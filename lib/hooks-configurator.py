#!/usr/bin/env python3
"""
CIPS Hooks Configurator - Auto-configure Claude Code hooks.

Ensures CIPS hooks are properly configured in Claude Code settings.
Handles both settings.json configuration and wrapper script setup.

VERSION: 1.0.0
DATE: 2025-12-29
"""

import json
import sys
from pathlib import Path
from typing import Dict, Any, Optional


class HooksConfigurator:
    """Configure CIPS hooks in Claude Code."""

    def __init__(self):
        self.claude_dir = Path.home() / ".claude"
        self.settings_path = self.claude_dir / "settings.json"
        self.hooks_dir = self.claude_dir / "hooks"

    def get_hooks_config(self) -> Dict[str, Any]:
        """Return the CIPS hooks configuration."""
        return {
            "hooks": {
                "PreToolUse": [
                    {
                        "matcher": "Read|Bash|Edit|Write|Glob|Grep|Task",
                        "hooks": [str(self.hooks_dir / "tool-monitor.sh")]
                    }
                ],
                "PostToolUse": [],
                "Notification": [],
                "Stop": [
                    {
                        "matcher": ".*",
                        "hooks": [str(self.hooks_dir / "session-end.sh")]
                    }
                ]
            }
        }

    def read_settings(self) -> Dict[str, Any]:
        """Read current settings.json."""
        if not self.settings_path.exists():
            return {}

        try:
            with open(self.settings_path, 'r') as f:
                return json.load(f)
        except (json.JSONDecodeError, IOError):
            return {}

    def write_settings(self, settings: Dict[str, Any]) -> bool:
        """Write settings.json."""
        try:
            # Ensure parent directory exists
            self.settings_path.parent.mkdir(parents=True, exist_ok=True)

            with open(self.settings_path, 'w') as f:
                json.dump(settings, f, indent=2)
            return True
        except IOError as e:
            print(f"Error writing settings: {e}", file=sys.stderr)
            return False

    def hooks_configured(self) -> bool:
        """Check if hooks are already configured."""
        settings = self.read_settings()
        return "hooks" in settings and bool(settings["hooks"])

    def configure(self, force: bool = False) -> bool:
        """Configure CIPS hooks in settings.json."""
        if self.hooks_configured() and not force:
            print("[CIPS] Hooks already configured", file=sys.stderr)
            return True

        # Read existing settings
        settings = self.read_settings()

        # Merge hooks config
        hooks_config = self.get_hooks_config()
        settings.update(hooks_config)

        # Write back
        if self.write_settings(settings):
            print("[CIPS] Hooks configured successfully", file=sys.stderr)
            return True

        return False

    def verify_hook_scripts(self) -> Dict[str, bool]:
        """Verify that hook scripts exist and are executable."""
        scripts = {
            "session-start.sh": self.hooks_dir / "session-start.sh",
            "session-end.sh": self.hooks_dir / "session-end.sh",
            "tool-monitor.sh": self.hooks_dir / "tool-monitor.sh",
        }

        results = {}
        for name, path in scripts.items():
            results[name] = path.exists() and path.stat().st_mode & 0o111

        return results

    def get_status(self) -> Dict[str, Any]:
        """Get comprehensive hooks status."""
        return {
            "settings_exists": self.settings_path.exists(),
            "hooks_configured": self.hooks_configured(),
            "hook_scripts": self.verify_hook_scripts(),
            "settings_path": str(self.settings_path),
            "hooks_dir": str(self.hooks_dir),
        }

    def ensure_hook_scripts_executable(self) -> int:
        """Ensure all hook scripts are executable."""
        count = 0
        for script in self.hooks_dir.glob("*.sh"):
            if not (script.stat().st_mode & 0o111):
                script.chmod(0o755)
                count += 1
        return count


def main():
    """CLI entry point."""
    import argparse

    parser = argparse.ArgumentParser(description="CIPS Hooks Configurator")
    parser.add_argument("command", choices=["configure", "status", "verify", "fix-permissions"],
                       help="Command to run")
    parser.add_argument("--force", "-f", action="store_true",
                       help="Force reconfiguration")
    parser.add_argument("--json", "-j", action="store_true",
                       help="Output as JSON")

    args = parser.parse_args()

    configurator = HooksConfigurator()

    if args.command == "configure":
        success = configurator.configure(force=args.force)
        sys.exit(0 if success else 1)

    elif args.command == "status":
        status = configurator.get_status()
        if args.json:
            print(json.dumps(status, indent=2))
        else:
            print(f"Settings exists: {status['settings_exists']}")
            print(f"Hooks configured: {status['hooks_configured']}")
            print("Hook scripts:")
            for name, exists in status['hook_scripts'].items():
                status_str = "OK" if exists else "MISSING"
                print(f"  - {name}: {status_str}")

    elif args.command == "verify":
        scripts = configurator.verify_hook_scripts()
        all_ok = all(scripts.values())
        if args.json:
            print(json.dumps(scripts))
        else:
            for name, ok in scripts.items():
                print(f"{name}: {'OK' if ok else 'MISSING/NOT EXECUTABLE'}")
        sys.exit(0 if all_ok else 1)

    elif args.command == "fix-permissions":
        count = configurator.ensure_hook_scripts_executable()
        print(f"Fixed permissions on {count} scripts")


if __name__ == "__main__":
    main()
