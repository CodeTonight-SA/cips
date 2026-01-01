#!/usr/bin/env python3
"""
Pre-embed Concept Library
One-time script to embed all semantic anchors from concept-library.json

This creates the static concept embeddings used for:
- Intent classification
- Solution classification
- Feedback detection
- Checkpoint detection
- Agent/skill/command matching

Run: python3 ~/.claude/scripts/embed-concepts.py
"""

import sys
import json
from pathlib import Path

sys.path.insert(0, str(Path.home() / ".claude" / "lib"))
from embeddings import EmbeddingEngine

CLAUDE_DIR = Path.home() / ".claude"
CONCEPT_LIBRARY_PATH = CLAUDE_DIR / "config" / "concept-library.json"


def main():
    print("=== Pre-embedding Concept Library ===\n")

    if not CONCEPT_LIBRARY_PATH.exists():
        print(f"ERROR: Concept library not found at {CONCEPT_LIBRARY_PATH}")
        return 1

    with open(CONCEPT_LIBRARY_PATH) as f:
        library = json.load(f)

    engine = EmbeddingEngine()
    engine.init_schema()

    total = 0
    categories = [
        ("intent_concepts", "concept_intent"),
        ("solution_concepts", "concept_solution"),
        ("feedback_concepts", "concept_feedback"),
        ("workflow_concepts", "concept_workflow"),
        ("checkpoint_anchors", "checkpoint"),
        ("agents", "concept_agent"),
        ("skills", "concept_skill"),
        ("commands", "concept_command"),
    ]

    for category_key, embed_type in categories:
        if category_key not in library:
            print(f"  Skipping {category_key} (not found)")
            continue

        concepts = library[category_key].get("concepts", {})
        print(f"  Embedding {len(concepts)} {category_key}...")

        for name, text in concepts.items():
            metadata = {"category": category_key, "name": name}

            engine.store_embedding(
                text=text,
                embed_type=embed_type,
                metadata=metadata,
                project_path="__system__",
                success_score=1.0,
                novelty_score=0.0,
                priority="system"
            )
            total += 1

    print(f"\n  Total concepts embedded: {total}")

    stats = engine.get_stats()
    print(f"\n=== Database Stats ===")
    print(f"  Total embeddings: {stats['total_embeddings']}")
    print(f"  By type: {json.dumps(stats['by_type'], indent=4)}")

    engine.close()
    print("\n=== Concept Library Pre-embedding Complete ===")
    return 0


if __name__ == "__main__":
    sys.exit(main())
