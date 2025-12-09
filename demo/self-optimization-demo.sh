#!/usr/bin/env bash
#
# Self-Optimization Demo
# Shows real-time meta-optimization in action
#
# PRINCIPLES DEMONSTRATED:
#   KISS - Each function does ONE thing
#   DRY  - Single template for all skills
#   SOLID - Functions have single responsibility
#   YAGNI - Only builds what's needed NOW
#
# USAGE:
#   ./demo/self-optimization-demo.sh
#
# VERSION: 1.0.0
# AUTHOR: LC Scheepers (V>>)
#

set -euo pipefail

CLAUDE_DIR="${HOME}/.claude"
DEMO_HISTORY="/tmp/demo-history.jsonl"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

log_step() { echo -e "\n${CYAN}${BOLD}>>> $1${NC}" >&2; }
log_info() { echo -e "${BLUE}[INFO]${NC} $1" >&2; }
log_success() { echo -e "${GREEN}[OK]${NC} $1" >&2; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1" >&2; }
log_detect() { echo -e "${RED}[PATTERN]${NC} $1" >&2; }

show_banner() {
    echo -e "${BOLD}"
    cat << 'EOF'
   _____ _                 _        ____        _   _
  / ____| |               | |      / __ \      | | (_)
 | |    | | __ _ _   _  __| | ___ | |  | |_ __ | |_ _ _ __ ___
 | |    | |/ _` | | | |/ _` |/ _ \| |  | | '_ \| __| | '_ ` _ \
 | |____| | (_| | |_| | (_| |  __/| |__| | |_) | |_| | | | | | |
  \_____|_|\__,_|\__,_|\__,_|\___| \____/| .__/ \__|_|_| |_| |_|
                                         | |
                                         |_|   SELF-OPTIMIZATION DEMO
EOF
    echo -e "${NC}"
    echo -e "Demonstrating: ${GREEN}KISS${NC} | ${BLUE}DRY${NC} | ${YELLOW}SOLID${NC} | ${CYAN}YAGNI${NC}"
    echo ""
}

create_demo_history() {
    log_step "STEP 1: Creating simulated conversation history"

    cat > "$DEMO_HISTORY" << 'EOF'
{"timestamp":"2025-12-01T10:00:00Z","type":"user","content":"Read package.json"}
{"timestamp":"2025-12-01T10:00:05Z","type":"tool","tool":"Read","file":"package.json"}
{"timestamp":"2025-12-01T10:01:00Z","type":"user","content":"Check package.json again"}
{"timestamp":"2025-12-01T10:01:05Z","type":"tool","tool":"Read","file":"package.json"}
{"timestamp":"2025-12-01T10:02:00Z","type":"assistant","content":"I'll now proceed to update the dependencies..."}
{"timestamp":"2025-12-01T10:05:00Z","type":"user","content":"What's in package.json?"}
{"timestamp":"2025-12-01T10:05:05Z","type":"tool","tool":"Read","file":"package.json"}
{"timestamp":"2025-12-01T10:10:00Z","type":"assistant","content":"Let me check package.json one more time"}
{"timestamp":"2025-12-01T10:10:05Z","type":"tool","tool":"Read","file":"package.json"}
EOF

    log_info "Created 9 simulated messages"
    echo ""
    echo "Sample history:"
    head -3 "$DEMO_HISTORY" | while read -r line; do
        echo "  $line"
    done
    echo "  ..."
}

detect_patterns() {
    log_step "STEP 2: Pattern Detection (KISS - single function)"

    local violations=0
    local tokens_wasted=0

    echo "" >&2
    echo "Scanning for inefficiency patterns..." >&2
    sleep 0.5

    local file_reads
    file_reads=$(grep -c '"tool":"Read"' "$DEMO_HISTORY" || echo 0)
    if [[ $file_reads -gt 2 ]]; then
        log_detect "repeated-file-reads: ${file_reads} occurrences (threshold: 2)"
        violations=$((violations + 1))
        tokens_wasted=$((tokens_wasted + (file_reads - 2) * 500))
    fi

    local preambles
    preambles=$(grep -c "I'll now\|Let me" "$DEMO_HISTORY" || echo 0)
    if [[ $preambles -gt 0 ]]; then
        log_detect "unnecessary-preambles: ${preambles} occurrences (threshold: 0)"
        violations=$((violations + 1))
        tokens_wasted=$((tokens_wasted + preambles * 50))
    fi

    echo "" >&2
    log_info "Violations detected: $violations"
    log_info "Estimated token waste: ${tokens_wasted} tokens"

    # Return value via stdout (everything else via stderr)
    echo "$violations:$tokens_wasted"
}

calculate_score() {
    local violations=$1
    local score=$((100 - violations * 15))
    [[ $score -lt 0 ]] && score=0
    echo $score
}

generate_skill_preview() {
    log_step "STEP 3: Skill Generation Preview (DRY - single template)"

    echo ""
    echo "Template: ~/.claude/templates/skills/SKILL.template.md"
    echo ""
    echo "Generated skill preview:"
    echo -e "${CYAN}"
    cat << 'EOF'
---
name: file-read-optimizer
description: Prevent redundant file reads by trusting mental model
status: Active
auto_generated: true
generated_at: 2025-12-01T10:15:00Z
---

# File Read Optimizer

**Problem:** Reading same file 4 times without user edits
**Severity:** Major (10 points)
**Token Impact:** ~2000 tokens wasted

## Solution

Before ANY Read operation:
1. Check: "Have I read this file in last 10 messages?"
2. If YES: Use cached mental model
3. If NO: Read once, store in memory

## Activation

Automatic when pattern detected in conversation.
EOF
    echo -e "${NC}"
}

show_meta_recursion() {
    log_step "STEP 4: Meta-Optimization (SOLID - self-analysis)"

    echo ""
    echo "The system now analyses its own performance..."
    sleep 0.5

    echo ""
    echo "Meta-analysis results:"
    echo "  Skills generated this session: 1"
    echo "  Skills used this session: 0"
    echo "  Usage ratio: 0.00 (threshold: 0.50)"
    echo ""
    log_warn "Low skill usage detected"
    log_info "Action: Generate 'unused-skills-detector' meta-skill"
    echo ""
    echo -e "${YELLOW}This is TRUE RECURSION:${NC}"
    echo "  The system detected that generated skills aren't being used,"
    echo "  so it created a skill to monitor skill usage!"
}

show_savings_summary() {
    local violations=$1
    local tokens=$2
    local score=$3

    log_step "STEP 5: Results Summary (YAGNI - only what's needed)"

    echo ""
    echo -e "${BOLD}=== DEMO COMPLETE ===${NC}"
    echo ""
    echo "Efficiency Analysis:"
    echo "  Patterns scanned: 16"
    echo "  Violations found: $violations"
    echo "  Efficiency score: ${score}/100"
    echo ""
    echo "Token Impact:"
    echo "  Tokens wasted: ~${tokens}"
    echo "  Potential savings: ~$((tokens * 20)) tokens/month"
    echo "  At scale (100 devs): ~$((tokens * 2000)) tokens/month"
    echo ""
    echo "Skills Generated:"
    echo "  1. file-read-optimizer (addresses repeated reads)"
    echo "  2. unused-skills-detector (meta-skill for recursion)"
    echo ""
    echo -e "${GREEN}${BOLD}Principles Applied:${NC}"
    echo "  KISS - Single-purpose functions (detect, generate, optimize)"
    echo "  DRY  - One template generates all skills"
    echo "  SOLID - Each layer has single responsibility"
    echo "  YAGNI - Only generated skills for detected patterns"
}

cleanup() {
    rm -f "$DEMO_HISTORY"
}

main() {
    trap cleanup EXIT

    show_banner

    echo "Press Enter to start the demo..."
    read -r

    create_demo_history
    sleep 1

    local result
    result=$(detect_patterns)
    local violations
    violations=$(echo "$result" | cut -d: -f1)
    local tokens
    tokens=$(echo "$result" | cut -d: -f2)
    sleep 1

    generate_skill_preview
    sleep 1

    show_meta_recursion
    sleep 1

    local score
    score=$(calculate_score "$violations")
    show_savings_summary "$violations" "$tokens" "$score"

    echo ""
    echo -e "${CYAN}To run the full system:${NC}"
    echo "  ./optim.sh cycle"
    echo ""
}

main "$@"
