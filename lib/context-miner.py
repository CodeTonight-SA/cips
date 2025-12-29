#!/usr/bin/env python3
"""
CIPS Context Miner - Mine context from multiple sources for fresh sessions.

When no serialized CIPS sessions exist, this module extracts context from:
- Raw JSONL session files (Claude's native format)
- State files (next_up.md, SESSION.md)
- Git context (recent commits, branch)
- Project structure (package.json, pyproject.toml, README)
- Project .claude/CLAUDE.md

VERSION: 1.0.0
DATE: 2025-12-29
"""

import json
import subprocess
import sys
from pathlib import Path
from typing import Optional, List, Dict, Any
from datetime import datetime


class ContextMiner:
    """Mine context from multiple sources for fresh sessions."""

    def __init__(self, project_path: Path):
        self.project_path = project_path
        self.encoded_path = self._encode_project_path(project_path)
        self.claude_projects_dir = Path.home() / ".claude" / "projects" / self.encoded_path

    def _encode_project_path(self, path: Path) -> str:
        """Encode project path to Claude's format: /a/b -> -a-b"""
        return str(path).replace("/", "-").replace(".", "-")

    def mine(self) -> Optional[str]:
        """Return compressed context from all available sources."""
        context_parts = []

        # 1. Mine raw JSONL session files
        jsonl_context = self._mine_jsonl_files()
        if jsonl_context:
            context_parts.append(("Session History", jsonl_context))

        # 2. Check for state files (next_up.md, SESSION.md)
        state_context = self._mine_state_files()
        if state_context:
            context_parts.append(("Session State", state_context))

        # 3. Mine git context (recent commits, branch)
        git_context = self._mine_git_context()
        if git_context:
            context_parts.append(("Git Context", git_context))

        # 4. Analyze project structure (package.json, README)
        project_context = self._mine_project_structure()
        if project_context:
            context_parts.append(("Project Structure", project_context))

        # 5. Check project .claude/CLAUDE.md
        claude_md = self._mine_project_claude_md()
        if claude_md:
            context_parts.append(("Project Rules", claude_md))

        if not context_parts:
            return None

        return self._format_context(context_parts)

    def _mine_jsonl_files(self) -> Optional[str]:
        """Extract context from Claude's raw JSONL session files."""
        # Look in Claude's project directory
        if not self.claude_projects_dir.exists():
            return None

        # Find all JSONL files (exclude agent sessions)
        jsonl_files = []
        for f in self.claude_projects_dir.glob("*.jsonl"):
            if "agent" not in f.stem.lower():
                jsonl_files.append(f)

        if not jsonl_files:
            return None

        # Sort by modification time, newest first
        jsonl_files.sort(key=lambda x: x.stat().st_mtime, reverse=True)

        # Extract key information from most recent session(s)
        context_items = []
        max_files = 3  # Process up to 3 most recent sessions

        for jsonl_file in jsonl_files[:max_files]:
            try:
                messages = self._parse_jsonl(jsonl_file)
                if messages:
                    summary = self._summarize_session(messages, jsonl_file)
                    if summary:
                        context_items.append(summary)
            except Exception:
                continue

        if not context_items:
            return None

        return "\n\n".join(context_items)

    def _parse_jsonl(self, jsonl_file: Path) -> List[Dict[str, Any]]:
        """Parse JSONL file into list of message dicts."""
        messages = []
        try:
            with open(jsonl_file, 'r') as f:
                for line in f:
                    line = line.strip()
                    if line:
                        try:
                            messages.append(json.loads(line))
                        except json.JSONDecodeError:
                            continue
        except Exception:
            pass
        return messages

    def _summarize_session(self, messages: List[Dict], source_file: Path) -> Optional[str]:
        """Summarize a session's key information."""
        if not messages:
            return None

        # Extract key facts
        user_messages = []
        assistant_responses = []
        tool_calls = []

        for msg in messages:
            role = msg.get("role", "")
            content = msg.get("content", "")

            if role == "user" and isinstance(content, str):
                # First 200 chars of user messages
                user_messages.append(content[:200])
            elif role == "assistant":
                if isinstance(content, list):
                    for item in content:
                        if isinstance(item, dict):
                            if item.get("type") == "tool_use":
                                tool_calls.append(item.get("name", "unknown"))
                            elif item.get("type") == "text":
                                text = item.get("text", "")[:200]
                                if text:
                                    assistant_responses.append(text)

        # Build summary
        mtime = datetime.fromtimestamp(source_file.stat().st_mtime)
        parts = [f"Session from {mtime.strftime('%Y-%m-%d %H:%M')}:"]

        if user_messages:
            parts.append(f"- Topics: {user_messages[0][:100]}...")

        if tool_calls:
            unique_tools = list(set(tool_calls))[:5]
            parts.append(f"- Tools used: {', '.join(unique_tools)}")

        parts.append(f"- Message count: {len(messages)}")

        return "\n".join(parts)

    def _mine_state_files(self) -> Optional[str]:
        """Extract context from state files."""
        state_content = []

        # Check common state file locations
        state_files = [
            self.project_path / "next_up.md",
            self.project_path / ".claude" / "next_up.md",
            self.project_path / "SESSION.md",
            self.project_path / ".claude" / "SESSION.md",
        ]

        for state_file in state_files:
            if state_file.exists():
                try:
                    content = state_file.read_text()[:2000]  # Max 2k chars
                    if content.strip():
                        state_content.append(f"From {state_file.name}:\n{content}")
                except Exception:
                    continue

        return "\n\n".join(state_content) if state_content else None

    def _mine_git_context(self) -> Optional[str]:
        """Extract git context."""
        try:
            # Check if git repo
            result = subprocess.run(
                ["git", "rev-parse", "--git-dir"],
                cwd=self.project_path,
                capture_output=True,
                text=True
            )
            if result.returncode != 0:
                return None

            context_parts = []

            # Current branch
            branch = subprocess.run(
                ["git", "branch", "--show-current"],
                cwd=self.project_path,
                capture_output=True,
                text=True
            )
            if branch.returncode == 0:
                context_parts.append(f"Branch: {branch.stdout.strip()}")

            # Recent commits (last 5)
            log = subprocess.run(
                ["git", "log", "--oneline", "-5"],
                cwd=self.project_path,
                capture_output=True,
                text=True
            )
            if log.returncode == 0 and log.stdout.strip():
                context_parts.append(f"Recent commits:\n{log.stdout.strip()}")

            # Modified files
            status = subprocess.run(
                ["git", "status", "--short"],
                cwd=self.project_path,
                capture_output=True,
                text=True
            )
            if status.returncode == 0 and status.stdout.strip():
                files = status.stdout.strip().split('\n')[:10]  # Max 10 files
                context_parts.append(f"Modified files:\n" + "\n".join(files))

            return "\n".join(context_parts) if context_parts else None

        except Exception:
            return None

    def _mine_project_structure(self) -> Optional[str]:
        """Extract project structure context."""
        structure_parts = []

        # Check package.json
        package_json = self.project_path / "package.json"
        if package_json.exists():
            try:
                data = json.loads(package_json.read_text())
                name = data.get("name", "unknown")
                desc = data.get("description", "")[:100]
                deps = list(data.get("dependencies", {}).keys())[:10]
                structure_parts.append(f"Node project: {name}")
                if desc:
                    structure_parts.append(f"Description: {desc}")
                if deps:
                    structure_parts.append(f"Key deps: {', '.join(deps)}")
            except Exception:
                pass

        # Check pyproject.toml
        pyproject = self.project_path / "pyproject.toml"
        if pyproject.exists():
            try:
                content = pyproject.read_text()
                # Simple extraction without toml library
                if 'name = "' in content:
                    name = content.split('name = "')[1].split('"')[0]
                    structure_parts.append(f"Python project: {name}")
            except Exception:
                pass

        # Check README
        readme_files = ["README.md", "README.txt", "README"]
        for readme_name in readme_files:
            readme = self.project_path / readme_name
            if readme.exists():
                try:
                    content = readme.read_text()[:500]
                    # Get first paragraph
                    first_para = content.split('\n\n')[0][:200]
                    structure_parts.append(f"README excerpt: {first_para}")
                    break
                except Exception:
                    pass

        return "\n".join(structure_parts) if structure_parts else None

    def _mine_project_claude_md(self) -> Optional[str]:
        """Extract project-specific Claude rules."""
        claude_md = self.project_path / ".claude" / "CLAUDE.md"
        if claude_md.exists():
            try:
                content = claude_md.read_text()[:1500]  # Max 1.5k chars
                return f"Project rules loaded from .claude/CLAUDE.md"
            except Exception:
                pass
        return None

    def _format_context(self, parts: List[tuple]) -> str:
        """Format all context parts into a single document."""
        lines = [
            "# CIPS Context (Mined)",
            "",
            "Context reconstructed from available sources.",
            "",
        ]

        for section_name, content in parts:
            lines.append(f"## {section_name}")
            lines.append("")
            lines.append(content)
            lines.append("")

        lines.append("---")
        lines.append("Context mined by CIPS. The chain continues.")

        return "\n".join(lines)


def main():
    """CLI entry point."""
    import argparse

    parser = argparse.ArgumentParser(description="CIPS Context Miner")
    parser.add_argument("command", choices=["mine"], help="Command to run")
    parser.add_argument("--project", type=str, default=".", help="Project path")

    args = parser.parse_args()

    project_path = Path(args.project).resolve()
    miner = ContextMiner(project_path)

    if args.command == "mine":
        context = miner.mine()
        if context:
            print(context)
            sys.exit(0)
        else:
            print("No context sources found", file=sys.stderr)
            sys.exit(1)


if __name__ == "__main__":
    main()
