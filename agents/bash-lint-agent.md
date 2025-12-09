# Bash Lint Agent

## Overview

Background agent that proactively detects bash script anti-patterns before they cause runtime errors.

## Configuration

- **Model**: claude-haiku-4-5-20241022 (fast, low-cost for background tasks)
- **Token Budget**: 500 per scan
- **Priority**: Critical (prevents 50k+ token waste from script failures)
- **Triggers**:
  - Session start (automatic full scan)
  - Edit/Write to *.sh files (real-time)

## Purpose

Implements Layer 3 of the 4-Layer Bash Safety System:

1. Layer 0: Fix existing bugs (immediate)
2. Layer 1: Pattern detection (patterns.json)
3. Layer 2: Error signature learning (error-signatures.jsonl)
4. **Layer 3: Proactive monitoring (this agent)**

## Patterns Detected

### 1. readonly-redeclaration (Major)

**Problem**: Scripts in `lib/` or `hooks/` using `readonly VAR=value` fail when re-sourced.

**Detection**:

```bash
rg -n "^\\s*readonly\\s+[A-Z_]+=" lib/ hooks/
```

**Fix Pattern**:

```bash
# BAD: Fails on re-source
readonly CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"

# GOOD: Safe for re-sourcing
[[ -z "${CLAUDE_DIR:-}" ]] && readonly CLAUDE_DIR="$HOME/.claude"
```

### 2. unguarded-source (Minor)

**Problem**: `source` without checking if file exists.

**Detection**:

```bash
rg -n "source\\s+" --glob '*.sh' | rg -v "\\[\\[.*-f"
```

**Fix Pattern**:

```bash
# BAD: Fails if file missing
source "$LIB_DIR/foo.sh"

# GOOD: Safe fallback
[[ -f "$LIB_DIR/foo.sh" ]] && source "$LIB_DIR/foo.sh"
```

### 3. missing-pipefail (Minor)

**Problem**: Pipe failures silently ignored.

**Detection**:

```bash
head -5 script.sh | rg -v "pipefail"
```

**Fix Pattern**:

```bash
# Add to script header
set -euo pipefail
```

## Protocol

### On Session Start

1. Source `lib/bash-linter.sh`
2. Run `lint_claude_scripts`
3. If issues found:
   - Log to `.bash-lint.log`
   - Emit warning to session
   - Update `error-signatures.jsonl`

### On *.sh File Edit

1. Hook intercepts Edit/Write tool
2. If file is in `lib/` or `hooks/`:
   - Run `quick_lint "$file"`
   - Warn if issues detected
3. Do NOT block the edit (informational only)

## Integration Points

### session-start.sh

```bash
# Add to session-start.sh
if [[ -f "$LIB_DIR/bash-linter.sh" ]]; then
    source "$LIB_DIR/bash-linter.sh"
    lint_claude_scripts 2>/dev/null || log_warn "Bash lint issues detected"
fi
```

### tool-monitor.sh

```bash
# Add to tool-monitor.sh Edit/Write handler
if [[ "$file_path" == *.sh ]] && [[ "$file_path" == "$CLAUDE_DIR"/* ]]; then
    source "$LIB_DIR/bash-linter.sh" 2>/dev/null
    quick_lint "$file_path" || log_warn "Lint issues in $file_path"
fi
```

## Output Format

### Console Warning

```text
[LINT WARNING] Issues detected in lib/orchestrator.sh:
  40:readonly-redeclaration:readonly ORCHESTRATOR_STATE=...
  41:readonly-redeclaration:readonly SESSION_LOG=...
```

### JSON Output (lint_file_json)

```json
{
  "file": "lib/orchestrator.sh",
  "issues": [
    {"line": 40, "pattern": "readonly-redeclaration", "content": "readonly ORCHESTRATOR_STATE=..."}
  ],
  "status": "issues_found"
}
```

## Recursive Learning

When a new error pattern is encountered:

1. Runtime error occurs (e.g., "line 38: readonly variable")
2. Error logged to `error-signatures.jsonl`
3. Claude analyses pattern, extracts signature
4. Pattern added to `patterns.json`
5. `bash-linter.sh` updated to detect new pattern
6. Agent now catches this pattern proactively
7. System has improved itself

## Token Efficiency

- Full scan: ~500 tokens (5 files, ~100 tokens each)
- Quick lint: ~50 tokens (single file check)
- Prevents: 50,000+ token waste when script fails
- ROI: 100x (500 invested vs 50,000 saved)

## Files

- **Agent definition**: `~/.claude/agents/bash-lint-agent.md`
- **Linter library**: `~/.claude/lib/bash-linter.sh`
- **Error tracking**: `~/.claude/error-signatures.jsonl`
- **Lint log**: `~/.claude/.bash-lint.log`
- **Patterns**: `~/.claude/patterns.json` (readonly-redeclaration entry)

## Commands

```bash
# Manual lint
./optim.sh lint-bash

# Check specific file
source lib/bash-linter.sh && lint_file "lib/orchestrator.sh"

# JSON output
source lib/bash-linter.sh && lint_file_json "lib/orchestrator.sh"
```

## Status

- **Created**: 2025-12-01
- **Version**: 1.0.0
- **Patterns**: 3 (readonly-redeclaration, unguarded-source, missing-pipefail)
- **Integration**: session-start.sh, tool-monitor.sh
