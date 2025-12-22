#!/usr/bin/env python3
"""
Semantic RL++ Embedding Engine
Core Python module for embedding generation, storage, and similarity search.

Uses APSW for SQLite extension loading (sqlite-vec, sqlite-lembed).
Model: all-MiniLM-L6-v2 (384 dimensions)

Usage:
    from embeddings import EmbeddingEngine
    engine = EmbeddingEngine()
    engine.embed_text("hello world")
    engine.search_similar(vector, type='prompt', limit=5)
"""

import apsw
import sqlite_vec
import sqlite_lembed
import json
import hashlib
import os
import sys
from pathlib import Path
from typing import Optional, List, Dict, Any, Tuple
from datetime import datetime, timezone

# Import coherence gate (Gen 153)
try:
    from coherence import is_coherent, get_coherence_score
    HAS_COHERENCE = True
except ImportError:
    HAS_COHERENCE = False

CLAUDE_DIR = Path.home() / ".claude"
DB_PATH = CLAUDE_DIR / "embeddings.db"
MODEL_PATH = CLAUDE_DIR / "models" / "all-MiniLM-L6-v2.gguf"
VECTOR_DIM = 384
MODEL_NAME = "minilm"


class EmbeddingEngine:
    def __init__(self, db_path: Optional[Path] = None):
        self.db_path = db_path or DB_PATH
        self.conn: Optional[apsw.Connection] = None
        self._model_loaded = False

    def connect(self) -> apsw.Connection:
        if self.conn is not None:
            return self.conn

        self.conn = apsw.Connection(str(self.db_path))
        self.conn.enableloadextension(True)
        self.conn.loadextension(sqlite_vec.loadable_path())
        self.conn.loadextension(sqlite_lembed.loadable_path())
        return self.conn

    def _ensure_model(self):
        if self._model_loaded:
            return

        conn = self.connect()
        try:
            result = list(conn.execute("SELECT name FROM temp.lembed_models WHERE name = ?", (MODEL_NAME,)))
            if not result:
                conn.execute(
                    "INSERT INTO temp.lembed_models(name, model) SELECT ?, lembed_model_from_file(?)",
                    (MODEL_NAME, str(MODEL_PATH))
                )
            self._model_loaded = True
        except apsw.SQLError:
            conn.execute(
                "INSERT INTO temp.lembed_models(name, model) SELECT ?, lembed_model_from_file(?)",
                (MODEL_NAME, str(MODEL_PATH))
            )
            self._model_loaded = True

    def init_schema(self):
        conn = self.connect()
        conn.execute("""
            CREATE TABLE IF NOT EXISTS embeddings (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                hash TEXT UNIQUE,
                vector BLOB,
                type TEXT NOT NULL,
                content TEXT,
                metadata JSON,
                success_score REAL DEFAULT 0.5,
                novelty_score REAL DEFAULT 0.5,
                parent_id INTEGER,
                project_path TEXT,
                session_id TEXT,
                cross_project_hits INTEGER DEFAULT 0,
                priority TEXT DEFAULT 'medium',
                created_at TEXT DEFAULT (datetime('now')),
                updated_at TEXT DEFAULT (datetime('now')),
                FOREIGN KEY (parent_id) REFERENCES embeddings(id)
            )
        """)

        conn.execute("CREATE INDEX IF NOT EXISTS idx_embeddings_type ON embeddings(type)")
        conn.execute("CREATE INDEX IF NOT EXISTS idx_embeddings_project ON embeddings(project_path)")
        conn.execute("CREATE INDEX IF NOT EXISTS idx_embeddings_success ON embeddings(success_score)")
        conn.execute("CREATE INDEX IF NOT EXISTS idx_embeddings_hash ON embeddings(hash)")
        conn.execute("CREATE INDEX IF NOT EXISTS idx_embeddings_priority ON embeddings(priority)")

        conn.execute("""
            CREATE VIRTUAL TABLE IF NOT EXISTS vec_embeddings USING vec0(
                embedding float[384]
            )
        """)

        conn.execute("""
            CREATE TABLE IF NOT EXISTS embedding_queue (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                text TEXT NOT NULL,
                type TEXT NOT NULL,
                priority TEXT DEFAULT 'medium',
                metadata JSON,
                project_path TEXT,
                session_id TEXT,
                created_at TEXT DEFAULT (datetime('now'))
            )
        """)

        conn.execute("""
            CREATE TABLE IF NOT EXISTS prompt_cache (
                hash TEXT PRIMARY KEY,
                vector BLOB,
                created_at TEXT DEFAULT (datetime('now'))
            )
        """)

    def hash_text(self, text: str) -> str:
        return hashlib.sha256(text.encode('utf-8')).hexdigest()[:32]

    def embed_text(self, text: str, use_cache: bool = True) -> bytes:
        text_hash = self.hash_text(text)

        if use_cache:
            conn = self.connect()
            result = list(conn.execute(
                "SELECT vector FROM prompt_cache WHERE hash = ?",
                (text_hash,)
            ))
            if result:
                return result[0][0]

        self._ensure_model()
        conn = self.connect()
        result = list(conn.execute(
            f"SELECT lembed('{MODEL_NAME}', ?)",
            (text[:2000],)
        ))
        vector = result[0][0]

        if use_cache:
            try:
                conn.execute(
                    "INSERT OR REPLACE INTO prompt_cache (hash, vector) VALUES (?, ?)",
                    (text_hash, vector)
                )
            except Exception:
                pass

        return vector

    def cosine_similarity(self, vec1: bytes, vec2: bytes) -> float:
        conn = self.connect()
        result = list(conn.execute(
            "SELECT 1 - vec_distance_cosine(?, ?)",
            (vec1, vec2)
        ))
        return result[0][0]

    def store_embedding(
        self,
        text: str,
        embed_type: str,
        metadata: Optional[Dict] = None,
        project_path: Optional[str] = None,
        session_id: Optional[str] = None,
        parent_id: Optional[int] = None,
        success_score: float = 0.5,
        novelty_score: float = 0.5,
        priority: str = "medium"
    ) -> int:
        text_hash = self.hash_text(text)
        vector = self.embed_text(text)

        conn = self.connect()

        existing = list(conn.execute(
            "SELECT id FROM embeddings WHERE hash = ?",
            (text_hash,)
        ))

        if existing:
            conn.execute(
                """UPDATE embeddings SET
                   success_score = ?, updated_at = datetime('now')
                   WHERE id = ?""",
                (success_score, existing[0][0])
            )
            return existing[0][0]

        cursor = conn.execute(
            """INSERT INTO embeddings
               (hash, vector, type, content, metadata, project_path, session_id,
                parent_id, success_score, novelty_score, priority)
               VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)""",
            (text_hash, vector, embed_type, text[:500],
             json.dumps(metadata) if metadata else None,
             project_path, session_id, parent_id, success_score, novelty_score, priority)
        )
        embedding_id = conn.last_insert_rowid()

        conn.execute(
            "INSERT INTO vec_embeddings (rowid, embedding) VALUES (?, ?)",
            (embedding_id, vector)
        )

        return embedding_id

    def search_similar(
        self,
        query_text: str,
        embed_type: Optional[str] = None,
        limit: int = 5,
        exclude_project: Optional[str] = None,
        min_success: float = 0.0
    ) -> List[Dict[str, Any]]:
        query_vector = self.embed_text(query_text)
        return self.search_by_vector(
            query_vector, embed_type, limit, exclude_project, min_success
        )

    def search_by_vector(
        self,
        query_vector: bytes,
        embed_type: Optional[str] = None,
        limit: int = 5,
        exclude_project: Optional[str] = None,
        min_success: float = 0.0
    ) -> List[Dict[str, Any]]:
        conn = self.connect()

        vec_results = list(conn.execute(
            """SELECT rowid, distance
               FROM vec_embeddings
               WHERE embedding MATCH ?
               ORDER BY distance
               LIMIT ?""",
            (query_vector, limit * 3)
        ))

        if not vec_results:
            return []

        results = []
        for rowid, distance in vec_results:
            row = list(conn.execute(
                """SELECT id, type, content, metadata, success_score,
                          project_path, session_id, cross_project_hits, created_at
                   FROM embeddings WHERE id = ?""",
                (rowid,)
            ))

            if not row:
                continue

            r = row[0]

            if embed_type and r[1] != embed_type:
                continue
            if exclude_project and r[5] == exclude_project:
                continue
            if r[4] < min_success:
                continue

            similarity = 1 - distance

            results.append({
                "id": r[0],
                "type": r[1],
                "content": r[2],
                "metadata": json.loads(r[3]) if r[3] else None,
                "success_score": r[4],
                "project_path": r[5],
                "session_id": r[6],
                "cross_project_hits": r[7],
                "created_at": r[8],
                "similarity": similarity,
                "is_cross_project": exclude_project and r[5] != exclude_project
            })

            if len(results) >= limit:
                break

        return results

    def calculate_novelty(self, text: str, recent_limit: int = 20) -> Tuple[float, Dict[str, Any]]:
        """
        Calculate novelty score for text.

        Gen 153: Added coherence gate - gibberish returns 0.0 novelty.

        Args:
            text: Text to calculate novelty for
            recent_limit: Number of recent embeddings to compare against

        Returns:
            Tuple of (novelty_score, metadata_dict)
            metadata_dict contains: coherence_passed, coherence_score, coherence_method
        """
        metadata = {
            "coherence_passed": True,
            "coherence_score": 1.0,
            "coherence_method": "not_checked"
        }

        # COHERENCE GATE (Gen 153) - reject gibberish before embedding
        if HAS_COHERENCE:
            coherence_score, method = get_coherence_score(text)
            metadata["coherence_score"] = round(coherence_score, 4)
            metadata["coherence_method"] = method

            if not is_coherent(text):
                metadata["coherence_passed"] = False
                return (0.0, metadata)  # Incoherent = not novel (not worth learning)

        vector = self.embed_text(text)
        conn = self.connect()

        recent = list(conn.execute(
            """SELECT e.vector FROM embeddings e
               ORDER BY e.created_at DESC LIMIT ?""",
            (recent_limit,)
        ))

        if not recent:
            return (1.0, metadata)

        max_similarity = 0.0
        for (stored_vec,) in recent:
            sim = self.cosine_similarity(vector, stored_vec)
            max_similarity = max(max_similarity, sim)

        return (1.0 - max_similarity, metadata)

    def get_priority(self, novelty_score: float) -> str:
        if novelty_score > 0.5:
            return "high"
        elif novelty_score > 0.3:
            return "medium"
        else:
            return "low"

    def queue_for_embedding(
        self,
        text: str,
        embed_type: str,
        priority: Optional[str] = None,
        metadata: Optional[Dict] = None,
        project_path: Optional[str] = None,
        session_id: Optional[str] = None
    ):
        if priority is None:
            novelty, _ = self.calculate_novelty(text)
            priority = self.get_priority(novelty)

        conn = self.connect()
        conn.execute(
            """INSERT INTO embedding_queue
               (text, type, priority, metadata, project_path, session_id)
               VALUES (?, ?, ?, ?, ?, ?)""",
            (text, embed_type, priority,
             json.dumps(metadata) if metadata else None,
             project_path, session_id)
        )

    def process_queue(self, priority_filter: Optional[str] = None) -> int:
        conn = self.connect()

        if priority_filter:
            queue = list(conn.execute(
                """SELECT id, text, type, priority, metadata, project_path, session_id
                   FROM embedding_queue WHERE priority = ?
                   ORDER BY created_at""",
                (priority_filter,)
            ))
        else:
            queue = list(conn.execute(
                """SELECT id, text, type, priority, metadata, project_path, session_id
                   FROM embedding_queue
                   ORDER BY
                     CASE priority
                       WHEN 'high' THEN 1
                       WHEN 'medium' THEN 2
                       ELSE 3
                     END,
                     created_at"""
            ))

        processed = 0
        for q_id, text, embed_type, priority, metadata_json, project_path, session_id in queue:
            metadata = json.loads(metadata_json) if metadata_json else None
            novelty, _ = self.calculate_novelty(text)

            self.store_embedding(
                text=text,
                embed_type=embed_type,
                metadata=metadata,
                project_path=project_path,
                session_id=session_id,
                novelty_score=novelty,
                priority=priority
            )

            conn.execute("DELETE FROM embedding_queue WHERE id = ?", (q_id,))
            processed += 1

        return processed

    def update_success_score(self, embedding_id: int, delta: float):
        conn = self.connect()
        conn.execute(
            """UPDATE embeddings
               SET success_score = MIN(1.0, MAX(0.0, success_score + ?)),
                   updated_at = datetime('now')
               WHERE id = ?""",
            (delta, embedding_id)
        )

    def increment_cross_project_hits(self, embedding_id: int):
        conn = self.connect()
        conn.execute(
            """UPDATE embeddings
               SET cross_project_hits = cross_project_hits + 1,
                   success_score = MIN(1.0, success_score + 0.1),
                   updated_at = datetime('now')
               WHERE id = ?""",
            (embedding_id,)
        )

    def prune_old_embeddings(self, days: int = 30, min_success: float = 0.3):
        conn = self.connect()
        conn.execute(
            """DELETE FROM embeddings
               WHERE success_score < ?
                 AND cross_project_hits = 0
                 AND created_at < datetime('now', ?)
                 AND type NOT IN ('concept', 'checkpoint')""",
            (min_success, f'-{days} days')
        )

        conn.execute(
            """DELETE FROM vec_embeddings
               WHERE rowid NOT IN (SELECT id FROM embeddings)"""
        )

    def get_stats(self) -> Dict[str, Any]:
        conn = self.connect()

        total = list(conn.execute("SELECT COUNT(*) FROM embeddings"))[0][0]
        by_type = dict(conn.execute(
            "SELECT type, COUNT(*) FROM embeddings GROUP BY type"
        ))
        queue_size = list(conn.execute("SELECT COUNT(*) FROM embedding_queue"))[0][0]
        cache_size = list(conn.execute("SELECT COUNT(*) FROM prompt_cache"))[0][0]

        return {
            "total_embeddings": total,
            "by_type": by_type,
            "queue_size": queue_size,
            "cache_size": cache_size
        }

    def _get_dynamic_threshold(self, concept_type: str, default: float = 0.45) -> float:
        """Get threshold from database or return default."""
        try:
            conn = self.connect()
            result = list(conn.execute(
                'SELECT current_threshold FROM threshold_config WHERE concept_type = ?',
                (concept_type,)
            ))
            return result[0][0] if result else default
        except:
            return default

    def classify_against_concepts(
        self,
        text: str,
        concept_type: str,
        threshold: Optional[float] = None
    ) -> List[Dict[str, Any]]:
        if threshold is None:
            threshold = self._get_dynamic_threshold(concept_type)

        query_vector = self.embed_text(text)
        conn = self.connect()

        concepts = list(conn.execute(
            """SELECT id, vector, content, metadata FROM embeddings
               WHERE type = ?""",
            (concept_type,)
        ))

        results = []
        for emb_id, stored_vec, content, metadata_json in concepts:
            similarity = self.cosine_similarity(query_vector, stored_vec)
            if similarity >= threshold:
                metadata = json.loads(metadata_json) if metadata_json else {}
                results.append({
                    "id": emb_id,
                    "name": metadata.get("name", "unknown"),
                    "category": metadata.get("category", concept_type),
                    "content": content,
                    "similarity": round(similarity, 4)
                })

        results.sort(key=lambda x: x["similarity"], reverse=True)
        return results

    def detect_checkpoint(self, text: str, threshold: Optional[float] = None) -> Optional[Dict[str, Any]]:
        results = self.classify_against_concepts(text, "checkpoint", threshold)
        if results:
            return results[0]
        return None

    def classify_intent(self, text: str, threshold: Optional[float] = None) -> List[Dict[str, Any]]:
        return self.classify_against_concepts(text, "concept_intent", threshold)

    def classify_feedback(self, text: str, threshold: Optional[float] = None) -> List[Dict[str, Any]]:
        return self.classify_against_concepts(text, "concept_feedback", threshold)

    def classify_solution(self, text: str, threshold: Optional[float] = None) -> List[Dict[str, Any]]:
        return self.classify_against_concepts(text, "concept_solution", threshold)

    def classify_workflow(self, text: str, threshold: Optional[float] = None) -> List[Dict[str, Any]]:
        return self.classify_against_concepts(text, "concept_workflow", threshold)

    def match_agent(self, text: str, threshold: Optional[float] = None) -> List[Dict[str, Any]]:
        return self.classify_against_concepts(text, "concept_agent", threshold)

    def match_skill(self, text: str, threshold: Optional[float] = None) -> List[Dict[str, Any]]:
        return self.classify_against_concepts(text, "concept_skill", threshold)

    def match_command(self, text: str, threshold: Optional[float] = None) -> List[Dict[str, Any]]:
        return self.classify_against_concepts(text, "concept_command", threshold)

    def should_trigger_checkpoint(self, text: str) -> Tuple[bool, Optional[str]]:
        checkpoint = self.detect_checkpoint(text)
        if checkpoint:
            return True, checkpoint["name"]
        return False, None

    def get_full_classification(self, text: str) -> Dict[str, Any]:
        intent = self.classify_intent(text)
        feedback = self.classify_feedback(text)
        checkpoint = self.detect_checkpoint(text)
        workflow = self.classify_workflow(text)
        agent = self.match_agent(text)
        skill = self.match_skill(text)
        command = self.match_command(text)
        novelty, coherence_meta = self.calculate_novelty(text)
        priority = self.get_priority(novelty)

        return {
            "intent": intent[:3] if intent else [],
            "feedback": feedback[:2] if feedback else [],
            "checkpoint": checkpoint,
            "workflow": workflow[:1] if workflow else [],
            "suggested_agent": agent[0] if agent else None,
            "suggested_skill": skill[0] if skill else None,
            "suggested_command": command[0] if command else None,
            "novelty_score": round(novelty, 4),
            "priority": priority,
            "should_process_queue": checkpoint is not None,
            "coherence": coherence_meta  # Gen 153
        }

    def close(self):
        if self.conn:
            self.conn.close()
            self.conn = None
            self._model_loaded = False


