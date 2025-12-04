#!/usr/bin/env python3
"""
Dynamic Threshold Manager
Learns optimal thresholds from user feedback for Semantic RL++

The threshold learning loop:
1. User prompt → semantic match with current threshold
2. Match recorded in history
3. User feedback (explicit or implicit) recorded
4. After N samples, threshold recalibrated
5. Significant changes trigger re-matching of recent prompts

VERSION: 1.0.0
DATE: 2025-12-02
"""

import json
import sys
from pathlib import Path
from typing import Optional, Dict, List, Any, Tuple
from datetime import datetime

CLAUDE_DIR = Path.home() / ".claude"
sys.path.insert(0, str(CLAUDE_DIR / "lib"))

try:
    from embeddings import EmbeddingEngine
except ImportError:
    EmbeddingEngine = None


class ThresholdManager:
    """Manages dynamic thresholds with feedback-based learning."""

    DEFAULT_THRESHOLDS = {
        'concept_intent': 0.40,
        'concept_feedback': 0.25,
        'concept_agent': 0.45,
        'concept_skill': 0.45,
        'concept_command': 0.45,
        'checkpoint': 0.55,
        'concept_solution': 0.40,
        'concept_workflow': 0.40,
    }

    TARGET_SUCCESS_RATE = 0.80
    MIN_SAMPLES_FOR_CALIBRATION = 10
    REMATCH_THRESHOLD_DELTA = 0.05

    def __init__(self, engine: Optional['EmbeddingEngine'] = None):
        if engine is None:
            if EmbeddingEngine is None:
                raise ImportError("EmbeddingEngine not available")
            engine = EmbeddingEngine()
        self.engine = engine
        self._ensure_tables()

    def _ensure_tables(self):
        """Ensure threshold tables exist."""
        conn = self.engine.connect()

        conn.execute('''
            CREATE TABLE IF NOT EXISTS threshold_config (
                concept_type TEXT PRIMARY KEY,
                current_threshold REAL NOT NULL,
                min_threshold REAL DEFAULT 0.2,
                max_threshold REAL DEFAULT 0.9,
                total_matches INTEGER DEFAULT 0,
                successful_matches INTEGER DEFAULT 0,
                last_calibrated TEXT,
                auto_adjust INTEGER DEFAULT 1,
                adjustment_sensitivity REAL DEFAULT 0.02
            )
        ''')

        conn.execute('''
            CREATE TABLE IF NOT EXISTS match_history (
                id INTEGER PRIMARY KEY,
                prompt_text TEXT,
                concept_type TEXT,
                matched_concept TEXT,
                similarity REAL,
                threshold_used REAL,
                user_feedback TEXT,
                feedback_at TEXT,
                created_at TEXT DEFAULT (datetime('now'))
            )
        ''')

        for concept_type, threshold in self.DEFAULT_THRESHOLDS.items():
            try:
                conn.execute('''
                    INSERT INTO threshold_config (concept_type, current_threshold)
                    VALUES (?, ?)
                ''', (concept_type, threshold))
            except:
                pass

    def get_threshold(self, concept_type: str) -> float:
        """Get current threshold for concept type from database."""
        cursor = self.engine.conn.cursor()

        result = list(cursor.execute(
            'SELECT current_threshold FROM threshold_config WHERE concept_type = ?',
            (concept_type,)
        ))

        if result:
            return result[0][0]

        return self.DEFAULT_THRESHOLDS.get(concept_type, 0.45)

    def get_all_thresholds(self) -> Dict[str, float]:
        """Get all current thresholds."""
        cursor = self.engine.conn.cursor()

        result = dict(cursor.execute(
            'SELECT concept_type, current_threshold FROM threshold_config'
        ))

        return result

    def record_match(
        self,
        concept_type: str,
        prompt: str,
        matched_concept: Optional[str],
        similarity: float
    ) -> int:
        """Record a match attempt for later feedback tracking."""
        cursor = self.engine.conn.cursor()
        threshold = self.get_threshold(concept_type)

        cursor.execute('''
            INSERT INTO match_history
            (prompt_text, concept_type, matched_concept, similarity, threshold_used)
            VALUES (?, ?, ?, ?, ?)
        ''', (prompt[:500], concept_type, matched_concept, similarity, threshold))

        self.engine.conn.commit()
        return cursor.lastrowid

    def record_feedback(
        self,
        feedback: str,
        match_id: Optional[int] = None,
        concept_type: Optional[str] = None
    ) -> Optional[Dict[str, Any]]:
        """
        Record user feedback on a match.

        Args:
            feedback: 'positive', 'negative', or 'neutral'
            match_id: Specific match to update (if known)
            concept_type: If match_id not provided, updates most recent match of this type

        Returns:
            Calibration result if threshold was adjusted, None otherwise
        """
        cursor = self.engine.conn.cursor()

        if match_id is None and concept_type:
            result = list(cursor.execute('''
                SELECT id, concept_type FROM match_history
                WHERE concept_type = ? AND user_feedback IS NULL
                ORDER BY created_at DESC LIMIT 1
            ''', (concept_type,)))

            if result:
                match_id = result[0][0]
                concept_type = result[0][1]

        if match_id is None:
            result = list(cursor.execute('''
                SELECT id, concept_type FROM match_history
                WHERE user_feedback IS NULL
                ORDER BY created_at DESC LIMIT 1
            '''))

            if result:
                match_id = result[0][0]
                concept_type = result[0][1]

        if match_id is None:
            return None

        cursor.execute('''
            UPDATE match_history
            SET user_feedback = ?, feedback_at = datetime('now')
            WHERE id = ?
        ''', (feedback, match_id))

        if concept_type is None:
            result = list(cursor.execute(
                'SELECT concept_type FROM match_history WHERE id = ?',
                (match_id,)
            ))
            if result:
                concept_type = result[0][0]

        if concept_type:
            if feedback == 'positive':
                cursor.execute('''
                    UPDATE threshold_config
                    SET total_matches = total_matches + 1,
                        successful_matches = successful_matches + 1
                    WHERE concept_type = ?
                ''', (concept_type,))
            elif feedback == 'negative':
                cursor.execute('''
                    UPDATE threshold_config
                    SET total_matches = total_matches + 1
                    WHERE concept_type = ?
                ''', (concept_type,))
            elif feedback == 'neutral':
                cursor.execute('''
                    UPDATE threshold_config
                    SET total_matches = total_matches + 1,
                        successful_matches = successful_matches + 1
                    WHERE concept_type = ?
                ''', (concept_type,))

        self.engine.conn.commit()

        return self._maybe_calibrate(concept_type)

    def _maybe_calibrate(
        self,
        concept_type: str,
        min_samples: Optional[int] = None
    ) -> Optional[Dict[str, Any]]:
        """
        Calibrate threshold if enough samples collected.

        Returns calibration result if adjustment made, None otherwise.
        """
        if min_samples is None:
            min_samples = self.MIN_SAMPLES_FOR_CALIBRATION

        cursor = self.engine.conn.cursor()

        result = list(cursor.execute('''
            SELECT current_threshold, total_matches, successful_matches,
                   min_threshold, max_threshold, adjustment_sensitivity, auto_adjust
            FROM threshold_config
            WHERE concept_type = ?
        ''', (concept_type,)))

        if not result:
            return None

        current, total, successes, min_t, max_t, sensitivity, auto_adjust = result[0]

        if not auto_adjust:
            return None

        if total < min_samples:
            return None

        success_rate = successes / total if total > 0 else 0.5

        if success_rate < self.TARGET_SUCCESS_RATE - 0.10:
            delta = min(sensitivity * 2.5, (self.TARGET_SUCCESS_RATE - success_rate) * 0.2)
            new_threshold = min(max_t, current + delta)
            reason = f"low success rate ({success_rate:.1%})"
        elif success_rate > self.TARGET_SUCCESS_RATE + 0.10:
            delta = min(sensitivity * 2.5, (success_rate - self.TARGET_SUCCESS_RATE) * 0.2)
            new_threshold = max(min_t, current - delta)
            reason = f"high success rate ({success_rate:.1%})"
        else:
            cursor.execute('''
                UPDATE threshold_config
                SET total_matches = 0, successful_matches = 0
                WHERE concept_type = ?
            ''', (concept_type,))
            self.engine.conn.commit()
            return None

        if abs(new_threshold - current) < 0.01:
            return None

        cursor.execute('''
            UPDATE threshold_config
            SET current_threshold = ?,
                total_matches = 0,
                successful_matches = 0,
                last_calibrated = datetime('now')
            WHERE concept_type = ?
        ''', (new_threshold, concept_type))

        self.engine.conn.commit()

        result = {
            'concept_type': concept_type,
            'old_threshold': round(current, 4),
            'new_threshold': round(new_threshold, 4),
            'success_rate': round(success_rate, 4),
            'samples': total,
            'reason': reason
        }

        if abs(new_threshold - current) >= self.REMATCH_THRESHOLD_DELTA:
            newly_matched = self._rematch_recent(concept_type, current, new_threshold)
            result['newly_matched'] = newly_matched

        return result

    def _rematch_recent(
        self,
        concept_type: str,
        old_threshold: float,
        new_threshold: float
    ) -> List[Dict[str, Any]]:
        """Re-evaluate recent unmatched prompts when threshold lowered."""
        if new_threshold >= old_threshold:
            return []

        cursor = self.engine.conn.cursor()

        cursor.execute('''
            SELECT id, prompt_text, similarity
            FROM match_history
            WHERE concept_type = ?
            AND matched_concept IS NULL
            AND similarity >= ? AND similarity < ?
            ORDER BY created_at DESC
            LIMIT 10
        ''', (concept_type, new_threshold, old_threshold))

        newly_matched = []
        for row in cursor.fetchall():
            newly_matched.append({
                'id': row[0],
                'prompt': row[1][:100] if row[1] else '',
                'similarity': round(row[2], 4)
            })

        return newly_matched

    def calibrate_all(self, min_samples: Optional[int] = None) -> List[Dict[str, Any]]:
        """Calibrate all concept types that have enough samples."""
        cursor = self.engine.conn.cursor()

        concept_types = [row[0] for row in cursor.execute(
            'SELECT concept_type FROM threshold_config WHERE auto_adjust = 1'
        )]

        results = []
        for concept_type in concept_types:
            result = self._maybe_calibrate(concept_type, min_samples)
            if result:
                results.append(result)

        return results

    def get_stats(self) -> Dict[str, Any]:
        """Get threshold learning statistics."""
        cursor = self.engine.conn.cursor()

        stats = {
            'thresholds': {},
            'feedback_summary': {},
            'recent_calibrations': []
        }

        for row in cursor.execute('''
            SELECT concept_type, current_threshold, total_matches, successful_matches,
                   last_calibrated
            FROM threshold_config
        '''):
            concept_type, threshold, total, successes, last_cal = row
            success_rate = successes / total if total > 0 else None

            stats['thresholds'][concept_type] = {
                'current': round(threshold, 4),
                'samples': total,
                'success_rate': round(success_rate, 4) if success_rate else None,
                'last_calibrated': last_cal
            }

        feedback_counts = dict(cursor.execute('''
            SELECT user_feedback, COUNT(*)
            FROM match_history
            WHERE user_feedback IS NOT NULL
            GROUP BY user_feedback
        '''))
        stats['feedback_summary'] = feedback_counts

        total_matches = list(cursor.execute(
            'SELECT COUNT(*) FROM match_history'
        ))[0][0]
        stats['total_matches_recorded'] = total_matches

        return stats

    def reset_threshold(self, concept_type: str, new_threshold: Optional[float] = None):
        """Reset a threshold to default or specified value."""
        if new_threshold is None:
            new_threshold = self.DEFAULT_THRESHOLDS.get(concept_type, 0.45)

        cursor = self.engine.conn.cursor()
        cursor.execute('''
            UPDATE threshold_config
            SET current_threshold = ?,
                total_matches = 0,
                successful_matches = 0,
                last_calibrated = NULL
            WHERE concept_type = ?
        ''', (new_threshold, concept_type))

        self.engine.conn.commit()

    def set_auto_adjust(self, concept_type: str, enabled: bool):
        """Enable or disable auto-adjustment for a concept type."""
        cursor = self.engine.conn.cursor()
        cursor.execute('''
            UPDATE threshold_config
            SET auto_adjust = ?
            WHERE concept_type = ?
        ''', (1 if enabled else 0, concept_type))
        self.engine.conn.commit()

    def close(self):
        """Close the database connection."""
        if self.engine:
            self.engine.close()


