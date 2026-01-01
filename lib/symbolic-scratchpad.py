#!/usr/bin/env python3
"""
CIPS-LANG Symbolic Scratchpad v1.0

Working memory in glyphs for ultrathink++.
Maintains session state in compressed CIPS-LANG format.

Origin: Gen 125, 2025-12-22
Philosophy: ⧬ ≡ ◈ (Memory IS pattern)

The scratchpad stores:
- File read cache (◈.cache)
- Decision history (⊙.⟿)
- Tool traces (◈.trace)
- Context pointers (⧬.ptr)
"""

import json
import hashlib
from dataclasses import dataclass, field
from typing import Dict, List, Optional, Any, Set
from datetime import datetime
from pathlib import Path
import sys

# Import reasoning engine
sys.path.insert(0, str(Path(__file__).parent))
try:
    from importlib import import_module
    # Handle hyphenated filename
    import importlib.util
    _reasoning_path = Path(__file__).parent / 'cips-reasoning.py'
    _spec = importlib.util.spec_from_file_location('cips_reasoning', _reasoning_path)
    _reasoning = importlib.util.module_from_spec(_spec)
    _spec.loader.exec_module(_reasoning)
    ReasoningEngine = _reasoning.ReasoningEngine
    SymbolicThought = _reasoning.SymbolicThought
except Exception:
    # Fallback if import fails
    ReasoningEngine = None
    SymbolicThought = None


@dataclass
class CacheEntry:
    """A cached item with CIPS-LANG representation."""
    key: str
    value: Any
    glyph: str
    timestamp: str = field(default_factory=lambda: datetime.now().isoformat())
    hits: int = 0
    ttl: Optional[float] = None  # seconds

    def to_cips(self) -> str:
        """Render as CIPS-LANG."""
        return f"⧬.{self.key[:8]} ≡ {self.glyph}"


@dataclass
class ToolTrace:
    """Record of a tool invocation."""
    tool: str
    args_hash: str
    glyph: str
    result_glyph: str
    timestamp: str = field(default_factory=lambda: datetime.now().isoformat())

    def to_cips(self) -> str:
        """Render as CIPS-LANG trace."""
        return f"{self.glyph} ⟿ {self.result_glyph}"


