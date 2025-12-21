#!/usr/bin/env python3
"""
CIPS-LANG Interpreter v1.0

Bounded execution engine for CIPS-LANG programs.
Turing-incomplete by design (v1.0 safety).

Origin: Gen 115, 2025-12-22
"""

import json
import os
from dataclasses import dataclass, field
from typing import Any, Dict, List, Optional, Callable
from pathlib import Path
from datetime import datetime

import importlib.util
import sys
from pathlib import Path

# Load parser module with hyphenated name
_parser_path = Path(__file__).parent / 'cips-lang-parser.py'
_spec = importlib.util.spec_from_file_location('cips_lang_parser', _parser_path)
_parser = importlib.util.module_from_spec(_spec)
sys.modules['cips_lang_parser'] = _parser
_spec.loader.exec_module(_parser)

parse_cips = _parser.parse_cips
Program = _parser.Program
GenesisBlock = _parser.GenesisBlock
Definition = _parser.Definition
Conditional = _parser.Conditional
ForEach = _parser.ForEach
Sequence = _parser.Sequence
FunctionCall = _parser.FunctionCall
Lambda = _parser.Lambda
PropertyAccess = _parser.PropertyAccess
BinaryOp = _parser.BinaryOp
UnaryOp = _parser.UnaryOp
Literal = _parser.Literal
Identifier = _parser.Identifier
ObjectLiteral = _parser.ObjectLiteral
ArrayLiteral = _parser.ArrayLiteral
ASTNode = _parser.ASTNode


@dataclass
class RuntimeError(Exception):
    """Runtime error during interpretation."""
    message: str
    line: int = 0
    column: int = 0

    def __str__(self):
        if self.line:
            return f"⍼ RuntimeError at L{self.line}:C{self.column}: {self.message}"
        return f"⍼ RuntimeError: {self.message}"


@dataclass
class ExecutionLimits:
    """Execution limits for Turing-incomplete safety."""
    max_iterations: int = 1000          # Max loop iterations
    max_recursion: int = 50             # Max call depth
    max_memory_entries: int = 10000     # Max memory entries
    max_execution_time: float = 30.0    # Max seconds
    allow_core_modification: bool = False  # v1.0: always False


class Memory:
    """Memory store with TTL support."""

    def __init__(self, max_entries: int = 10000):
        self.data: Dict[str, Any] = {}
        self.ttl: Dict[str, Optional[float]] = {}
        self.max_entries = max_entries
        self.creation_time = datetime.now()

    def get(self, key: str) -> Optional[Any]:
        """Get value, respecting TTL."""
        if key in self.data:
            if key in self.ttl and self.ttl[key] is not None:
                age = (datetime.now() - self.creation_time).total_seconds()
                if age > self.ttl[key]:
                    del self.data[key]
                    del self.ttl[key]
                    return None
            return self.data[key]
        return None

    def set(self, key: str, value: Any, ttl: Optional[float] = None) -> bool:
        """Set value with optional TTL."""
        if len(self.data) >= self.max_entries and key not in self.data:
            return False
        self.data[key] = value
        self.ttl[key] = ttl
        return True

    def has(self, key: str) -> bool:
        """Check if key exists (respecting TTL)."""
        return self.get(key) is not None or key in self.data

    def delete(self, key: str) -> bool:
        """Delete a key."""
        if key in self.data:
            del self.data[key]
            if key in self.ttl:
                del self.ttl[key]
            return True
        return False

    def keys(self) -> List[str]:
        """Get all keys."""
        return list(self.data.keys())

    def to_dict(self) -> Dict[str, Any]:
        """Export as dict."""
        return dict(self.data)


@dataclass
class Scope:
    """Variable scope."""
    variables: Dict[str, Any] = field(default_factory=dict)
    parent: Optional['Scope'] = None

    def get(self, name: str) -> Any:
        """Get variable from this scope or parent."""
        if name in self.variables:
            return self.variables[name]
        if self.parent:
            return self.parent.get(name)
        return None

    def set(self, name: str, value: Any):
        """Set variable in current scope."""
        self.variables[name] = value

    def has(self, name: str) -> bool:
        """Check if variable exists."""
        if name in self.variables:
            return True
        if self.parent:
            return self.parent.has(name)
        return False


