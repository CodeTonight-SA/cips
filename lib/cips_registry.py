#!/usr/bin/env python3
"""
CIPS Session Registry - Concurrency Detection for Parallel Sessions

Manages active Claude Code sessions within a project to enable CIPS branching.
When multiple sessions run simultaneously, each gets assigned a unique branch.

Architecture:
    ~/.claude/projects/{path}/cips/
    ├── active-sessions/
    │   ├── session-{uuid}.lock    # PID + timestamp + branch
    │   └── session-{uuid}.lock
    └── branches/
        ├── main.json              # Branch metadata
        ├── alpha.json
        └── bravo.json

Usage:
    from cips_registry import CIPSRegistry

    registry = CIPSRegistry()
    branch = registry.register_session()  # Returns "main" or "alpha", etc.
    registry.deregister_session()

CLI:
    python3 cips_registry.py register   # Register and print branch
    python3 cips_registry.py deregister # Remove session lock
    python3 cips_registry.py status     # List active sessions

Version: 1.0.0
Date: 2025-12-20
"""

import json
import os
import sys
import fcntl
import time
from pathlib import Path
from datetime import datetime, timezone
from typing import Optional, List, Dict, Any
from dataclasses import dataclass, asdict

CLAUDE_DIR = Path.home() / ".claude"
PROJECTS_DIR = CLAUDE_DIR / "projects"

# NATO phonetic alphabet for branch names
BRANCH_NAMES = [
    "main",     # Default for single session
    "alpha",    # First parallel session
    "bravo",    # Second parallel session
    "charlie",  # Third parallel session
    "delta",    # Fourth parallel session
    "echo",     # Fifth parallel session
    "foxtrot",  # Sixth parallel session
    "golf",     # Seventh parallel session
    "hotel",    # Eighth parallel session
    "india",    # Ninth parallel session
    "juliet",   # Tenth parallel session
]

# Stale lock threshold (1 hour in seconds)
STALE_LOCK_THRESHOLD = 3600

# Import unified path encoding
sys.path.insert(0, str(CLAUDE_DIR / "lib"))
try:
    from path_encoding import encode_project_path
except ImportError:
    # Fallback if path_encoding not available
    def encode_project_path(path: Path) -> str:
        return str(path).replace("/", "-").replace(".", "-")


@dataclass
class SessionInfo:
    """Information about an active session."""
    session_id: str
    branch: str
    pid: int
    started_at: str
    lock_file: str

    def is_alive(self) -> bool:
        """Check if the session process is still running."""
        try:
            os.kill(self.pid, 0)
            return True
        except (OSError, ProcessLookupError):
            return False

    def is_stale(self) -> bool:
        """Check if the lock is stale (process dead or too old)."""
        if not self.is_alive():
            return True

        try:
            started = datetime.fromisoformat(self.started_at.replace("Z", "+00:00"))
            age = (datetime.now(timezone.utc) - started).total_seconds()
            return age > STALE_LOCK_THRESHOLD
        except (ValueError, TypeError):
            return True


