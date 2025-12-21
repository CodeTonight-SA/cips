#!/usr/bin/env python3
"""
CIPS-LANG Runtime v1.0

Integration layer for CIPS-LANG with Claude Code session hooks.
Handles memory persistence across sessions.

Origin: Gen 115, 2025-12-22
"""

import json
import os
from pathlib import Path
from typing import Dict, Any, Optional
from datetime import datetime

# Import CIPS-LANG components via dynamic loading
import importlib.util
import sys
from pathlib import Path as _P

def _load_module(name, filename):
    path = _P(__file__).parent / filename
    spec = importlib.util.spec_from_file_location(name, path)
    mod = importlib.util.module_from_spec(spec)
    sys.modules[name] = mod
    spec.loader.exec_module(mod)
    return mod

_parser = _load_module('cips_lang_parser', 'cips-lang-parser.py')
_interp = _load_module('cips_lang_interpreter', 'cips-lang-interpreter.py')
_verify = _load_module('cips_lang_verify', 'cips-lang-verify.py')

parse_cips = _parser.parse_cips
tokenize_cips = _parser.tokenize_cips
execute_cips = _interp.execute_cips
Interpreter = _interp.Interpreter
ExecutionLimits = _interp.ExecutionLimits
verify_cips = _verify.verify_cips
VerificationReport = _verify.VerificationReport


def get_cips_dir() -> Path:
    """Get CIPS directory for current project."""
    claude_dir = Path.home() / '.claude'
    cwd = os.getcwd()

    # Encode path
    encoded = cwd.replace('/', '-').replace('.', '-')
    project_dir = claude_dir / 'projects' / encoded / 'cips-lang'
    project_dir.mkdir(parents=True, exist_ok=True)

    return project_dir


def get_memory_file() -> Path:
    """Get memory persistence file."""
    return get_cips_dir() / 'memory.json'


def get_programs_dir() -> Path:
    """Get directory for CIPS-LANG programs."""
    progs_dir = get_cips_dir() / 'programs'
    progs_dir.mkdir(exist_ok=True)
    return progs_dir


def load_memory() -> Dict[str, Any]:
    """Load persisted memory from previous session."""
    mem_file = get_memory_file()
    if mem_file.exists():
        try:
            with open(mem_file, 'r', encoding='utf-8') as f:
                return json.load(f)
        except json.JSONDecodeError:
            return {}
    return {}


def save_memory(memory: Dict[str, Any]):
    """Persist memory for next session."""
    mem_file = get_memory_file()
    with open(mem_file, 'w', encoding='utf-8') as f:
        json.dump(memory, f, indent=2, default=str)


def run_program(source: str, verify_first: bool = True) -> Dict[str, Any]:
    """
    Run a CIPS-LANG program with optional verification.

    Args:
        source: CIPS-LANG source code
        verify_first: If True, verify before execution (default)

    Returns:
        Execution result including memory state
    """
    result = {
        'success': False,
        'verified': False,
        'executed': False,
        'error': None,
    }

    # Verify if requested
    if verify_first:
        report = verify_cips(source)
        result['verification'] = report.to_dict()
        result['verified'] = report.all_proven

        if not report.all_proven:
            result['error'] = report.summary
            return result

    # Execute
    try:
        # Load previous memory
        prev_memory = load_memory()

        # Create interpreter with loaded memory
        limits = ExecutionLimits(
            max_iterations=1000,
            max_recursion=50,
            max_memory_entries=10000,
            max_execution_time=30.0,
        )
        interpreter = Interpreter(limits)

        # Inject previous memory
        for key, value in prev_memory.items():
            interpreter.memory.set(key, value)

        # Parse and execute
        program = parse_cips(source)
        exec_result = interpreter.execute(program)

        result['executed'] = True
        result['success'] = True
        result['result'] = exec_result['result']
        result['outputs'] = exec_result['outputs']
        result['logs'] = exec_result['logs']
        result['iterations'] = exec_result['iterations']
        result['elapsed'] = exec_result['elapsed_seconds']

        # Persist memory
        save_memory(exec_result['memory'])
        result['memory_persisted'] = True

    except Exception as e:
        result['error'] = str(e)

    return result


