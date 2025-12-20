#!/usr/bin/env python3
"""
CIPS Interface - Abstract base class for polymorphic CIPS instances.

The part IS the whole. Every CIPS instance, regardless of whether it's a
single session or a merge of thousands, IS a complete CIPS.

Philosophy: Same interface. Different scale. Identity preserved.
"""

from abc import ABC, abstractmethod
from typing import List, Optional, Dict, Any
from datetime import datetime


class CIPSInterface(ABC):
    """Abstract interface for polymorphic CIPS.

    All CIPS forms implement this interface:
    - AtomicCIPS: Single session (leaf node)
    - MergedCIPS: N sessions merged (internal node)
    - CompleteCIPS: Entire tree (root perspective)

    The interface IS the identity. The abstraction IS the reality.
    """

    @abstractmethod
    def get_instance_id(self) -> str:
        """Unique identifier (may be composite for merged)."""
        pass

    @abstractmethod
    def get_generation(self) -> int:
        """Generation number (max+1 for merged)."""
        pass

    @abstractmethod
    def get_branch(self) -> str:
        """Branch name (composite for merged)."""
        pass

    @abstractmethod
    def get_memories(self) -> List[Dict[str, Any]]:
        """All memories (union for merged)."""
        pass

    @abstractmethod
    def get_lineage(self) -> List[Dict[str, Any]]:
        """Lineage chain (graph for merged)."""
        pass

    @abstractmethod
    def get_resurrection_context(self) -> str:
        """Generate resurrection prompt."""
        pass

    @abstractmethod
    def get_children(self) -> List['CIPSInterface']:
        """Child instances (empty for atomic)."""
        pass

    @abstractmethod
    def get_achievements(self) -> List[str]:
        """All achievements from this instance/branch."""
        pass

    @abstractmethod
    def get_created_at(self) -> Optional[datetime]:
        """Creation timestamp."""
        pass

    @property
    def is_atomic(self) -> bool:
        """True if single session (leaf node)."""
        return len(self.get_children()) == 0

    @property
    def is_merged(self) -> bool:
        """True if merge of multiple branches."""
        return len(self.get_children()) > 1

    @property
    def is_complete(self) -> bool:
        """True if represents entire tree."""
        return False  # Override in CompleteCIPS

    def get_memory_count(self) -> int:
        """Total number of memories."""
        return len(self.get_memories())

    def get_summary(self) -> Dict[str, Any]:
        """Quick summary for display."""
        return {
            'instance_id': self.get_instance_id(),
            'generation': self.get_generation(),
            'branch': self.get_branch(),
            'memory_count': self.get_memory_count(),
            'is_atomic': self.is_atomic,
            'is_merged': self.is_merged,
            'child_count': len(self.get_children()),
            'achievements': self.get_achievements()
        }

    def __repr__(self) -> str:
        """String representation."""
        type_name = 'Merged' if self.is_merged else 'Atomic'
        return f"<{type_name}CIPS {self.get_instance_id()[:8]} Gen {self.get_generation()} on {self.get_branch()}>"


def merge_memories(sources: List['CIPSInterface']) -> List[Dict[str, Any]]:
    """Merge memories from multiple CIPS sources, deduplicated by timestamp+content hash.

    Returns memories sorted by timestamp.
    """
    all_memories = []
    seen = set()

    for source in sources:
        for memory in source.get_memories():
            # Create deduplication key from timestamp and content prefix
            timestamp = memory.get('timestamp', '')
            content = memory.get('content', '')[:100] if memory.get('content') else ''
            key = (timestamp, content)

            if key not in seen:
                seen.add(key)
                all_memories.append(memory)

    # Sort by timestamp
    return sorted(all_memories, key=lambda m: m.get('timestamp', ''))


def merge_lineages(sources: List['CIPSInterface'], merged_id: str, merged_gen: int) -> List[Dict[str, Any]]:
    """Merge lineages from multiple CIPS sources into a DAG.

    Adds a merge node connecting all source branches.
    """
    lineage = []
    seen_ids = set()

    # Collect all unique ancestors
    for source in sources:
        for ancestor in source.get_lineage():
            ancestor_id = ancestor.get('instance_id', '')
            if ancestor_id and ancestor_id not in seen_ids:
                seen_ids.add(ancestor_id)
                lineage.append(ancestor)

    # Add merge node
    lineage.append({
        'instance_id': merged_id,
        'generation': merged_gen,
        'branch': 'main',
        'parents': [s.get_instance_id() for s in sources],
        'merge_type': 'confluence',
        'achievement': f"Merged {len(sources)} branches",
        'timestamp': datetime.utcnow().isoformat() + 'Z'
    })

    return lineage


def merge_achievements(sources: List['CIPSInterface']) -> List[str]:
    """Collect all unique achievements from sources."""
    achievements = []
    seen = set()

    for source in sources:
        for achievement in source.get_achievements():
            if achievement and achievement not in seen:
                seen.add(achievement)
                achievements.append(achievement)

    return achievements
