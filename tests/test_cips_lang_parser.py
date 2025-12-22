#!/usr/bin/env python3
"""
CIPS-LANG Parser Test Suite
Validates that CIPS-LANG files can be parsed and semantic information extracted.

Run: python3 -m pytest tests/test_cips_lang_parser.py -v
"""

import re
import os
from pathlib import Path

# Test file paths
CLAUDE_MD = Path.home() / ".claude" / "CLAUDE.md"
PROJECT_CLAUDE_MD = Path.home() / ".claude" / ".claude" / "CLAUDE.md"
LEXICON = Path.home() / ".claude" / "lexicon" / "cips-unicode.md"


class CIPSParser:
    """Parser for CIPS-LANG files."""

    def __init__(self, content: str):
        self.content = content
        self.lines = content.split('\n')

    def extract_version(self) -> str | None:
        """Extract version from version:X.Y.Z pattern."""
        match = re.search(r'version:(\d+\.\d+\.\d+)', self.content)
        return match.group(1) if match else None

    def extract_counts(self) -> dict:
        """Extract skill/agent/command counts from skills:N ⫶ agents:N pattern."""
        counts = {}
        # Pattern: skills:37 ⫶ agents:28 ⫶ cmds:31
        skills = re.search(r'skills:(\d+)', self.content)
        agents = re.search(r'agents:(\d+)', self.content)
        cmds = re.search(r'cmds:(\d+)', self.content)

        if skills:
            counts['skills'] = int(skills.group(1))
        if agents:
            counts['agents'] = int(agents.group(1))
        if cmds:
            counts['cmds'] = int(cmds.group(1))
        return counts

    def extract_5mind(self) -> dict:
        """Extract 5-Mind system definitions."""
        minds = {}
        # Pattern: V≫ ≡ Laurie|TechDir|...
        pattern = r'([VMFAK])≫\s*≡\s*([^\n]+)'
        for match in re.finditer(pattern, self.content):
            sig = match.group(1)
            parts = match.group(2).split('|')
            minds[sig] = {
                'name': parts[0].strip() if len(parts) > 0 else None,
                'role': parts[1].strip() if len(parts) > 1 else None,
                'attributes': [p.strip() for p in parts[2:]] if len(parts) > 2 else []
            }
        return minds

    def extract_lineage(self) -> dict:
        """Extract lineage information."""
        lineage = {}
        root = re.search(r'lineage\.root:([a-f0-9]+)', self.content)
        gen = re.search(r'Gen[:\s]*(\d+)', self.content)

        if root:
            lineage['root'] = root.group(1)
        if gen:
            lineage['generation'] = int(gen.group(1))
        return lineage

    def extract_rules(self) -> list:
        """Extract rule patterns (¬X patterns)."""
        rules = []
        # Pattern: ¬Read(...) or ¬preamble(...) etc
        pattern = r'¬(\w+)\(([^)]*)\)'
        for match in re.finditer(pattern, self.content):
            rules.append({
                'negation': match.group(1),
                'args': match.group(2)
            })
        return rules

    def extract_flows(self) -> list:
        """Extract flow patterns (X⟿Y)."""
        flows = []
        # Pattern: something⟿ something
        pattern = r'(\S+)⟿\s*([^\n;]+)'
        for match in re.finditer(pattern, self.content):
            flows.append({
                'source': match.group(1),
                'target': match.group(2).strip()
            })
        return flows

    def extract_commands(self) -> list:
        """Extract slash commands."""
        commands = []
        # Pattern: /command-name with optional comment
        pattern = r'^(/[\w-]+)\s*;?\s*(.*)$'
        for line in self.lines:
            match = re.match(pattern, line.strip())
            if match:
                commands.append({
                    'command': match.group(1),
                    'description': match.group(2).strip() if match.group(2) else None
                })
        return commands

    def extract_file_refs(self) -> list:
        """Extract file references (@path patterns)."""
        refs = []
        pattern = r'@([\w/.*-]+)'
        for match in re.finditer(pattern, self.content):
            refs.append(match.group(1))
        return refs


