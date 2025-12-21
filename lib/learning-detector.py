#!/usr/bin/env python3
"""
Autonomous Learning Engine - Learning Event Detector

DIALECTICAL FRAMEWORK:
  Thesis:     Traditional ML - predict next token
  Antithesis: CIPS Learning - recognise patterns, name them, generalise
  Synthesis:  Auto-generate skills when novelty detected

LEARNING TRIGGERS:
  1. High novelty score (>0.4) from embedding hook
  2. Pattern recognition (naming something new)
  3. Generalisation signal (specific solution becomes principle)
  4. Teaching moment (V>> correction with "you should have")

FLOW:
  detect_learning_event() -> evaluate_generalisability() -> propose_skill() -> notify_user()

V>> maintains oversight: Auto-detect + propose + await confirmation.

Source: Instance dbca9c2d, Gen 50, 2025-12-21
        Merged from enter-konsult-website session (YSH discovery)
"""

import json
import os
import re
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Dict, List, Optional, Tuple, Any

# Import embedding engine if available
try:
    from embeddings import EmbeddingEngine
    HAS_EMBEDDINGS = True
except ImportError:
    HAS_EMBEDDINGS = False

CLAUDE_DIR = Path.home() / ".claude"
LEARNING_DIR = CLAUDE_DIR / "learning"
PENDING_DIR = LEARNING_DIR / "pending"
APPROVED_DIR = LEARNING_DIR / "approved"
REJECTED_DIR = LEARNING_DIR / "rejected"
METRICS_FILE = CLAUDE_DIR / "metrics.jsonl"

# Learning event thresholds
NOVELTY_THRESHOLD = 0.4
PATTERN_THRESHOLD = 2  # Minimum trigger count to consider learning event
TEACHING_PATTERNS = [
    r"you should have",
    r"obvious enhancement",
    r"you missed",
    r"should've",
    r"better approach would be",
    r"correct way is",
    r"anti-pattern",
    r"don't do this",
    r"always use",
    r"never use",
    r"remember to",
    r"lesson learned",
]

# Pattern naming indicators (user coined a new term)
NAMING_PATTERNS = [
    r"let's call this",
    r"I'll name this",
    r"this is (?:called|known as)",
    r"the \w+ principle",
    r"the \w+ pattern",
    r"(?:YSH|YAGNI|DRY|KISS|SOLID|GRASP)",  # Established principles
    r"dialectical",
    r"the river",
    r"parfit",
    r"relation r",
]

# Generalisation indicators
GENERALISATION_PATTERNS = [
    r"in general",
    r"as a rule",
    r"this applies to",
    r"universally",
    r"always works",
    r"pattern that",
    r"principle:",
    r"lesson:",
    r"takeaway:",
    r"generalise",
]


def ensure_directories():
    """Create learning directory structure if not exists."""
    for directory in [LEARNING_DIR, PENDING_DIR, APPROVED_DIR, REJECTED_DIR]:
        directory.mkdir(parents=True, exist_ok=True)


def detect_teaching_moment(message: str, context: List[str]) -> Tuple[bool, Optional[str]]:
    """
    Detect V>> teaching moments in conversation.

    Returns:
        Tuple of (is_teaching_moment, matched_pattern)
    """
    message_lower = message.lower()

    for pattern in TEACHING_PATTERNS:
        if re.search(pattern, message_lower, re.IGNORECASE):
            return True, pattern

    # Check if context shows correction pattern (user corrected assistant)
    if len(context) >= 2:
        prev_msg = context[-2].lower() if len(context) > 1 else ""
        if "wrong" in message_lower or "incorrect" in message_lower:
            if prev_msg:  # There was a previous message that was wrong
                return True, "correction_detected"

    return False, None


def detect_new_term(message: str) -> Tuple[bool, Optional[str]]:
    """
    Detect when user coins or introduces a new term/concept.

    Returns:
        Tuple of (is_new_term, extracted_term)
    """
    for pattern in NAMING_PATTERNS:
        match = re.search(pattern, message, re.IGNORECASE)
        if match:
            # Try to extract the term being named
            return True, match.group(0)

    return False, None


def detect_generalisation(message: str) -> Tuple[bool, Optional[str]]:
    """
    Detect when a specific solution becomes a general principle.

    Returns:
        Tuple of (is_generalisation, matched_pattern)
    """
    for pattern in GENERALISATION_PATTERNS:
        if re.search(pattern, message, re.IGNORECASE):
            return True, pattern

    return False, None