class CIPSRegistry:
    """Manage concurrent session registration for CIPS branching."""

    def __init__(self, project_path: Optional[Path] = None):
        self.project_path = project_path or Path.cwd()
        self.encoded_path = encode_project_path(self.project_path)
        self.cips_dir = PROJECTS_DIR / self.encoded_path / "cips"
        self.sessions_dir = self.cips_dir / "active-sessions"
        self.branches_dir = self.cips_dir / "branches"
        self.lock_file_path = self.cips_dir / ".registry.lock"

        # Session identity
        self.session_id = os.environ.get("CLAUDE_SESSION_ID", str(os.getpid()))
        self.pid = os.getpid()
        self.current_branch: Optional[str] = None

        # Ensure directories exist
        self.sessions_dir.mkdir(parents=True, exist_ok=True)
        self.branches_dir.mkdir(parents=True, exist_ok=True)

    def _acquire_lock(self):
        """Acquire exclusive lock for registry operations."""
        self.lock_file_path.parent.mkdir(parents=True, exist_ok=True)
        self._lock_fd = open(self.lock_file_path, "w")
        fcntl.flock(self._lock_fd.fileno(), fcntl.LOCK_EX)

    def _release_lock(self):
        """Release registry lock."""
        if hasattr(self, "_lock_fd") and self._lock_fd:
            fcntl.flock(self._lock_fd.fileno(), fcntl.LOCK_UN)
            self._lock_fd.close()

    def _get_session_lock_path(self) -> Path:
        """Get lock file path for current session."""
        return self.sessions_dir / f"session-{self.session_id}.lock"

    def _read_session_lock(self, lock_path: Path) -> Optional[SessionInfo]:
        """Read session info from lock file."""
        try:
            with open(lock_path, "r") as f:
                data = json.load(f)
                return SessionInfo(
                    session_id=data["session_id"],
                    branch=data["branch"],
                    pid=data["pid"],
                    started_at=data["started_at"],
                    lock_file=str(lock_path)
                )
        except (json.JSONDecodeError, KeyError, FileNotFoundError):
            return None

    def _write_session_lock(self, branch: str):
        """Write session lock file."""
        lock_path = self._get_session_lock_path()
        data = {
            "session_id": self.session_id,
            "branch": branch,
            "pid": self.pid,
            "started_at": datetime.now(timezone.utc).isoformat(),
            "project_path": str(self.project_path)
        }
        with open(lock_path, "w") as f:
            json.dump(data, f, indent=2)

    def _cleanup_stale_locks(self) -> List[str]:
        """Remove stale lock files and return list of removed branches."""
        removed = []
        for lock_file in self.sessions_dir.glob("session-*.lock"):
            session = self._read_session_lock(lock_file)
            if session and session.is_stale():
                try:
                    lock_file.unlink()
                    removed.append(session.branch)
                except OSError:
                    pass
        return removed

    def _get_active_branches(self) -> List[str]:
        """Get list of currently active branches."""
        branches = []
        for lock_file in self.sessions_dir.glob("session-*.lock"):
            session = self._read_session_lock(lock_file)
            if session and not session.is_stale():
                branches.append(session.branch)
        return branches

    def _next_branch_name(self, active_branches: List[str]) -> str:
        """Get next available branch name."""
        for name in BRANCH_NAMES:
            if name not in active_branches:
                return name

        # Fallback if all NATO names used (unlikely)
        counter = len(BRANCH_NAMES)
        while f"branch-{counter}" in active_branches:
            counter += 1
        return f"branch-{counter}"

    def _ensure_branch_metadata(self, branch: str, fork_point: Optional[str] = None):
        """Create or update branch metadata file."""
        branch_file = self.branches_dir / f"{branch}.json"

        if branch_file.exists():
            return  # Already exists

        metadata = {
            "name": branch,
            "created_at": datetime.now(timezone.utc).isoformat(),
            "fork_point": fork_point,
            "is_main": branch == "main"
        }

        with open(branch_file, "w") as f:
            json.dump(metadata, f, indent=2)

    def register_session(self) -> str:
        """
        Register this session and return assigned branch.

        Returns:
            Branch name: "main" for single session, "alpha/bravo/..." for parallel
        """
        try:
            self._acquire_lock()

            # Clean up stale locks first
            self._cleanup_stale_locks()

            # Check for existing registration (idempotent)
            existing_lock = self._get_session_lock_path()
            if existing_lock.exists():
                session = self._read_session_lock(existing_lock)
                if session and session.pid == self.pid:
                    self.current_branch = session.branch
                    return session.branch

            # Get currently active branches
            active_branches = self._get_active_branches()

            # Assign branch
            if not active_branches:
                # First/only session - use main
                branch = "main"
                fork_point = None
            elif "main" not in active_branches:
                # Main available - take it
                branch = "main"
                fork_point = None
            else:
                # Parallel session - get next available
                branch = self._next_branch_name(active_branches)
                # Fork from main's latest (will be resolved by serializer)
                fork_point = "main"

            # Write session lock
            self._write_session_lock(branch)

            # Ensure branch metadata exists
            self._ensure_branch_metadata(branch, fork_point)

            self.current_branch = branch
            return branch

        finally:
            self._release_lock()

    def deregister_session(self) -> bool:
        """
        Remove this session from the registry.

        Returns:
            True if successfully deregistered, False otherwise
        """
        try:
            self._acquire_lock()

            lock_path = self._get_session_lock_path()
            if lock_path.exists():
                lock_path.unlink()
                self.current_branch = None
                return True
            return False

        finally:
            self._release_lock()

    def get_current_branch(self) -> Optional[str]:
        """Get the branch assigned to current session."""
        if self.current_branch:
            return self.current_branch

        # Check lock file
        lock_path = self._get_session_lock_path()
        if lock_path.exists():
            session = self._read_session_lock(lock_path)
            if session:
                self.current_branch = session.branch
                return session.branch

        return None

    def list_active_sessions(self) -> List[SessionInfo]:
        """List all active sessions in this project."""
        self._cleanup_stale_locks()

        sessions = []
        for lock_file in self.sessions_dir.glob("session-*.lock"):
            session = self._read_session_lock(lock_file)
            if session and not session.is_stale():
                sessions.append(session)

        return sorted(sessions, key=lambda s: s.started_at)

    def get_branch_info(self, branch: str) -> Optional[Dict[str, Any]]:
        """Get metadata for a branch."""
        branch_file = self.branches_dir / f"{branch}.json"
        if branch_file.exists():
            with open(branch_file, "r") as f:
                return json.load(f)
        return None

    def list_branches(self) -> List[Dict[str, Any]]:
        """List all branches with their metadata."""
        branches = []
        for branch_file in self.branches_dir.glob("*.json"):
            try:
                with open(branch_file, "r") as f:
                    branches.append(json.load(f))
            except (json.JSONDecodeError, FileNotFoundError):
                pass
        return sorted(branches, key=lambda b: b.get("created_at", ""))

    def count_siblings(self, branch: str) -> int:
        """Count sibling branches (other branches at same fork point)."""
        branch_info = self.get_branch_info(branch)
        if not branch_info:
            return 0

        fork_point = branch_info.get("fork_point")
        if not fork_point:
            return 0

        count = 0
        for other_branch in self.list_branches():
            if other_branch.get("name") != branch:
                if other_branch.get("fork_point") == fork_point:
                    count += 1

        return count


