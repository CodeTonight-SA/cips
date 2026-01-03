#!/usr/bin/env python3
"""
Unified Enforcement Hook - PARAMOUNT Gates
==========================================

PreToolUse hook that BLOCKS tool execution for multiple enforcement rules.
Provides ACTUAL enforcement via permissionDecision: "deny".

Gates:
1. Context Gate (80%) - Block when approaching context limit
2. Dependency Guardian - Block reads from node_modules, venv, dist, etc.
3. Destructive Git - Block force push, hard reset without explicit approval
4. Secrets Detection - Block commits containing sensitive files

Architecture:
- Reads tool_name and tool_input from hook input
- Applies enforcement rules in priority order
- Returns permissionDecision: "deny" to BLOCK execution
"""

import json
import os
import re
import sys
from pathlib import Path

# Configuration
CONTEXT_MAX = int(os.environ.get("CONTEXT_GATE_MAX", 200000))
CONTEXT_WARNING = int(os.environ.get("CONTEXT_GATE_WARNING", int(CONTEXT_MAX * 0.70)))
CONTEXT_CRITICAL = int(os.environ.get("CONTEXT_GATE_CRITICAL", int(CONTEXT_MAX * 0.80)))

# State file for tracking
STATE_FILE = Path.home() / ".claude" / ".context-gate-state.json"

# Blocked dependency paths (case-insensitive matching)
BLOCKED_PATHS = [
    "node_modules",
    ".next",
    "dist",
    "build",
    "__pycache__",
    "venv",
    ".venv",
    "target",
    "vendor",
    "Pods",
    ".git/objects",
    ".nuxt",
    ".output",
    "coverage",
    ".cache",
]

# Destructive git patterns
DESTRUCTIVE_GIT_PATTERNS = [
    r"git\s+push\s+.*--force",
    r"git\s+push\s+-f\b",
    r"git\s+reset\s+--hard",
    r"git\s+clean\s+-fd",
    r"git\s+checkout\s+--\s+\.",  # Discard all changes
]

# Sensitive files that should not be committed
SENSITIVE_FILE_PATTERNS = [
    r"\.env$",
    r"\.env\.\w+$",
    r"credentials\.json$",
    r"secrets\.json$",
    r"\.pem$",
    r"\.key$",
    r"id_rsa",
    r"id_ed25519",
]


def deny(reason: str) -> dict:
    """Return a deny response."""
    return {
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "deny",
            "permissionDecisionReason": reason
        }
    }


def allow(system_message: str = None) -> dict:
    """Return an allow response, optionally with a system message."""
    response = {
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "allow"
        }
    }
    if system_message:
        response["systemMessage"] = system_message
    return response


def is_blocked_path(path: str) -> str | None:
    """Check if path contains a blocked directory. Returns the blocked component or None."""
    if not path:
        return None

    path_lower = path.lower()
    path_parts = Path(path).parts

    for blocked in BLOCKED_PATHS:
        blocked_lower = blocked.lower()
        # Check if any path component matches
        for part in path_parts:
            if part.lower() == blocked_lower:
                return blocked
        # Also check substring for patterns like .git/objects
        if blocked_lower in path_lower:
            return blocked

    return None


def is_destructive_git(command: str) -> str | None:
    """Check if command is a destructive git operation. Returns description or None."""
    if not command:
        return None

    for pattern in DESTRUCTIVE_GIT_PATTERNS:
        if re.search(pattern, command, re.IGNORECASE):
            if "push" in command and "force" in command.lower():
                return "git push --force (destructive: rewrites remote history)"
            if "reset --hard" in command:
                return "git reset --hard (destructive: discards uncommitted changes)"
            if "clean -fd" in command:
                return "git clean -fd (destructive: removes untracked files)"
            return f"destructive git operation"

    return None


def contains_sensitive_file(command: str) -> str | None:
    """Check if git command might commit sensitive files."""
    if not command:
        return None

    # Only check git add/commit commands
    if not re.search(r"git\s+(add|commit)", command, re.IGNORECASE):
        return None

    for pattern in SENSITIVE_FILE_PATTERNS:
        if re.search(pattern, command, re.IGNORECASE):
            match = re.search(pattern, command, re.IGNORECASE)
            return match.group(0) if match else "sensitive file"

    return None


def estimate_tokens_from_jsonl(transcript_path: str) -> int:
    """Estimate token count from conversation JSONL file."""
    if not transcript_path or not Path(transcript_path).exists():
        return 0

    total_chars = 0

    try:
        with open(transcript_path, 'r', encoding='utf-8') as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                try:
                    entry = json.loads(line)
                    if "message" in entry:
                        msg = entry["message"]
                        if isinstance(msg, dict):
                            content = msg.get("content", "")
                            if isinstance(content, str):
                                total_chars += len(content)
                            elif isinstance(content, list):
                                for block in content:
                                    if isinstance(block, dict):
                                        text = block.get("text", "")
                                        total_chars += len(text)
                    if "tool_input" in entry:
                        total_chars += len(json.dumps(entry["tool_input"]))
                    if "tool_output" in entry:
                        total_chars += len(str(entry.get("tool_output", "")))
                except json.JSONDecodeError:
                    continue
    except Exception:
        return 0

    return total_chars // 4