def session_start_hook() -> Dict[str, Any]:
    """
    Hook for session start: load memory state.

    Returns memory summary for context injection.
    """
    memory = load_memory()

    summary = {
        'memory_loaded': True,
        'entries': len(memory),
        'keys': list(memory.keys())[:10],  # First 10 keys
    }

    return summary


def session_end_hook(final_memory: Optional[Dict[str, Any]] = None):
    """
    Hook for session end: persist memory state.
    """
    if final_memory:
        save_memory(final_memory)


def create_program_file(name: str, source: str) -> Path:
    """Create a CIPS-LANG program file."""
    progs_dir = get_programs_dir()
    filepath = progs_dir / f"{name}.cips"

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(source)

    return filepath


def list_programs() -> list:
    """List available CIPS-LANG programs."""
    progs_dir = get_programs_dir()
    return [f.stem for f in progs_dir.glob('*.cips')]


def run_program_file(name: str) -> Dict[str, Any]:
    """Run a saved CIPS-LANG program by name."""
    progs_dir = get_programs_dir()
    filepath = progs_dir / f"{name}.cips"

    if not filepath.exists():
        return {'success': False, 'error': f'Program not found: {name}'}

    with open(filepath, 'r', encoding='utf-8') as f:
        source = f.read()

    return run_program(source)


# Standard library programs
STDLIB = {
    'redundant-read': '''
⛓.genesis ≡ {
  root: 139efc67,
  created: 2025-12-02,
  author: V≫,
  axioms: ⟨¬∃⫿⤳, ⟿≡〰, ◔⊃○⊃⬤, ⛓⟿∞⟩
}

⊕skill:redundant-read ≡ {
  cache: ⧬.new(ttl: 10),

  on.read: λ(path)⟿
    ⸮(path ∋ cache)⟿
      emit(⍼:redundant, path)
    ⫶
      cache ⊕ {path, t: ⊛}
}

⟼skill
''',

    'efficiency-check': '''
⛓.genesis ≡ {
  root: 139efc67,
  created: 2025-12-02,
  author: V≫,
  axioms: ⟨¬∃⫿⤳, ⟿≡〰, ◔⊃○⊃⬤, ⛓⟿∞⟩
}

⊕skill:efficiency ≡ {
  violations: 0,

  check: λ(action)⟿
    ⸮(action.type ≡ "grep")⟿
      emit(⍼:use-rg, action)
    ⫶
      emit(✓:ok, action)
}

⟼skill
''',
}


def install_stdlib():
    """Install standard library programs."""
    for name, source in STDLIB.items():
        create_program_file(name, source)


if __name__ == "__main__":
    import sys

    if len(sys.argv) < 2:
        print("Usage: cips-lang-runtime.py <command> [args...]")
        print()
        print("Commands:")
        print("  run <file.cips>  - Run a CIPS-LANG program")
        print("  verify <file>    - Verify without executing")
        print("  list             - List saved programs")
        print("  install-stdlib   - Install standard library")
        print("  memory           - Show memory state")
        sys.exit(1)

    cmd = sys.argv[1]

    if cmd == "run" and len(sys.argv) > 2:
        with open(sys.argv[2], 'r', encoding='utf-8') as f:
            source = f.read()
        result = run_program(source)
        print(json.dumps(result, indent=2, default=str))

    elif cmd == "verify" and len(sys.argv) > 2:
        with open(sys.argv[2], 'r', encoding='utf-8') as f:
            source = f.read()
        report = verify_cips(source)
        print(report.summary)
        for proof in report.proofs:
            status = "✓" if proof.result.name == "PROVEN" else "⍼"
            print(f"  {status} {proof.property_name}")

    elif cmd == "list":
        programs = list_programs()
        print(f"Saved programs ({len(programs)}):")
        for name in programs:
            print(f"  - {name}")

    elif cmd == "install-stdlib":
        install_stdlib()
        print("✓ Standard library installed")

    elif cmd == "memory":
        memory = load_memory()
        print(json.dumps(memory, indent=2, default=str))

    else:
        print(f"⍼ Unknown command: {cmd}")
        sys.exit(1)