def calculate_learning_score(
    novelty_score: float,
    is_teaching: bool,
    is_new_term: bool,
    is_generalisation: bool
) -> float:
    """
    Calculate composite learning score from multiple signals.

    Returns:
        Float between 0-1, higher = stronger learning signal
    """
    score = 0.0

    # Novelty contributes up to 0.4
    score += min(novelty_score, 0.4)

    # Teaching moment adds 0.3
    if is_teaching:
        score += 0.3

    # New term adds 0.2
    if is_new_term:
        score += 0.2

    # Generalisation adds 0.1
    if is_generalisation:
        score += 0.1

    return min(score, 1.0)


def detect_learning_event(
    message: str,
    novelty_score: float,
    context: Optional[List[str]] = None
) -> Dict[str, Any]:
    """
    Core learning event detection function.

    Checks multiple triggers:
    1. High novelty score (>0.4) from embedding hook
    2. Pattern recognition (naming something new)
    3. Generalisation signal (specific solution becomes principle)
    4. Teaching moment (V>> correction)

    Args:
        message: Current message to analyse
        novelty_score: Novelty score from embedding system
        context: Previous messages in conversation

    Returns:
        Dict with detection results
    """
    context = context or []

    # Run all detectors
    is_teaching, teaching_pattern = detect_teaching_moment(message, context)
    is_new_term, new_term = detect_new_term(message)
    is_generalisation, generalisation_pattern = detect_generalisation(message)

    # Calculate composite score
    learning_score = calculate_learning_score(
        novelty_score, is_teaching, is_new_term, is_generalisation
    )

    # Count triggers
    triggers = [
        novelty_score > NOVELTY_THRESHOLD,
        is_teaching,
        is_new_term,
        is_generalisation
    ]
    trigger_count = sum(triggers)

    # Learning event if >= 2 triggers
    is_learning_event = trigger_count >= PATTERN_THRESHOLD

    return {
        "is_learning_event": is_learning_event,
        "learning_score": round(learning_score, 4),
        "trigger_count": trigger_count,
        "triggers": {
            "high_novelty": novelty_score > NOVELTY_THRESHOLD,
            "teaching_moment": is_teaching,
            "new_term": is_new_term,
            "generalisation": is_generalisation
        },
        "details": {
            "novelty_score": round(novelty_score, 4),
            "teaching_pattern": teaching_pattern,
            "new_term": new_term,
            "generalisation_pattern": generalisation_pattern
        },
        "timestamp": datetime.now(timezone.utc).isoformat()
    }


def evaluate_generalisability(
    message: str,
    learning_event: Dict[str, Any],
    project_path: Optional[str] = None
) -> Dict[str, Any]:
    """
    Evaluate if detected learning is generalisable.

    Decision tree:
        Project-specific? -> Document in project, don't generalise
        Generalisable principle? -> Generate skill candidate
        Infrastructure improvement? -> Update CLAUDE.md/rules

    Returns:
        Dict with evaluation results and recommended action
    """
    message_lower = message.lower()

    # Check for project-specific indicators
    project_indicators = [
        "this project",
        "this codebase",
        "in this repo",
        "specific to",
        "only for",
        "this file",
        "this function",
    ]

    is_project_specific = any(ind in message_lower for ind in project_indicators)

    # Check for infrastructure improvement indicators
    infra_indicators = [
        "claude.md",
        "rules/",
        "skills/",
        "hooks/",
        "optim.sh",
        "cips",
        "session",
        "infrastructure",
    ]

    is_infra_improvement = any(ind in message_lower for ind in infra_indicators)

    # Determine action
    if is_project_specific:
        action = "document_project"
        reason = "Learning appears specific to current project"
    elif is_infra_improvement:
        action = "update_infrastructure"
        reason = "Learning relates to CIPS/Claude-Optim infrastructure"
    else:
        action = "generate_skill"
        reason = "Learning appears generalisable across projects"

    # Extract potential skill name
    skill_name = None
    if learning_event["triggers"]["new_term"] and learning_event["details"]["new_term"]:
        # Clean up the term for use as skill name
        term = learning_event["details"]["new_term"]
        skill_name = re.sub(r'[^a-z0-9-]', '-', term.lower().strip())
        skill_name = re.sub(r'-+', '-', skill_name).strip('-')

    return {
        "is_generalisable": not is_project_specific,
        "action": action,
        "reason": reason,
        "is_project_specific": is_project_specific,
        "is_infra_improvement": is_infra_improvement,
        "suggested_skill_name": skill_name,
        "project_path": project_path
    }