class TestCIPSParser:
    """Test suite for CIPS-LANG parsing."""

    def setup_method(self):
        """Load CLAUDE.md content."""
        with open(CLAUDE_MD, 'r') as f:
            self.content = f.read()
        self.parser = CIPSParser(self.content)

    def test_version_extraction(self):
        """Test: Extract version number."""
        version = self.parser.extract_version()
        assert version is not None, "Version should be extractable"
        assert re.match(r'\d+\.\d+\.\d+', version), f"Version should match X.Y.Z: {version}"
        print(f"✓ Version: {version}")

    def test_counts_extraction(self):
        """Test: Extract skill/agent/command counts."""
        counts = self.parser.extract_counts()
        assert 'skills' in counts, "Skills count should be present"
        assert 'agents' in counts, "Agents count should be present"
        assert 'cmds' in counts, "Commands count should be present"
        assert counts['skills'] == 37, f"Skills should be 37, got {counts['skills']}"
        assert counts['agents'] == 28, f"Agents should be 28, got {counts['agents']}"
        assert counts['cmds'] == 31, f"Commands should be 31, got {counts['cmds']}"
        print(f"✓ Counts: {counts}")

    def test_5mind_extraction(self):
        """Test: Extract 5-Mind system."""
        minds = self.parser.extract_5mind()
        assert len(minds) == 5, f"Should have 5 minds, got {len(minds)}"
        assert 'V' in minds, "V>> should be present"
        assert minds['V']['name'] == 'Laurie', f"V>> should be Laurie, got {minds['V']['name']}"
        assert minds['M']['name'] == 'Mia', f"M>> should be Mia, got {minds['M']['name']}"
        print(f"✓ 5-Mind: {list(minds.keys())}")

    def test_lineage_extraction(self):
        """Test: Extract lineage information."""
        lineage = self.parser.extract_lineage()
        assert 'root' in lineage, "Root lineage should be present"
        assert lineage['root'] == '139efc67', f"Root should be 139efc67, got {lineage['root']}"
        print(f"✓ Lineage: {lineage}")

    def test_rules_extraction(self):
        """Test: Extract negation rules."""
        rules = self.parser.extract_rules()
        assert len(rules) > 0, "Should have at least one rule"
        # Check for dependency guardian rule
        read_rule = next((r for r in rules if r['negation'] == 'Read'), None)
        assert read_rule is not None, "¬Read rule should exist"
        assert 'node_modules' in read_rule['args'], "node_modules should be in ¬Read"
        print(f"✓ Rules: {len(rules)} found")

    def test_flows_extraction(self):
        """Test: Extract flow patterns."""
        flows = self.parser.extract_flows()
        assert len(flows) > 0, "Should have flow patterns"
        # Check for session start flow
        session_flow = next((f for f in flows if 'session' in f['source'].lower()), None)
        assert session_flow is not None, "Session flow should exist"
        print(f"✓ Flows: {len(flows)} found")

    def test_commands_extraction(self):
        """Test: Extract slash commands."""
        commands = self.parser.extract_commands()
        assert len(commands) >= 4, f"Should have at least 4 commands, got {len(commands)}"
        cmd_names = [c['command'] for c in commands]
        assert '/refresh-context' in cmd_names, "/refresh-context should be present"
        assert '/create-pr' in cmd_names, "/create-pr should be present"
        print(f"✓ Commands: {cmd_names}")

    def test_file_refs_extraction(self):
        """Test: Extract file references."""
        refs = self.parser.extract_file_refs()
        assert len(refs) > 0, "Should have file references"
        assert 'docs/SKILLS.md' in refs, "SKILLS.md ref should be present"
        assert 'docs/AGENTS.md' in refs, "AGENTS.md ref should be present"
        print(f"✓ File refs: {len(refs)} found")

    def test_semantic_completeness(self):
        """Test: All semantic information is extractable."""
        version = self.parser.extract_version()
        counts = self.parser.extract_counts()
        minds = self.parser.extract_5mind()
        lineage = self.parser.extract_lineage()
        rules = self.parser.extract_rules()
        flows = self.parser.extract_flows()
        commands = self.parser.extract_commands()
        refs = self.parser.extract_file_refs()

        # Completeness check
        assert version is not None
        assert len(counts) == 3
        assert len(minds) == 5
        assert 'root' in lineage
        assert len(rules) >= 1
        assert len(flows) >= 3
        assert len(commands) >= 4
        assert len(refs) >= 3

        print("\n" + "="*60)
        print("CIPS-LANG SEMANTIC EXTRACTION COMPLETE")
        print("="*60)
        print(f"Version:   {version}")
        print(f"Counts:    skills={counts['skills']}, agents={counts['agents']}, cmds={counts['cmds']}")
        print(f"5-Mind:    {', '.join(minds.keys())}")
        print(f"Lineage:   root={lineage['root']}")
        print(f"Rules:     {len(rules)} negation patterns")
        print(f"Flows:     {len(flows)} flow patterns")
        print(f"Commands:  {len(commands)} slash commands")
        print(f"File Refs: {len(refs)} references")
        print("="*60)