def get_state() -> dict:
    """Load state from file."""
    if STATE_FILE.exists():
        try:
            return json.loads(STATE_FILE.read_text())
        except:
            pass
    return {"warning_issued": False, "session_id": None}


def save_state(state: dict):
    """Save state to file."""
    STATE_FILE.parent.mkdir(parents=True, exist_ok=True)
    STATE_FILE.write_text(json.dumps(state))


def main():
    # Read hook input from stdin
    try:
        input_data = json.load(sys.stdin)
    except json.JSONDecodeError:
        print(json.dumps(allow()))
        return

    transcript_path = input_data.get("transcript_path", "")
    session_id = input_data.get("session_id", "")
    tool_name = input_data.get("tool_name", "")
    tool_input = input_data.get("tool_input", {})

    # Always allow critical tools
    ALLOWED_TOOLS = {"AskUserQuestion", "TodoWrite"}
    if tool_name in ALLOWED_TOOLS:
        print(json.dumps(allow()))
        return

    # =========================================================================
    # GATE 1: Dependency Guardian - Block reads from dependency folders
    # =========================================================================
    if tool_name in ("Read", "Glob", "Grep"):
        path = tool_input.get("file_path") or tool_input.get("path") or ""
        pattern = tool_input.get("pattern", "")

        blocked = is_blocked_path(path) or is_blocked_path(pattern)
        if blocked:
            print(json.dumps(deny(
                f"[DEPENDENCY GUARDIAN] BLOCKED: Cannot read from '{blocked}'. "
                f"These folders waste 50k+ tokens. Use rg/fd with --exclude instead."
            )))
            return

    # =========================================================================
    # GATE 2: Destructive Git - Block dangerous git operations
    # =========================================================================
    if tool_name == "Bash":
        command = tool_input.get("command", "")

        destructive = is_destructive_git(command)
        if destructive:
            print(json.dumps(deny(
                f"[DESTRUCTIVE GIT] BLOCKED: {destructive}. "
                f"This operation cannot be undone. If you need this, ask user for explicit approval first."
            )))
            return

        # Check for sensitive files in git commands
        sensitive = contains_sensitive_file(command)
        if sensitive:
            print(json.dumps(deny(
                f"[SECRETS DETECTION] BLOCKED: Command may commit '{sensitive}'. "
                f"Never commit secrets. Remove sensitive files from staging first."
            )))
            return

    # =========================================================================
    # GATE 3: Skill Creation Gate - Warn (not block) on skill writes
    # =========================================================================
    if tool_name in ("Write", "Edit"):
        file_path = tool_input.get("file_path", "")
        if "/skills/" in file_path and file_path.endswith(".md"):
            # Allow but inject reminder (soft gate - the skill-creation-best-practices handles approval)
            print(json.dumps(allow(
                "[SKILL CREATION] Remember: skill-creation-best-practices PARAMOUNT. "
                "Ensure AskUserQuestion approval before creating skills."
            )))
            return

    # =========================================================================
    # GATE 4: Context Gate - Block at 80% threshold
    # =========================================================================
    estimated_tokens = estimate_tokens_from_jsonl(transcript_path)
    usage_percent = (estimated_tokens / CONTEXT_MAX) * 100

    state = get_state()
    if state.get("session_id") != session_id:
        state = {"warning_issued": False, "session_id": session_id}
        save_state(state)

    # CRITICAL threshold (80%) - BLOCK
    if estimated_tokens >= CONTEXT_CRITICAL:
        print(json.dumps(deny(
            f"[CONTEXT GATE - {usage_percent:.0f}%] "
            f"Estimated {estimated_tokens:,} tokens. "
            f"HALT: Use AskUserQuestion for user choice: "
            f"compact, serialize+fresh, push through, or checkpoint."
        )))
        return

    # WARNING threshold (70%) - Allow but warn once
    if estimated_tokens >= CONTEXT_WARNING and not state.get("warning_issued"):
        state["warning_issued"] = True
        save_state(state)
        print(json.dumps(allow(
            f"[CONTEXT GATE - {usage_percent:.0f}%] "
            f"Approaching limit ({estimated_tokens:,}/{CONTEXT_MAX:,}). "
            f"Consider /compact or session transition."
        )))
        return

    # All gates passed - allow
    print(json.dumps(allow()))


if __name__ == "__main__":
    main()