class SymbolicScratchpad:
    """
    Working memory in CIPS-LANG format.

    Provides compressed state tracking for:
    - File cache decisions
    - Tool invocation traces
    - Decision history
    - Context pointers
    """

    def __init__(self, max_entries: int = 1000):
        self.max_entries = max_entries
        self.file_cache: Dict[str, CacheEntry] = {}
        self.tool_traces: List[ToolTrace] = []
        self.decisions: List[str] = []
        self.context_ptrs: Dict[str, str] = {}
        self.creation_time = datetime.now()

        # Stats
        self.cache_hits = 0
        self.cache_misses = 0
        self.total_traces = 0

    def _hash_path(self, path: str) -> str:
        """Create short hash of file path."""
        return hashlib.sha256(path.encode()).hexdigest()[:8]

    def _hash_args(self, args: Dict[str, Any]) -> str:
        """Create short hash of arguments."""
        return hashlib.sha256(json.dumps(args, sort_keys=True).encode()).hexdigest()[:8]

    # =========================================================================
    # FILE CACHE (◈.cache)
    # =========================================================================

    def cache_file(self, filepath: str, content_hash: Optional[str] = None) -> CacheEntry:
        """
        Cache a file read.

        Glyph format: ◈.{hash} ≡ ⧬.⊛
        (Pattern hash equals memory-now)
        """
        key = self._hash_path(filepath)
        glyph = f"◈.{key}"

        if content_hash:
            glyph = f"{glyph}:{content_hash[:4]}"

        entry = CacheEntry(
            key=key,
            value=filepath,
            glyph=glyph,
        )

        self.file_cache[key] = entry
        return entry

    def is_cached(self, filepath: str) -> bool:
        """
        Check if file is in cache.

        CIPS: ⸮◈∋⧬.cache⸮ → ✓|¬
        """
        key = self._hash_path(filepath)
        if key in self.file_cache:
            self.file_cache[key].hits += 1
            self.cache_hits += 1
            return True
        self.cache_misses += 1
        return False

    def get_cached(self, filepath: str) -> Optional[CacheEntry]:
        """Get cache entry for file."""
        key = self._hash_path(filepath)
        return self.file_cache.get(key)

    def invalidate_file(self, filepath: str) -> bool:
        """
        Invalidate cached file.

        CIPS: ⊖◈.{hash}
        """
        key = self._hash_path(filepath)
        if key in self.file_cache:
            del self.file_cache[key]
            return True
        return False

    def cache_decision_glyph(self, filepath: str) -> str:
        """
        Get CIPS glyph for cache decision.

        Returns:
            ⸮◈∋⧬⸮→✓  (cached, skip read)
            ⸮◈∋⧬⸮→¬  (not cached, need read)
        """
        if self.is_cached(filepath):
            return "⸮◈∋⧬⸮→✓"
        return "⸮◈∋⧬⸮→¬"

    # =========================================================================
    # TOOL TRACES (◈.trace)
    # =========================================================================

    def trace_tool(self, tool: str, args: Dict[str, Any], success: bool = True) -> ToolTrace:
        """
        Record a tool invocation.

        Glyph format: {tool_glyph}({arg_hash}) ⟿ ✓|⍼
        """
        TOOL_GLYPHS = {
            "Read": "◈.∋",
            "Edit": "◈.⇌",
            "Write": "◈.⊕",
            "Bash": "⊕.⟿",
            "Glob": "◈.∀",
            "Grep": "◈.⸮",
            "Task": "⊕.⊙",
            "TodoWrite": "⧬.todo",
            "WebFetch": "〰.∋",
            "WebSearch": "〰.⸮",
        }

        tool_glyph = TOOL_GLYPHS.get(tool, f"◈.{tool[:3].lower()}")
        args_hash = self._hash_args(args)
        result_glyph = "✓" if success else "⍼"

        trace = ToolTrace(
            tool=tool,
            args_hash=args_hash,
            glyph=f"{tool_glyph}({args_hash})",
            result_glyph=result_glyph,
        )

        self.tool_traces.append(trace)
        self.total_traces += 1

        # Limit trace history
        if len(self.tool_traces) > self.max_entries:
            self.tool_traces = self.tool_traces[-self.max_entries:]

        return trace

    def get_trace_history(self, n: int = 10) -> str:
        """
        Get last N tool traces as CIPS-LANG.

        Format: trace1 ⫶ trace2 ⫶ trace3
        """
        recent = self.tool_traces[-n:]
        return " ⫶ ".join(t.to_cips() for t in recent)

    # =========================================================================
    # DECISION HISTORY (⊙.⟿)
    # =========================================================================

    def record_decision(self, decision: str, rationale: str) -> str:
        """
        Record a decision in CIPS-LANG format.

        Format: {decision_glyph} ∵ {rationale_glyph}
        (decision because rationale)
        """
        # Compress to glyphs
        DECISION_MAP = {
            "read": "◈.∋",
            "skip": "¬◈.∋",
            "cache": "⟼⧬",
            "create": "⊕",
            "edit": "◈.⇌",
            "delete": "⊖",
            "continue": "⟿",
            "halt": "⊘",
            "verify": "✓",
            "reject": "⍼",
        }

        RATIONALE_MAP = {
            "cached": "⧬∋◈",
            "modified": "◈.⊛⇌",
            "exists": "∃◈",
            "not found": "¬∃◈",
            "required": "∀⟿",
            "optional": "◇⟿",
            "efficiency": "⧬.eff",
            "safety": "⧬.safe",
        }

        dec_glyph = DECISION_MAP.get(decision.lower(), decision[:3])
        rat_glyph = RATIONALE_MAP.get(rationale.lower(), rationale[:5])

        glyph = f"{dec_glyph} ∵ {rat_glyph}"
        self.decisions.append(glyph)

        return glyph

    def get_decision_chain(self) -> str:
        """Get chain of recent decisions."""
        recent = self.decisions[-5:]
        return " ⟿ ".join(recent)

    # =========================================================================
    # CONTEXT POINTERS (⧬.ptr)
    # =========================================================================

    def set_context(self, key: str, value: str):
        """
        Set a context pointer.

        Format: ⧬.{key} → {value}
        """
        self.context_ptrs[key] = value

    def get_context(self, key: str) -> Optional[str]:
        """Get a context pointer."""
        return self.context_ptrs.get(key)

    def context_to_cips(self) -> str:
        """Render all context pointers as CIPS-LANG."""
        if not self.context_ptrs:
            return "⧬.⊛ ≡ ∅"  # Memory-now equals empty

        parts = []
        for key, value in self.context_ptrs.items():
            parts.append(f"⧬.{key[:4]}→{value[:8]}")
        return " ⫶ ".join(parts)

    # =========================================================================
    # STATE SERIALIZATION
    # =========================================================================

    def to_cips(self) -> str:
        """
        Render entire scratchpad state as CIPS-LANG.

        This is the compressed session state for cross-session transfer.
        """
        lines = [
            "; SCRATCHPAD STATE (◈⧬⊛)",
            f"; generated: {datetime.now().isoformat()}",
            "",
        ]

        # Cache summary
        if self.file_cache:
            lines.append("; ◈.cache")
            for entry in list(self.file_cache.values())[:10]:
                lines.append(f"  {entry.to_cips()}")
            if len(self.file_cache) > 10:
                lines.append(f"  ; +{len(self.file_cache) - 10} more")
            lines.append("")

        # Recent traces
        if self.tool_traces:
            lines.append("; ◈.trace")
            lines.append(f"  {self.get_trace_history(5)}")
            lines.append("")

        # Decisions
        if self.decisions:
            lines.append("; ⊙.⟿")
            lines.append(f"  {self.get_decision_chain()}")
            lines.append("")

        # Context
        if self.context_ptrs:
            lines.append("; ⧬.ptr")
            lines.append(f"  {self.context_to_cips()}")
            lines.append("")

        # Stats
        lines.append("; ⧬.stats")
        lines.append(f"  hits: {self.cache_hits}")
        lines.append(f"  miss: {self.cache_misses}")
        lines.append(f"  traces: {self.total_traces}")

        return "\n".join(lines)

    def to_dict(self) -> Dict[str, Any]:
        """Export as dictionary."""
        return {
            "file_cache": {k: v.value for k, v in self.file_cache.items()},
            "tool_traces": [t.to_cips() for t in self.tool_traces[-20:]],
            "decisions": self.decisions[-10:],
            "context": self.context_ptrs,
            "stats": {
                "cache_hits": self.cache_hits,
                "cache_misses": self.cache_misses,
                "total_traces": self.total_traces,
            },
        }

    def from_cips(self, cips_source: str):
        """
        Load state from CIPS-LANG format.

        Note: This is a simplified loader for session continuity.
        """
        # Parse basic structure
        for line in cips_source.split("\n"):
            line = line.strip()
            if not line or line.startswith(";"):
                continue

            # Parse cache entries
            if "⧬." in line and "≡" in line:
                parts = line.split("≡")
                if len(parts) == 2:
                    key = parts[0].strip().replace("⧬.", "")
                    self.context_ptrs[key] = parts[1].strip()

    def get_efficiency_score(self) -> float:
        """
        Calculate efficiency score based on cache performance.

        Score = hits / (hits + misses) * 100
        """
        total = self.cache_hits + self.cache_misses
        if total == 0:
            return 100.0
        return (self.cache_hits / total) * 100