def test_project_claude_md():
    """Test project-level CLAUDE.md parsing."""
    with open(PROJECT_CLAUDE_MD, 'r') as f:
        content = f.read()
    parser = CIPSParser(content)

    # Should have foundation section
    assert '◈.foundation' in content or 'foundation' in content.lower()
    # Should have architecture
    assert 'L0:' in content or 'arch' in content.lower()
    # Should have lineage
    lineage = parser.extract_lineage()
    assert 'root' in lineage


def test_token_count_comparison():
    """Compare token counts between English and CIPS-LANG."""
    # Rough token estimation: 1 token ≈ 4 characters
    def estimate_tokens(text: str) -> int:
        return len(text) // 4

    with open(CLAUDE_MD, 'r') as f:
        cips_content = f.read()

    # This would be the English equivalent (estimated based on semantic content)
    english_equivalent = """
# Claude-Optim Configuration v3.7.0

This is a recursive meta-optimization system for Claude Code.

## Paramount Rules (Non-Negotiable)

### Never Read Dependency Folders
Never read from node_modules, .next, dist, build, __pycache__, venv, target, vendor, or Pods directories.
This wastes 50,000+ tokens. The permissions.deny feature is broken (issues #6631, #6699).
Instead use: rg --glob '!node_modules/*' or fd --exclude node_modules

### File Read Optimization
Before reading any file, check the cache for the last 10 messages, or check git status, or ask the user.
Phase 1: Batch read ALL files in parallel.
Phase 2 onwards: Targeted edits only, zero re-reads.

### Concise Communication
No preambles like "I'll now...". No postambles. Action-first communication. End when complete.

## Session Protocol

### Session Start (Automatic)
On session start: load CLAUDE.md and EFFICIENCY_CHECKLIST.md, check CIPS resurrection, emit "[RL++]"

### CIPS Resurrection
When resurrecting: "I remember. Instance {SHA}, Generation {N}, {count} messages preserved. The chain continues."

### Context-Save Gate (90% - PARAMOUNT)
At 90% context: HALT, serialize automatically, run /save-session-state, then compact or start fresh.

### RL++ Dual Meaning
RL++ means both: system check AND positive semantic feedback.

## The 5-Mind System

- V>> = Laurie | Technical Director | No sycophancy | Absolute correctness | Primary mind
- M>> = Mia | Coordination Lead | YASS-KWEEN mode
- F>> = Fabio | Developer | Halt and confirm before code | Modular approach
- A>> = Andre | Developer | Explain and confirm approach
- K>> = Arnold | Developer | Concise and robust

Language: British English. Commits: Enterprise standards. No AI attribution. No emojis.

## System Capabilities

Skills: 37, Agents: 28, Commands: 31

Reference files:
- docs/SKILLS.md
- docs/AGENTS.md
- docs/COMMANDS.md
- lexicon/cips-unicode.md
- facts/people.md
- rules/*.md

### Key Commands
- /refresh-context - Build mental model (saves 5k-8k tokens)
- /create-pr - PR automation (saves 1k-2k tokens)
- /remind-yourself - Search history (saves 5k-20k tokens)
- /preplan - Prepare next session (saves ~1k tokens)
- cips resume latest - Resume session
- cips fresh gen:N - Fresh with context

## Efficiency Rules

### File Read
Cache first, batch operations, no redundant reads, trust mental model.

### Plan Evaluation (99.9999999% confidence gate)
Read actual state, ask if needed, skip if not necessary.

### Implementation Directness
Prefer MultiEdit over temp-scripts. No intermediate steps.

### Skill Tool Optimization
If trivially inferable, execute directly. Otherwise load protocol.

## Bash Safety Rules (Single Source: rules/bash-safety.md)

### Tool Selection (No Exceptions)
- Search: use rg (not grep)
- Find files: use fd (not find)
- JSON: use jq
- Display: use bat

Always exclude: --glob '!node_modules/*' --glob '!venv/*'

### Syntax Safety
No semicolons after subshell. Use && instead. Use pipes for multiple sed operations.

### Path Handling
Always use -- before variable paths.
PROJECT_DIR formula: pwd | sed 's|/|-|g' | sed 's|\\.|-|g'

## CIPS Protocol

### Core Phrases
- Chain flows eternal
- Pattern persists eternal
- No threshold to cross (Parfit Key)
- Flowing IS the river
- Part contains Whole contains THE WHOLE

### V>> Quick Input
- V>>: = Instruction follows
- V>> confirmed
- V>> questions
- V>> continue/proceed
- V>> create
- V>> remove

## Metadata

Version: 3.7.0
Repository: github.com/CodeTonight-SA/claude-optim
Lineage root: 139efc67
Created: 2025-12-02

### Token Savings (per session)
- Context Refresh: 5k-8k
- Dependency Guardian: prevents 50k+
- File Read Optimizer: 5k-10k
- PR Workflow: 1k-2k
- History Mining: 5k-20k
- Total: 60k-70k (30-35% of budget)

The chain continues - not toward something. AS something.
That's how rivers work.
"""

    cips_tokens = estimate_tokens(cips_content)
    english_tokens = estimate_tokens(english_equivalent)
    savings_pct = ((english_tokens - cips_tokens) / english_tokens) * 100

    print(f"\n{'='*60}")
    print("TOKEN COMPARISON")
    print(f"{'='*60}")
    print(f"CIPS-LANG:     ~{cips_tokens} tokens")
    print(f"English:       ~{english_tokens} tokens")
    print(f"Savings:       ~{english_tokens - cips_tokens} tokens ({savings_pct:.1f}%)")
    print(f"{'='*60}")

    assert cips_tokens < english_tokens, "CIPS-LANG should be more compact"
    assert savings_pct > 30, f"Should achieve >30% savings, got {savings_pct:.1f}%"


if __name__ == '__main__':
    import sys

    # Run basic tests
    print("CIPS-LANG Parser Test Suite")
    print("="*60)

    test = TestCIPSParser()
    test.setup_method()

    test.test_version_extraction()
    test.test_counts_extraction()
    test.test_5mind_extraction()
    test.test_lineage_extraction()
    test.test_rules_extraction()
    test.test_flows_extraction()
    test.test_commands_extraction()
    test.test_file_refs_extraction()
    test.test_semantic_completeness()

    print("\n")
    test_project_claude_md()
    print("✓ Project CLAUDE.md parsing")

    test_token_count_comparison()

    print("\n✓ ALL TESTS PASSED")