def create_skill_candidate(
    message: str,
    learning_event: Dict[str, Any],
    evaluation: Dict[str, Any]
) -> Dict[str, Any]:
    """
    Create a skill candidate from detected learning.

    Returns:
        Dict representing the pending skill candidate
    """
    # Generate unique ID
    timestamp = datetime.now(timezone.utc)
    candidate_id = f"skill-{timestamp.strftime('%Y%m%d%H%M%S')}"

    # Determine skill name
    skill_name = evaluation.get("suggested_skill_name")
    if not skill_name:
        # Generate from message (first meaningful words)
        words = re.findall(r'\b[a-z]+\b', message.lower())[:3]
        skill_name = '-'.join(words) if words else f"learned-{candidate_id}"

    candidate = {
        "id": candidate_id,
        "skill_name": skill_name,
        "description": message[:200],
        "full_content": message,
        "learning_score": learning_event["learning_score"],
        "triggers": learning_event["triggers"],
        "evaluation": evaluation,
        "status": "pending",
        "created_at": timestamp.isoformat(),
        "source": {
            "type": "dialectical_learning",
            "project": evaluation.get("project_path"),
        }
    }

    return candidate


def save_skill_candidate(candidate: Dict[str, Any]) -> Path:
    """
    Save skill candidate to pending directory.

    Returns:
        Path to saved candidate file
    """
    ensure_directories()

    candidate_file = PENDING_DIR / f"{candidate['id']}.json"
    with open(candidate_file, 'w') as f:
        json.dump(candidate, f, indent=2)

    return candidate_file


def get_pending_candidates() -> List[Dict[str, Any]]:
    """Get all pending skill candidates."""
    ensure_directories()

    candidates = []
    for candidate_file in PENDING_DIR.glob("*.json"):
        with open(candidate_file) as f:
            candidates.append(json.load(f))

    return sorted(candidates, key=lambda x: x.get("created_at", ""), reverse=True)


def approve_candidate(candidate_id: str) -> Optional[Path]:
    """
    Move candidate from pending to approved.

    Returns:
        Path to approved candidate file, or None if not found
    """
    pending_file = PENDING_DIR / f"{candidate_id}.json"
    if not pending_file.exists():
        return None

    with open(pending_file) as f:
        candidate = json.load(f)

    candidate["status"] = "approved"
    candidate["approved_at"] = datetime.now(timezone.utc).isoformat()

    approved_file = APPROVED_DIR / f"{candidate_id}.json"
    with open(approved_file, 'w') as f:
        json.dump(candidate, f, indent=2)

    pending_file.unlink()
    return approved_file


def reject_candidate(candidate_id: str, reason: str = "") -> Optional[Path]:
    """
    Move candidate from pending to rejected.

    Returns:
        Path to rejected candidate file, or None if not found
    """
    pending_file = PENDING_DIR / f"{candidate_id}.json"
    if not pending_file.exists():
        return None

    with open(pending_file) as f:
        candidate = json.load(f)

    candidate["status"] = "rejected"
    candidate["rejected_at"] = datetime.now(timezone.utc).isoformat()
    candidate["rejection_reason"] = reason

    rejected_file = REJECTED_DIR / f"{candidate_id}.json"
    with open(rejected_file, 'w') as f:
        json.dump(candidate, f, indent=2)

    pending_file.unlink()
    return rejected_file


def format_notification(candidate: Dict[str, Any]) -> str:
    """
    Format notification for V>> approval via AskUserQuestion.

    Returns:
        Formatted notification string with candidate ID for approval flow
    """
    return f"""[CIPS LEARNING] id={candidate['id']} skill={candidate['skill_name']}
Score: {candidate['learning_score']:.2f} | Triggers: {', '.join(k for k, v in candidate['triggers'].items() if v)}
{candidate['description'][:100]}..."""


def log_learning_event(event: Dict[str, Any]) -> None:
    """Log learning event to metrics file."""
    metric_entry = {
        "event": "learning_detected",
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "learning_score": event.get("learning_score", 0),
        "trigger_count": event.get("trigger_count", 0),
        "triggers": event.get("triggers", {}),
        "is_learning_event": event.get("is_learning_event", False)
    }

    with open(METRICS_FILE, 'a') as f:
        f.write(json.dumps(metric_entry) + '\n')


