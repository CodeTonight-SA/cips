#!/usr/bin/env python3
"""
Pattern Emergence Engine
Discovers patterns from accumulated embeddings using clustering

PURPOSE:
  1. Cluster similar embeddings to detect emerging patterns
  2. Generate new concepts from high-success clusters
  3. Identify cross-project insights
  4. Prune low-value embeddings

USAGE:
  python3 ~/.claude/scripts/pattern-emergence.py cluster
  python3 ~/.claude/scripts/pattern-emergence.py generate-concepts
  python3 ~/.claude/scripts/pattern-emergence.py cross-project
  python3 ~/.claude/scripts/pattern-emergence.py prune --days 30

VERSION: 1.0.0
DATE: 2025-12-02
"""

import sys
import json
import argparse
from pathlib import Path
from datetime import datetime, timedelta
from collections import defaultdict

sys.path.insert(0, str(Path.home() / ".claude" / "lib"))
from embeddings import EmbeddingEngine

CLAUDE_DIR = Path.home() / ".claude"
CONCEPT_LIBRARY_PATH = CLAUDE_DIR / "config" / "concept-library.json"
PATTERNS_OUTPUT_PATH = CLAUDE_DIR / "config" / "discovered-patterns.json"


def cluster_embeddings(engine, min_cluster_size=3, similarity_threshold=0.75):
    """Cluster similar embeddings using simple agglomerative approach."""
    cursor = engine.conn.cursor()

    cursor.execute('''
        SELECT id, content, type, success_score, project_path, vector
        FROM embeddings
        WHERE vector IS NOT NULL
        AND success_score >= 0.5
        ORDER BY success_score DESC
        LIMIT 500
    ''')

    embeddings_data = cursor.fetchall()

    if len(embeddings_data) < min_cluster_size:
        return []

    clusters = []
    used_ids = set()

    for i, (id1, text1, type1, score1, proj1, emb1) in enumerate(embeddings_data):
        if id1 in used_ids:
            continue

        cluster = {
            'center_id': id1,
            'center_text': text1[:200],
            'embed_type': type1,
            'avg_success': score1,
            'members': [id1],
            'member_texts': [text1[:100]],
            'projects': {proj1}
        }

        for j, (id2, text2, type2, score2, proj2, emb2) in enumerate(embeddings_data[i+1:], i+1):
            if id2 in used_ids:
                continue

            similarity = engine.cosine_similarity(emb1, emb2)

            if similarity >= similarity_threshold:
                cluster['members'].append(id2)
                cluster['member_texts'].append(text2[:100])
                cluster['projects'].add(proj2)
                cluster['avg_success'] = (cluster['avg_success'] * (len(cluster['members']) - 1) + score2) / len(cluster['members'])
                used_ids.add(id2)

        if len(cluster['members']) >= min_cluster_size:
            cluster['projects'] = list(cluster['projects'])
            clusters.append(cluster)
            used_ids.add(id1)

    clusters.sort(key=lambda c: (len(c['members']), c['avg_success']), reverse=True)

    return clusters


def generate_concepts_from_clusters(clusters, min_success=0.7):
    """Generate new concept entries from high-success clusters."""
    new_concepts = []

    for cluster in clusters:
        if cluster['avg_success'] < min_success:
            continue
        if len(cluster['members']) < 3:
            continue

        common_words = extract_common_words(cluster['member_texts'])

        if not common_words:
            continue

        concept_name = f"discovered_{cluster['embed_type']}_{len(new_concepts)+1}"
        concept_text = " ".join(common_words[:15])

        new_concepts.append({
            'name': concept_name,
            'text': concept_text,
            'type': cluster['embed_type'],
            'source_cluster_size': len(cluster['members']),
            'avg_success': round(cluster['avg_success'], 3),
            'cross_project': len(cluster['projects']) > 1,
            'projects': cluster['projects'],
            'discovered_at': datetime.utcnow().isoformat() + 'Z'
        })

    return new_concepts


def extract_common_words(texts, min_frequency=0.5):
    """Extract words that appear in at least min_frequency of texts."""
    word_counts = defaultdict(int)

    for text in texts:
        words = set(text.lower().split())
        for word in words:
            if len(word) > 3 and word.isalpha():
                word_counts[word] += 1

    threshold = len(texts) * min_frequency
    common_words = [word for word, count in word_counts.items() if count >= threshold]

    common_words.sort(key=lambda w: word_counts[w], reverse=True)

    return common_words


def find_cross_project_patterns(engine, min_projects=2):
    """Find patterns that span multiple projects."""
    cursor = engine.conn.cursor()

    cursor.execute('''
        SELECT content, type, AVG(success_score) as avg_score,
               COUNT(DISTINCT project_path) as project_count,
               SUM(cross_project_hits) as total_hits
        FROM embeddings
        WHERE cross_project_hits > 0
        GROUP BY content
        HAVING project_count >= ?
        ORDER BY total_hits DESC, avg_score DESC
        LIMIT 20
    ''', (min_projects,))

    patterns = []
    for row in cursor.fetchall():
        patterns.append({
            'text': row[0][:200],
            'type': row[1],
            'avg_success': round(row[2], 3),
            'project_count': row[3],
            'total_hits': row[4]
        })

    return patterns