def main():
    """CLI interface for threshold manager."""
    import argparse

    parser = argparse.ArgumentParser(description='Threshold Manager CLI')
    parser.add_argument('command', choices=['stats', 'calibrate', 'reset', 'get', 'set'])
    parser.add_argument('--type', '-t', help='Concept type')
    parser.add_argument('--value', '-v', type=float, help='Threshold value')
    parser.add_argument('--feedback', '-f', choices=['positive', 'negative', 'neutral'])

    args = parser.parse_args()

    manager = ThresholdManager()

    try:
        if args.command == 'stats':
            stats = manager.get_stats()
            print(json.dumps(stats, indent=2, default=str))

        elif args.command == 'calibrate':
            results = manager.calibrate_all()
            if results:
                for r in results:
                    print(f"[CALIBRATED] {r['concept_type']}: "
                          f"{r['old_threshold']:.3f} -> {r['new_threshold']:.3f} "
                          f"({r['reason']})")
            else:
                print("No calibrations needed")

        elif args.command == 'reset':
            if not args.type:
                print("ERROR: --type required")
                sys.exit(1)
            manager.reset_threshold(args.type, args.value)
            print(f"Reset {args.type} to {args.value or 'default'}")

        elif args.command == 'get':
            if args.type:
                threshold = manager.get_threshold(args.type)
                print(f"{args.type}: {threshold:.4f}")
            else:
                thresholds = manager.get_all_thresholds()
                for t, v in thresholds.items():
                    print(f"{t}: {v:.4f}")

        elif args.command == 'set':
            if not args.type or args.value is None:
                print("ERROR: --type and --value required")
                sys.exit(1)
            manager.reset_threshold(args.type, args.value)
            print(f"Set {args.type} to {args.value:.4f}")

    finally:
        manager.close()


if __name__ == '__main__':
    main()