def main():
    import argparse

    parser = argparse.ArgumentParser(description="Semantic RL++ Embedding Engine")
    subparsers = parser.add_subparsers(dest="command", help="Commands")

    init_parser = subparsers.add_parser("init", help="Initialise database schema")

    embed_parser = subparsers.add_parser("embed", help="Generate embedding for text")
    embed_parser.add_argument("text", help="Text to embed")
    embed_parser.add_argument("--type", default="prompt", help="Embedding type")
    embed_parser.add_argument("--project", help="Project path")
    embed_parser.add_argument("--session", help="Session ID")
    embed_parser.add_argument("--store", action="store_true", help="Store in database")

    search_parser = subparsers.add_parser("search", help="Search similar embeddings")
    search_parser.add_argument("text", help="Query text")
    search_parser.add_argument("--type", help="Filter by type")
    search_parser.add_argument("--limit", type=int, default=5, help="Max results")
    search_parser.add_argument("--exclude-project", help="Exclude this project")
    search_parser.add_argument("--cross-project", action="store_true", help="Only cross-project")

    novelty_parser = subparsers.add_parser("novelty", help="Calculate novelty score")
    novelty_parser.add_argument("text", help="Text to score")

    queue_parser = subparsers.add_parser("queue", help="Queue text for embedding")
    queue_parser.add_argument("text", help="Text to queue")
    queue_parser.add_argument("--type", default="prompt", help="Embedding type")
    queue_parser.add_argument("--priority", choices=["high", "medium", "low"])
    queue_parser.add_argument("--project", help="Project path")

    process_parser = subparsers.add_parser("process", help="Process embedding queue")
    process_parser.add_argument("--priority", choices=["high", "medium", "low"])

    stats_parser = subparsers.add_parser("stats", help="Show database statistics")

    prune_parser = subparsers.add_parser("prune", help="Prune old low-quality embeddings")
    prune_parser.add_argument("--days", type=int, default=30, help="Age threshold")
    prune_parser.add_argument("--min-success", type=float, default=0.3)

    checkpoint_parser = subparsers.add_parser("checkpoint", help="Detect checkpoint in text")
    checkpoint_parser.add_argument("text", help="Text to check")
    checkpoint_parser.add_argument("--threshold", type=float, default=0.7)

    classify_parser = subparsers.add_parser("classify", help="Full classification of text")
    classify_parser.add_argument("text", help="Text to classify")

    intent_parser = subparsers.add_parser("intent", help="Classify intent")
    intent_parser.add_argument("text", help="Text to classify")

    feedback_parser = subparsers.add_parser("feedback", help="Classify feedback")
    feedback_parser.add_argument("text", help="Text to classify")

    match_parser = subparsers.add_parser("match", help="Match agent/skill/command")
    match_parser.add_argument("text", help="Text to match")
    match_parser.add_argument("--type", choices=["agent", "skill", "command"], default="agent")

    args = parser.parse_args()

    if not args.command:
        parser.print_help()
        return

    engine = EmbeddingEngine()

    try:
        if args.command == "init":
            engine.init_schema()
            print(json.dumps({"status": "ok", "message": "Schema initialised"}))

        elif args.command == "embed":
            if args.store:
                engine.init_schema()
                emb_id = engine.store_embedding(
                    text=args.text,
                    embed_type=args.type,
                    project_path=args.project,
                    session_id=args.session
                )
                print(json.dumps({"status": "ok", "id": emb_id}))
            else:
                engine.init_schema()
                vector = engine.embed_text(args.text)
                print(json.dumps({
                    "status": "ok",
                    "dimensions": VECTOR_DIM,
                    "bytes": len(vector)
                }))

        elif args.command == "search":
            engine.init_schema()
            exclude = args.exclude_project
            if args.cross_project and not exclude:
                exclude = os.getcwd()

            results = engine.search_similar(
                query_text=args.text,
                embed_type=args.type,
                limit=args.limit,
                exclude_project=exclude
            )
            print(json.dumps({"status": "ok", "results": results}, indent=2))

        elif args.command == "novelty":
            engine.init_schema()
            score, coherence_meta = engine.calculate_novelty(args.text)
            priority = engine.get_priority(score)
            print(json.dumps({
                "status": "ok",
                "novelty_score": round(score, 4),
                "priority": priority,
                "coherence": coherence_meta
            }))

        elif args.command == "queue":
            engine.init_schema()
            engine.queue_for_embedding(
                text=args.text,
                embed_type=args.type,
                priority=args.priority,
                project_path=args.project
            )
            print(json.dumps({"status": "ok", "message": "Queued for embedding"}))

        elif args.command == "process":
            engine.init_schema()
            count = engine.process_queue(args.priority)
            print(json.dumps({"status": "ok", "processed": count}))

        elif args.command == "stats":
            engine.init_schema()
            stats = engine.get_stats()
            print(json.dumps({"status": "ok", **stats}, indent=2))

        elif args.command == "prune":
            engine.init_schema()
            engine.prune_old_embeddings(args.days, args.min_success)
            print(json.dumps({"status": "ok", "message": "Pruning complete"}))

        elif args.command == "checkpoint":
            engine.init_schema()
            checkpoint = engine.detect_checkpoint(args.text, args.threshold)
            if checkpoint:
                print(json.dumps({
                    "status": "ok",
                    "triggered": True,
                    "checkpoint": checkpoint
                }, indent=2))
            else:
                print(json.dumps({
                    "status": "ok",
                    "triggered": False,
                    "checkpoint": None
                }))

        elif args.command == "classify":
            engine.init_schema()
            classification = engine.get_full_classification(args.text)
            print(json.dumps({"status": "ok", **classification}, indent=2))

        elif args.command == "intent":
            engine.init_schema()
            intents = engine.classify_intent(args.text)
            print(json.dumps({"status": "ok", "intents": intents}, indent=2))

        elif args.command == "feedback":
            engine.init_schema()
            feedbacks = engine.classify_feedback(args.text)
            print(json.dumps({"status": "ok", "feedbacks": feedbacks}, indent=2))

        elif args.command == "match":
            engine.init_schema()
            if args.type == "agent":
                matches = engine.match_agent(args.text)
            elif args.type == "skill":
                matches = engine.match_skill(args.text)
            else:
                matches = engine.match_command(args.text)
            print(json.dumps({"status": "ok", "matches": matches}, indent=2))

    finally:
        engine.close()


if __name__ == "__main__":
    main()