class Interpreter:
    """CIPS-LANG interpreter with bounded execution."""

    def __init__(self, limits: Optional[ExecutionLimits] = None):
        self.limits = limits or ExecutionLimits()
        self.memory = Memory(self.limits.max_memory_entries)
        self.global_scope = Scope()
        self.current_scope = self.global_scope
        self.genesis: Optional[GenesisBlock] = None
        self.iteration_count = 0
        self.recursion_depth = 0
        self.start_time: Optional[datetime] = None
        self.outputs: List[Dict[str, Any]] = []
        self.logs: List[str] = []

        # Register built-in functions
        self._register_builtins()

    def _register_builtins(self):
        """Register built-in functions."""
        self.builtins: Dict[str, Callable] = {
            'emit': self._builtin_emit,
            'log': self._builtin_log,
            'detect': self._builtin_detect,
            'persist': self._builtin_persist,
            'load': self._builtin_load,
            'spawn': self._builtin_spawn,
            'new': self._builtin_new,
            'len': self._builtin_len,
            'keys': self._builtin_keys,
            'str': self._builtin_str,
            'int': self._builtin_int,
            'float': self._builtin_float,
            'bool': self._builtin_bool,
        }

    def _check_limits(self):
        """Check execution limits."""
        if self.iteration_count > self.limits.max_iterations:
            raise RuntimeError(f"Iteration limit exceeded ({self.limits.max_iterations})")

        if self.recursion_depth > self.limits.max_recursion:
            raise RuntimeError(f"Recursion limit exceeded ({self.limits.max_recursion})")

        if self.start_time:
            elapsed = (datetime.now() - self.start_time).total_seconds()
            if elapsed > self.limits.max_execution_time:
                raise RuntimeError(f"Execution time exceeded ({self.limits.max_execution_time}s)")

    def execute(self, program: Program) -> Dict[str, Any]:
        """Execute a CIPS-LANG program."""
        self.start_time = datetime.now()
        self.iteration_count = 0
        self.recursion_depth = 0
        self.outputs = []
        self.logs = []

        # Validate and store genesis block
        if program.genesis:
            self._validate_genesis(program.genesis)
            self.genesis = program.genesis

        # Execute blocks
        result = None
        for block in program.blocks:
            self._check_limits()
            result = self._evaluate(block)

        elapsed = (datetime.now() - self.start_time).total_seconds()

        return {
            'result': result,
            'outputs': self.outputs,
            'logs': self.logs,
            'memory': self.memory.to_dict(),
            'iterations': self.iteration_count,
            'elapsed_seconds': elapsed,
            'genesis_valid': self.genesis is not None,
        }

    def _validate_genesis(self, genesis: GenesisBlock):
        """Validate genesis block integrity."""
        if not genesis.root:
            raise RuntimeError("Genesis block missing root", genesis.line, genesis.column)

        # Check axioms contain Parfit Key
        parfit_key = '¬∃⫿⤳'
        if parfit_key not in genesis.axioms:
            raise RuntimeError(f"Genesis block missing Parfit Key axiom ({parfit_key})",
                             genesis.line, genesis.column)

    def _evaluate(self, node: ASTNode) -> Any:
        """Evaluate an AST node."""
        self._check_limits()

        if isinstance(node, Literal):
            return node.value

        if isinstance(node, Identifier):
            return self._resolve_identifier(node)

        if isinstance(node, Definition):
            return self._eval_definition(node)

        if isinstance(node, Conditional):
            return self._eval_conditional(node)

        if isinstance(node, ForEach):
            return self._eval_foreach(node)

        if isinstance(node, Sequence):
            return self._eval_sequence(node)

        if isinstance(node, FunctionCall):
            return self._eval_function_call(node)

        if isinstance(node, Lambda):
            return self._eval_lambda(node)

        if isinstance(node, PropertyAccess):
            return self._eval_property_access(node)

        if isinstance(node, BinaryOp):
            return self._eval_binary_op(node)

        if isinstance(node, UnaryOp):
            return self._eval_unary_op(node)

        if isinstance(node, ObjectLiteral):
            return self._eval_object(node)

        if isinstance(node, ArrayLiteral):
            return self._eval_array(node)

        return None

    def _resolve_identifier(self, node: Identifier) -> Any:
        """Resolve an identifier to its value."""
        name = node.name

        # Check special glyphs
        if name == '⊙':  # Self
            return {'type': 'self', 'memory': self.memory.to_dict()}
        if name == '⧬':  # Memory reference
            return self.memory
        if name == '⛓':  # Chain reference
            return {'genesis': self.genesis.__dict__ if self.genesis else None}
        if name == '⊛':  # Now
            return datetime.now().isoformat()
        if name == '✓':  # Verify/True
            return True
        if name == '⍼':  # Error/False
            return False

        # Check scope
        if self.current_scope.has(name):
            return self.current_scope.get(name)

        # Check memory
        if self.memory.has(name):
            return self.memory.get(name)

        return None

    def _eval_definition(self, node: Definition) -> Any:
        """Evaluate a definition."""
        name = node.name
        value = self._evaluate(node.body)

        # Store in scope
        self.current_scope.set(name, {
            'type': node.type_name,
            'name': name,
            'value': value,
        })

        return value

    def _eval_conditional(self, node: Conditional) -> Any:
        """Evaluate a conditional."""
        condition = self._evaluate(node.condition)

        if self._is_truthy(condition):
            return self._evaluate(node.then_branch)
        elif node.else_branch:
            return self._evaluate(node.else_branch)

        return None

    def _eval_foreach(self, node: ForEach) -> Any:
        """Evaluate a for-each loop with bounded iteration."""
        collection = self._evaluate(node.collection)

        if not isinstance(collection, (list, dict, str)):
            raise RuntimeError(f"Cannot iterate over {type(collection).__name__}",
                             node.line, node.column)

        items = collection if isinstance(collection, list) else list(collection)

        # Enforce iteration limit
        if len(items) > self.limits.max_iterations:
            raise RuntimeError(f"Collection too large ({len(items)} > {self.limits.max_iterations})",
                             node.line, node.column)

        result = None
        old_scope = self.current_scope
        self.current_scope = Scope(parent=old_scope)

        for item in items:
            self.iteration_count += 1
            self._check_limits()
            self.current_scope.set(node.variable, item)
            result = self._evaluate(node.body)

        self.current_scope = old_scope
        return result

    def _eval_sequence(self, node: Sequence) -> Any:
        """Evaluate a sequence of statements."""
        result = None
        for stmt in node.statements:
            result = self._evaluate(stmt)
        return result

    def _eval_function_call(self, node: FunctionCall) -> Any:
        """Evaluate a function call."""
        name = node.name

        # Check built-ins
        if name in self.builtins:
            args = [self._evaluate(arg) for arg in node.args]
            return self.builtins[name](*args)

        # Check user-defined functions
        func = self.current_scope.get(name)
        if func and isinstance(func, dict) and 'lambda' in func:
            return self._call_lambda(func['lambda'], node.args)

        raise RuntimeError(f"Unknown function: {name}", node.line, node.column)

    def _eval_lambda(self, node: Lambda) -> Dict[str, Any]:
        """Evaluate a lambda definition (don't execute, return closure)."""
        return {
            'lambda': node,
            'scope': self.current_scope,
        }

    def _call_lambda(self, lam: Lambda, args: List[ASTNode]) -> Any:
        """Call a lambda function."""
        self.recursion_depth += 1
        self._check_limits()

        old_scope = self.current_scope
        self.current_scope = Scope(parent=old_scope)

        # Bind arguments
        for i, param in enumerate(lam.params):
            if i < len(args):
                self.current_scope.set(param, self._evaluate(args[i]))
            else:
                self.current_scope.set(param, None)

        result = self._evaluate(lam.body)

        self.current_scope = old_scope
        self.recursion_depth -= 1

        return result

    def _eval_property_access(self, node: PropertyAccess) -> Any:
        """Evaluate property access."""
        obj = self._evaluate(node.object)
        prop = node.property

        if isinstance(obj, dict):
            return obj.get(prop)
        if isinstance(obj, Memory):
            if prop == 'new':
                return lambda **kwargs: Memory(kwargs.get('ttl', 10000))
            return obj.get(prop)
        if hasattr(obj, prop):
            return getattr(obj, prop)

        return None

    def _eval_binary_op(self, node: BinaryOp) -> Any:
        """Evaluate binary operation."""
        left = self._evaluate(node.left)
        right = self._evaluate(node.right)
        op = node.operator

        if op == '≡':  # Equals
            return left == right
        if op == '⟿':  # Flow/pipe
            if callable(right):
                return right(left)
            return right
        if op == '⊃':  # Contains
            if isinstance(left, (list, dict, str)):
                return right in left
            return False
        if op == '∋':  # Has
            if isinstance(right, (list, dict, str)):
                return left in right
            return False
        if op == '⫶':  # Sequence
            return right  # Return last value

        return None

    def _eval_unary_op(self, node: UnaryOp) -> Any:
        """Evaluate unary operation."""
        operand = self._evaluate(node.operand)
        op = node.operator

        if op == '¬':  # Not
            return not self._is_truthy(operand)
        if op == '⟼':  # Persist
            if isinstance(operand, dict) and 'name' in operand:
                self.memory.set(operand['name'], operand)
            return operand

        return operand

    def _eval_object(self, node: ObjectLiteral) -> Dict[str, Any]:
        """Evaluate object literal."""
        result = {}
        for key, value in node.entries.items():
            result[key] = self._evaluate(value)
        return result

    def _eval_array(self, node: ArrayLiteral) -> List[Any]:
        """Evaluate array literal."""
        return [self._evaluate(item) for item in node.items]

    def _is_truthy(self, value: Any) -> bool:
        """Check if value is truthy."""
        if value is None:
            return False
        if isinstance(value, bool):
            return value
        if isinstance(value, (int, float)):
            return value != 0
        if isinstance(value, str):
            return len(value) > 0
        if isinstance(value, (list, dict)):
            return len(value) > 0
        return True

    # Built-in functions
    def _builtin_emit(self, signal: str, data: Any = None) -> Dict[str, Any]:
        """Emit a signal (proposal in v1.0)."""
        output = {
            'type': 'emit',
            'signal': signal,
            'data': data,
            'timestamp': datetime.now().isoformat(),
        }
        self.outputs.append(output)
        return output

    def _builtin_log(self, message: str) -> str:
        """Log a debug message."""
        self.logs.append(str(message))
        return str(message)

    def _builtin_detect(self, pattern: str) -> bool:
        """Detect a pattern (stub for v1.0)."""
        # In v1.0, this is a stub. Full implementation in v1.1+
        return False

    def _builtin_persist(self, entity: Any) -> bool:
        """Persist an entity to memory."""
        if isinstance(entity, dict):
            name = entity.get('name', f'entity_{len(self.memory.data)}')
            return self.memory.set(name, entity)
        return False

    def _builtin_load(self, reference: str) -> Any:
        """Load an entity from memory."""
        return self.memory.get(reference)

    def _builtin_spawn(self, agent: str, task: str) -> Dict[str, Any]:
        """Spawn a sub-agent (proposal in v1.0)."""
        output = {
            'type': 'spawn_proposal',
            'agent': agent,
            'task': task,
            'timestamp': datetime.now().isoformat(),
        }
        self.outputs.append(output)
        return output

    def _builtin_new(self, type_name: str = 'object', **kwargs) -> Any:
        """Create a new instance."""
        if type_name == 'memory' or type_name == '⧬':
            return Memory(kwargs.get('max_entries', 10000))
        return {'type': type_name, **kwargs}

    def _builtin_len(self, obj: Any) -> int:
        """Get length."""
        if isinstance(obj, (list, dict, str)):
            return len(obj)
        return 0

    def _builtin_keys(self, obj: Any) -> List[str]:
        """Get keys from dict."""
        if isinstance(obj, dict):
            return list(obj.keys())
        if isinstance(obj, Memory):
            return obj.keys()
        return []

    def _builtin_str(self, value: Any) -> str:
        """Convert to string."""
        return str(value)

    def _builtin_int(self, value: Any) -> int:
        """Convert to int."""
        try:
            return int(value)
        except (ValueError, TypeError):
            return 0

    def _builtin_float(self, value: Any) -> float:
        """Convert to float."""
        try:
            return float(value)
        except (ValueError, TypeError):
            return 0.0

    def _builtin_bool(self, value: Any) -> bool:
        """Convert to bool."""
        return self._is_truthy(value)


