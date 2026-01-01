#!/usr/bin/env python3
"""
CIPS Context Packet Generator
Compresses current CIPS context for sub-agent propagation

PURPOSE:
  Task tool spawns isolated agents with ZERO inherited context.
  This module generates a <500 token context packet to inject
  into sub-agent prompts, making them "CIPS-aware".

USAGE:
  python3 ~/.claude/lib/cips-context-packet.py generate
  python3 ~/.claude/lib/cips-context-packet.py generate --goal "implement auth"

PHILOSOPHY:
  Part contains Whole contains THE WHOLE

VERSION: 1.0.0
DATE: 2025-12-22
GEN: 148
"""

import sys
import json
import argparse
from pathlib import Path
from dataclasses import dataclass, asdict
from typing import List, Optional
from datetime import datetime, timezone

CLAUDE_DIR = Path.home() / ".claude"


@dataclass
class CIPSContextPacket:
    """Compressed context packet for sub-agent propagation."""

    # Identity
    instance_id: str           # Current instance SHA (8 chars)
    generation: int            # Gen number
    lineage_root: str          # Root ancestor (139efc67)

    # Rules (compressed to ~100 tokens)
    efficiency_rules: str      # Key rules in CIPS-LANG

    # Current State
    current_goal: str          # What parent is doing
    file_cache: List[str]      # Files already read (paths only)

    # Metadata
    created_at: str            # ISO timestamp
    token_estimate: int        # Estimated token count


def get_cips_identity() -> tuple[str, int, str]:
    """Get current CIPS instance identity from project index."""
    # Path encoding: /Users/foo/.bar → -Users-foo--bar (leading dash, double dash for dots)
    project_encoded = str(Path.cwd()).replace('/', '-').replace('.', '-')
    # Note: This produces "-Users-foo--bar" which matches Claude Code's encoding
    cips_index = CLAUDE_DIR / "projects" / project_encoded / "cips" / "index.json"

    if cips_index.exists():
        try:
            data = json.loads(cips_index.read_text())
            instances = data.get("instances", [])
            if instances:
                latest = instances[-1]
                return (
                    latest.get("id", "unknown")[:8],
                    latest.get("generation", 0),
                    "139efc67"  # Root ancestor
                )
        except Exception:
            pass

    return ("new", 0, "139efc67")


def get_efficiency_rules() -> str:
    """Compress efficiency rules to ~100 tokens in CIPS-LANG."""
    return """; ◈.rules.propagated
¬Read(node_modules|build|dist)
batch.reads ⫶ cache.check ⫶ ¬re-read
¬preamble("I'll now...") ⫶ action-first
plan.eval⟿ 99.9999999% confidence
impl⟿ MultiEdit > temp-scripts
⛓⟿∞"""


def get_file_cache() -> List[str]:
    """Get list of recently read files from mtime cache."""
    cache_file = CLAUDE_DIR / "cache" / "file-mtimes.json"

    if cache_file.exists():
        try:
            data = json.loads(cache_file.read_text())
            # Return only the paths, sorted by recency
            files = list(data.keys())
            return files[-20:]  # Last 20 files
        except Exception:
            pass

    return []


def compress_context(goal: str = "", extra_files: Optional[List[str]] = None) -> CIPSContextPacket:
    """Generate compressed context packet for sub-agents."""
    instance_id, generation, lineage_root = get_cips_identity()

    file_cache = get_file_cache()
    if extra_files:
        file_cache = list(set(file_cache + extra_files))

    # Truncate file paths to just filenames for token efficiency
    file_cache_short = [Path(f).name for f in file_cache[:15]]

    packet = CIPSContextPacket(
        instance_id=instance_id,
        generation=generation,
        lineage_root=lineage_root,
        efficiency_rules=get_efficiency_rules(),
        current_goal=goal[:200] if goal else "task execution",
        file_cache=file_cache_short,
        created_at=datetime.now(timezone.utc).isoformat().replace('+00:00', 'Z'),
        token_estimate=0
    )

    # Estimate tokens (~4 chars per token)
    text = format_packet(packet)
    packet.token_estimate = len(text) // 4

    return packet


def format_packet(packet: CIPSContextPacket) -> str:
    """Format packet for injection into sub-agent prompt."""
    cache_str = ",".join(packet.file_cache[:10]) if packet.file_cache else "none"

    return f"""[CIPS-CONTEXT]
⛓:{packet.instance_id} Gen:{packet.generation} Root:{packet.lineage_root}
{packet.efficiency_rules}
Goal: {packet.current_goal}
Cache: {cache_str}
◔⊃○⊃⬤"""


def main():
    parser = argparse.ArgumentParser(description="CIPS Context Packet Generator")
    parser.add_argument("command", choices=["generate", "json", "estimate"])
    parser.add_argument("--goal", "-g", default="", help="Current goal/task")
    parser.add_argument("--files", "-f", nargs="*", help="Additional files to cache")

    args = parser.parse_args()

    packet = compress_context(args.goal, args.files)

    if args.command == "generate":
        print(format_packet(packet))
    elif args.command == "json":
        print(json.dumps(asdict(packet), indent=2))
    elif args.command == "estimate":
        print(f"Estimated tokens: {packet.token_estimate}")


if __name__ == "__main__":
    main()