def prune_low_value_embeddings(engine, days=30, min_success=0.3):
    """Remove old, low-success embeddings."""
    cursor = engine.conn.cursor()

    cutoff_date = datetime.utcnow() - timedelta(days=days)

    cursor.execute('''
        SELECT COUNT(*) FROM embeddings
        WHERE created_at < ?
        AND success_score < ?
        AND cross_project_hits = 0
    ''', (cutoff_date.isoformat(), min_success))

    count = cursor.fetchone()[0]

    if count > 0:
        cursor.execute('''
            DELETE FROM embeddings
            WHERE created_at < ?
            AND success_score < ?
            AND cross_project_hits = 0
        ''', (cutoff_date.isoformat(), min_success))

        engine.conn.commit()

    return count


def save_discovered_patterns(clusters, concepts, cross_project):
    """Save discovered patterns to JSON file."""
    output = {
        'generated_at': datetime.utcnow().isoformat() + 'Z',
        'clusters': clusters[:20],
        'new_concepts': concepts,
        'cross_project_patterns': cross_project,
        'stats': {
            'total_clusters': len(clusters),
            'new_concepts_count': len(concepts),
            'cross_project_count': len(cross_project)
        }
    }

    with open(PATTERNS_OUTPUT_PATH, 'w') as f:
        json.dump(output, f, indent=2)

    return PATTERNS_OUTPUT_PATH


def update_concept_library(new_concepts):
    """Add discovered concepts to the concept library."""
    if not CONCEPT_LIBRARY_PATH.exists():
        return 0

    with open(CONCEPT_LIBRARY_PATH) as f:
        library = json.load(f)

    if 'discovered_concepts' not in library:
        library['discovered_concepts'] = {
            'description': 'Auto-discovered concepts from pattern emergence',
            'concepts': {}
        }

    added = 0
    for concept in new_concepts:
        name = concept['name']
        if name not in library['discovered_concepts']['concepts']:
            library['discovered_concepts']['concepts'][name] = concept['text']
            added += 1

    with open(CONCEPT_LIBRARY_PATH, 'w') as f:
        json.dump(library, f, indent=2)

    return added


def main():
    parser = argparse.ArgumentParser(description='Pattern Emergence Engine')
    parser.add_argument('command', choices=['cluster', 'generate-concepts', 'cross-project', 'prune', 'full-analysis'])
    parser.add_argument('--days', type=int, default=30, help='Days threshold for pruning')
    parser.add_argument('--min-success', type=float, default=0.3, help='Minimum success score for pruning')
    parser.add_argument('--min-cluster-size', type=int, default=3, help='Minimum cluster size')
    parser.add_argument('--similarity', type=float, default=0.75, help='Similarity threshold for clustering')

    args = parser.parse_args()

    engine = EmbeddingEngine()
    engine.connect()

    try:
        if args.command == 'cluster':
            clusters = cluster_embeddings(engine, args.min_cluster_size, args.similarity)
            print(json.dumps(clusters[:10], indent=2))
            print(f"\nTotal clusters found: {len(clusters)}")

        elif args.command == 'generate-concepts':
            clusters = cluster_embeddings(engine, args.min_cluster_size, args.similarity)
            concepts = generate_concepts_from_clusters(clusters)

            added = update_concept_library(concepts)
            print(json.dumps(concepts, indent=2))
            print(f"\nGenerated {len(concepts)} concepts, added {added} to library")

        elif args.command == 'cross-project':
            patterns = find_cross_project_patterns(engine)
            print(json.dumps(patterns, indent=2))
            print(f"\nFound {len(patterns)} cross-project patterns")

        elif args.command == 'prune':
            count = prune_low_value_embeddings(engine, args.days, args.min_success)
            print(f"Pruned {count} low-value embeddings older than {args.days} days")

        elif args.command == 'full-analysis':
            print("=== Running Full Pattern Analysis ===\n")

            clusters = cluster_embeddings(engine, args.min_cluster_size, args.similarity)
            print(f"1. Found {len(clusters)} clusters")

            concepts = generate_concepts_from_clusters(clusters)
            print(f"2. Generated {len(concepts)} new concepts")

            cross_project = find_cross_project_patterns(engine)
            print(f"3. Found {len(cross_project)} cross-project patterns")

            output_path = save_discovered_patterns(clusters, concepts, cross_project)
            print(f"4. Saved analysis to {output_path}")

            if concepts:
                added = update_concept_library(concepts)
                print(f"5. Added {added} concepts to library")

            count = prune_low_value_embeddings(engine, args.days, args.min_success)
            print(f"6. Pruned {count} low-value embeddings")

            print("\n=== Analysis Complete ===")

    finally:
        engine.close()


if __name__ == "__main__":
    main()