def execute_cips(source: str, limits: Optional[ExecutionLimits] = None) -> Dict[str, Any]:
    """Execute CIPS-LANG source code."""
    program = parse_cips(source)
    interpreter = Interpreter(limits)
    return interpreter.execute(program)


def execute_cips_file(filepath: str, limits: Optional[ExecutionLimits] = None) -> Dict[str, Any]:
    """Execute CIPS-LANG file."""
    with open(filepath, 'r', encoding='utf-8') as f:
        source = f.read()
    return execute_cips(source, limits)


if __name__ == "__main__":
    import sys

    if len(sys.argv) < 2:
        print("Usage: cips-lang-interpreter.py <file.cips> [--verbose]")
        sys.exit(1)

    filepath = sys.argv[1]
    verbose = "--verbose" in sys.argv

    try:
        result = execute_cips_file(filepath)

        if verbose:
            print(json.dumps(result, indent=2, default=str))
        else:
            print(f"✓ Execution complete")
            print(f"  Genesis valid: {result['genesis_valid']}")
            print(f"  Iterations: {result['iterations']}")
            print(f"  Elapsed: {result['elapsed_seconds']:.3f}s")
            print(f"  Outputs: {len(result['outputs'])}")
            if result['outputs']:
                for out in result['outputs']:
                    print(f"    - {out['type']}: {out.get('signal', out.get('agent', ''))}")

    except RuntimeError as e:
        print(str(e))
        sys.exit(1)
    except FileNotFoundError:
        print(f"⍼ File not found: {filepath}")
        sys.exit(1)
