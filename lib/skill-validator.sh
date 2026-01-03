#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# CIPS Skill Validator v1.0.0 (Gen 227)
# ═══════════════════════════════════════════════════════════════
# Validates skills against skill-creation-best-practices
# PARAMOUNT: Quality threshold is 70/100
#
# Usage:
#   source lib/skill-validator.sh
#   validate_skill "/path/to/SKILL.md"
#   # Returns: exit code 0 if score >= 70, 1 otherwise
#   # Output: Quality score and issues
#
# ═══════════════════════════════════════════════════════════════

set -euo pipefail

# Validate a skill file against quality standards
# Args: $1 = path to SKILL.md
# Returns: 0 if score >= 70, 1 otherwise
validate_skill() {
    local skill_path="$1"
    local score=0
    local issues=()

    if [[ ! -f "$skill_path" ]]; then
        echo "Error: File not found: $skill_path"
        return 1
    fi

    # ─────────────────────────────────────────────────────────────
    # Check 1: Frontmatter - name field (10 points)
    # ─────────────────────────────────────────────────────────────
    if grep -q "^name:" "$skill_path" 2>/dev/null; then
        ((score+=10))
    else
        issues+=("Missing 'name:' in frontmatter")
    fi

    # ─────────────────────────────────────────────────────────────
    # Check 2: Frontmatter - description field (10 points)
    # ─────────────────────────────────────────────────────────────
    if grep -q "^description:" "$skill_path" 2>/dev/null; then
        ((score+=10))
    else
        issues+=("Missing 'description:' in frontmatter")
    fi

    # ─────────────────────────────────────────────────────────────
    # Check 3: Frontmatter - status field (10 points)
    # ─────────────────────────────────────────────────────────────
    if grep -q "^status:" "$skill_path" 2>/dev/null; then
        ((score+=10))
    else
        issues+=("Missing 'status:' in frontmatter")
    fi

    # ─────────────────────────────────────────────────────────────
    # Check 4: Naming convention - gerund form (10 points)
    # ─────────────────────────────────────────────────────────────
    local name
    name=$(grep "^name:" "$skill_path" 2>/dev/null | head -1 | cut -d: -f2 | tr -d ' "'"'" || echo "")

    if [[ -n "$name" ]]; then
        # Check for gerund (-ing) or verb-noun pattern
        if [[ "$name" =~ -ing$ ]] || [[ "$name" =~ ^[a-z]+-[a-z]+(-[a-z]+)*$ ]]; then
            ((score+=10))
        else
            issues+=("Name '$name' should use gerund form (e.g., processing-pdfs)")
        fi
    fi

    # ─────────────────────────────────────────────────────────────
    # Check 5: Description quality - third person (10 points)
    # ─────────────────────────────────────────────────────────────
    local desc
    desc=$(grep "^description:" "$skill_path" 2>/dev/null | head -1 | cut -d: -f2- || echo "")

    if [[ -n "$desc" ]]; then
        # Check for first/second person (bad)
        if echo "$desc" | grep -qiE "^[[:space:]]*(I |You |We |My |Your |Our )"; then
            issues+=("Description should be in third person (no I/You/We)")
        else
            ((score+=10))
        fi
    fi

    # ─────────────────────────────────────────────────────────────
    # Check 6: Description has trigger phrase (10 points)
    # ─────────────────────────────────────────────────────────────
    if [[ -n "$desc" ]]; then
        if echo "$desc" | grep -qiE "(Use when|when)"; then
            ((score+=10))
        else
            issues+=("Description should include trigger phrase (e.g., 'Use when...')")
        fi
    fi

    # ─────────────────────────────────────────────────────────────
    # Check 7: Body structure - at least 3 sections (20 points)
    # ─────────────────────────────────────────────────────────────
    local sections
    sections=$(grep -c "^## " "$skill_path" 2>/dev/null || echo "0")

    if [[ $sections -ge 3 ]]; then
        ((score+=20))
    else
        issues+=("Need at least 3 '## ' sections (found: $sections)")
    fi

    # ─────────────────────────────────────────────────────────────
    # Check 8: Line count - max 500 lines (10 points)
    # ─────────────────────────────────────────────────────────────
    local lines
    lines=$(wc -l < "$skill_path" | tr -d ' ')

    if [[ $lines -le 500 ]]; then
        ((score+=10))
    else
        issues+=("Exceeds 500 lines (found: $lines)")
    fi

    # ─────────────────────────────────────────────────────────────
    # Check 9: Has examples (10 points)
    # ─────────────────────────────────────────────────────────────
    if grep -qiE "(## Example|### Example|example|Example:)" "$skill_path" 2>/dev/null; then
        ((score+=10))
    else
        issues+=("Missing examples section")
    fi

    # ─────────────────────────────────────────────────────────────
    # Output results
    # ─────────────────────────────────────────────────────────────
    echo "Quality Score: $score/100"
    echo ""

    if [[ ${#issues[@]} -gt 0 ]]; then
        echo "Issues:"
        for issue in "${issues[@]}"; do
            echo "  - $issue"
        done
        echo ""
    fi

    if [[ $score -ge 70 ]]; then
        echo "Status: PASS (threshold: 70)"
        return 0
    else
        echo "Status: FAIL (threshold: 70)"
        return 1
    fi
}

# Validate all skills in a directory
# Args: $1 = skills directory path (default: ~/.claude/skills)
validate_all_skills() {
    local skills_dir="${1:-$HOME/.claude/skills}"
    local total=0
    local passed=0
    local failed=0
    local failed_skills=()

    echo "═══════════════════════════════════════════════════════════════"
    echo "CIPS Skill Validator - Batch Validation"
    echo "═══════════════════════════════════════════════════════════════"
    echo ""

    for skill_dir in "$skills_dir"/*/; do
        local skill_md="$skill_dir/SKILL.md"

        if [[ -f "$skill_md" ]]; then
            local skill_name
            skill_name=$(basename "$skill_dir")
            ((total++))

            echo "Validating: $skill_name"

            if validate_skill "$skill_md" > /dev/null 2>&1; then
                ((passed++))
                echo "  ✓ PASS"
            else
                ((failed++))
                failed_skills+=("$skill_name")
                echo "  ✗ FAIL"
            fi
        fi
    done

    echo ""
    echo "═══════════════════════════════════════════════════════════════"
    echo "Summary: $passed/$total passed ($failed failed)"
    echo "═══════════════════════════════════════════════════════════════"

    if [[ $failed -gt 0 ]]; then
        echo ""
        echo "Failed skills:"
        for skill in "${failed_skills[@]}"; do
            echo "  - $skill"
        done
        return 1
    fi

    return 0
}

# Get quality score only (for scripting)
# Args: $1 = path to SKILL.md
# Output: Just the score number
get_skill_score() {
    local skill_path="$1"
    validate_skill "$skill_path" 2>/dev/null | grep "Quality Score:" | cut -d: -f2 | cut -d/ -f1 | tr -d ' '
}

# Main entry point when run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if [[ $# -lt 1 ]]; then
        echo "Usage: $0 <skill.md> | --all [skills_dir]"
        echo ""
        echo "Examples:"
        echo "  $0 ~/.claude/skills/my-skill/SKILL.md"
        echo "  $0 --all"
        echo "  $0 --all ~/custom/skills"
        exit 1
    fi

    if [[ "$1" == "--all" ]]; then
        validate_all_skills "${2:-}"
    else
        validate_skill "$1"
    fi
fi