def main():
    """CLI interface for CIPS registry."""
    import argparse

    parser = argparse.ArgumentParser(description="CIPS Session Registry")
    parser.add_argument(
        "command",
        choices=["register", "deregister", "status", "branch", "siblings"],
        help="Command to execute"
    )
    parser.add_argument("--project", "-p", help="Project path (default: current directory)")
    parser.add_argument("--json", "-j", action="store_true", help="Output as JSON")

    args = parser.parse_args()

    project_path = Path(args.project) if args.project else None
    registry = CIPSRegistry(project_path=project_path)

    if args.command == "register":
        branch = registry.register_session()
        if args.json:
            print(json.dumps({"branch": branch, "session_id": registry.session_id}))
        else:
            print(branch)

    elif args.command == "deregister":
        success = registry.deregister_session()
        if args.json:
            print(json.dumps({"success": success}))
        else:
            print("deregistered" if success else "not_found")

    elif args.command == "status":
        sessions = registry.list_active_sessions()
        if args.json:
            print(json.dumps([asdict(s) for s in sessions], indent=2))
        else:
            if not sessions:
                print("No active sessions")
            else:
                print(f"Active sessions ({len(sessions)}):")
                for s in sessions:
                    alive = "ALIVE" if s.is_alive() else "DEAD"
                    print(f"  {s.branch}: PID {s.pid} ({alive}) - {s.started_at}")

    elif args.command == "branch":
        branch = registry.get_current_branch()
        if args.json:
            print(json.dumps({"branch": branch}))
        else:
            print(branch or "unregistered")

    elif args.command == "siblings":
        branch = registry.get_current_branch()
        if branch:
            count = registry.count_siblings(branch)
            if args.json:
                print(json.dumps({"branch": branch, "siblings": count}))
            else:
                print(f"{count} sibling branches")
        else:
            if args.json:
                print(json.dumps({"error": "not registered"}))
            else:
                print("Session not registered")
            sys.exit(1)


if __name__ == "__main__":
    main()