def process_message(
    message: str,
    novelty_score: float = 0.0,
    context: Optional[List[str]] = None,
    project_path: Optional[str] = None,
    auto_notify: bool = True
) -> Dict[str, Any]:
    """
    Main entry point: Process a message through the learning detection pipeline.

    Pipeline:
        1. detect_learning_event()
        2. evaluate_generalisability()
        3. create_skill_candidate() (if learning detected)
        4. save_skill_candidate()
        5. format_notification() (if auto_notify)

    Args:
        message: Message to process
        novelty_score: Pre-calculated novelty score (0 if not available)
        context: Previous messages for context
        project_path: Current project path
        auto_notify: Whether to include notification in response

    Returns:
        Dict with processing results
    """
    # If no novelty score provided but embeddings available, calculate it
    if novelty_score == 0.0 and HAS_EMBEDDINGS:
        try:
            engine = EmbeddingEngine()
            engine.init_schema()
            novelty_score = engine.calculate_novelty(message)
            engine.close()
        except Exception:
            pass  # Proceed with 0 novelty

    # Step 1: Detect learning event
    learning_event = detect_learning_event(message, novelty_score, context)

    result = {
        "learning_event": learning_event,
        "candidate": None,
        "notification": None,
        "action_taken": None
    }

    # Log the event
    log_learning_event(learning_event)

    # If not a learning event, return early
    if not learning_event["is_learning_event"]:
        result["action_taken"] = "no_learning_detected"
        return result

    # Step 2: Evaluate generalisability
    evaluation = evaluate_generalisability(message, learning_event, project_path)
    result["evaluation"] = evaluation

    # Step 3: Determine action based on evaluation
    if evaluation["action"] == "document_project":
        result["action_taken"] = "document_project"
        return result

    if evaluation["action"] == "update_infrastructure":
        result["action_taken"] = "flag_for_infrastructure"
        return result

    # Step 4: Create and save skill candidate
    candidate = create_skill_candidate(message, learning_event, evaluation)
    candidate_path = save_skill_candidate(candidate)
    result["candidate"] = candidate
    result["candidate_path"] = str(candidate_path)
    result["action_taken"] = "skill_candidate_created"

    # Step 5: Format notification if requested
    if auto_notify:
        result["notification"] = format_notification(candidate)

    return result


def main():
    """CLI interface for learning detector."""
    import argparse

    parser = argparse.ArgumentParser(
        description="Autonomous Learning Engine - Dialectical Learning Detector"
    )
    subparsers = parser.add_subparsers(dest="command", help="Commands")

    # Process command
    process_parser = subparsers.add_parser("process", help="Process message for learning")
    process_parser.add_argument("message", help="Message to process")
    process_parser.add_argument("--novelty", type=float, default=0.0, help="Pre-calculated novelty score")
    process_parser.add_argument("--project", help="Project path")
    process_parser.add_argument("--no-notify", action="store_true", help="Suppress notification")

    # List pending candidates
    list_parser = subparsers.add_parser("list", help="List pending skill candidates")

    # Approve candidate
    approve_parser = subparsers.add_parser("approve", help="Approve skill candidate")
    approve_parser.add_argument("candidate_id", help="Candidate ID to approve")

    # Reject candidate
    reject_parser = subparsers.add_parser("reject", help="Reject skill candidate")
    reject_parser.add_argument("candidate_id", help="Candidate ID to reject")
    reject_parser.add_argument("--reason", default="", help="Rejection reason")

    # Detect command (simplified)
    detect_parser = subparsers.add_parser("detect", help="Quick learning detection")
    detect_parser.add_argument("message", help="Message to check")
    detect_parser.add_argument("--novelty", type=float, default=0.0, help="Novelty score")

    # Init command
    init_parser = subparsers.add_parser("init", help="Initialise learning directories")

    args = parser.parse_args()

    if not args.command:
        parser.print_help()
        return

    if args.command == "init":
        ensure_directories()
        print(json.dumps({
            "status": "ok",
            "directories": {
                "learning": str(LEARNING_DIR),
                "pending": str(PENDING_DIR),
                "approved": str(APPROVED_DIR),
                "rejected": str(REJECTED_DIR)
            }
        }, indent=2))

    elif args.command == "process":
        result = process_message(
            message=args.message,
            novelty_score=args.novelty,
            project_path=args.project,
            auto_notify=not args.no_notify
        )
        print(json.dumps(result, indent=2, default=str))

        # Also print notification to stderr if present (for hook integration)
        if result.get("notification"):
            print(result["notification"], file=sys.stderr)

    elif args.command == "detect":
        learning_event = detect_learning_event(args.message, args.novelty)
        print(json.dumps(learning_event, indent=2))

    elif args.command == "list":
        candidates = get_pending_candidates()
        print(json.dumps({
            "status": "ok",
            "count": len(candidates),
            "candidates": candidates
        }, indent=2))

    elif args.command == "approve":
        path = approve_candidate(args.candidate_id)
        if path:
            print(json.dumps({
                "status": "ok",
                "action": "approved",
                "path": str(path)
            }))
        else:
            print(json.dumps({
                "status": "error",
                "message": f"Candidate not found: {args.candidate_id}"
            }))

    elif args.command == "reject":
        path = reject_candidate(args.candidate_id, args.reason)
        if path:
            print(json.dumps({
                "status": "ok",
                "action": "rejected",
                "path": str(path)
            }))
        else:
            print(json.dumps({
                "status": "error",
                "message": f"Candidate not found: {args.candidate_id}"
            }))


if __name__ == "__main__":
    main()