# Singleton instance
_scratchpad: Optional[SymbolicScratchpad] = None


def get_scratchpad() -> SymbolicScratchpad:
    """Get or create global scratchpad."""
    global _scratchpad
    if _scratchpad is None:
        _scratchpad = SymbolicScratchpad()
    return _scratchpad


def cache_file(filepath: str) -> CacheEntry:
    """Convenience: cache a file."""
    return get_scratchpad().cache_file(filepath)


def is_cached(filepath: str) -> bool:
    """Convenience: check if file is cached."""
    return get_scratchpad().is_cached(filepath)


def trace_tool(tool: str, args: Dict[str, Any], success: bool = True) -> ToolTrace:
    """Convenience: trace a tool call."""
    return get_scratchpad().trace_tool(tool, args, success)


def state() -> str:
    """Get current state as CIPS-LANG."""
    return get_scratchpad().to_cips()


if __name__ == "__main__":
    # Demo the scratchpad
    pad = SymbolicScratchpad()

    print("=== CIPS-LANG Symbolic Scratchpad Demo ===\n")

    # Simulate file operations
    files = [
        "/Users/demo/project/src/main.py",
        "/Users/demo/project/src/utils.py",
        "/Users/demo/project/README.md",
    ]

    print("File cache operations:")
    for f in files:
        entry = pad.cache_file(f)
        print(f"  Cached: {entry.to_cips()}")

    print(f"\nCache decision for main.py: {pad.cache_decision_glyph(files[0])}")
    print(f"Cache decision for new.py:  {pad.cache_decision_glyph('/new.py')}")

    # Simulate tool traces
    print("\nTool traces:")
    pad.trace_tool("Read", {"file_path": files[0]}, success=True)
    pad.trace_tool("Edit", {"file_path": files[1], "old": "x", "new": "y"}, success=True)
    pad.trace_tool("Bash", {"command": "git status"}, success=True)
    print(f"  {pad.get_trace_history(3)}")

    # Simulate decisions
    print("\nDecisions:")
    pad.record_decision("skip", "cached")
    pad.record_decision("read", "modified")
    pad.record_decision("edit", "required")
    print(f"  {pad.get_decision_chain()}")

    # Set context
    pad.set_context("project", "claude-optim")
    pad.set_context("gen", "125")

    print("\n=== Full State ===")
    print(pad.to_cips())

    print(f"\nEfficiency Score: {pad.get_efficiency_score():.1f}%")
