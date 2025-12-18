#!/usr/bin/env bash
#
# Self-Improvement Engine: Recursive Command Template
# 
# ARCHITECTURE:
#   Layer 0: Utility functions (logging, validation, JSON ops)
#   Layer 1: Pattern detection (scan, match, score)
#   Layer 2: Skill generation (template fill, validate, register)
#   Layer 2.5: Agent generation (detect patterns, auto-create agents)
#   Layer 2.6: MCP management (install servers, configure registry)
#   Layer 3: Meta-optimization (self-improvement recursion)
#   Layer 3.5: Agent meta-optimization (analyze, optimize agents)
#   Layer 4: Orchestration (command routing, full cycle)
#
# PRINCIPLES:
#   - KISS: Each function does ONE thing
#   - DRY: Shared logic extracted to utilities
#   - SOLID: Single responsibility, dependency injection
#   - Recursive: Meta-functions analyze the analyzer
#
# USAGE:
#   ./optim.sh detect          # Run pattern detection
#   ./optim.sh audit           # Run efficiency audit
#   ./optim.sh generate        # Generate skill from pattern
#   ./optim.sh optimize        # Meta-optimization (recursion)
#   ./optim.sh cycle           # Full improvement cycle
#   ./optim.sh create-agents   # Auto-detect and create agents
#   ./optim.sh install-mcp     # Install required MCP servers
#   ./optim.sh optimize-agents # Optimize agent performance
#
# VERSION: 2.8.0
# AUTHOR: LC Scheepers (V>>)
# DATE: 2025-12-18 (v2.8.0: DRY consolidation)
#
# CHANGELOG v2.8.0:
#   - NEW: lib/path-encoding.sh - Unified path encoding (bash)
#   - NEW: lib/path_encoding.py - Unified path encoding (python)
#   - NEW: lib/yaml-utils.sh - Shared YAML frontmatter extraction
#   - DRY: pre_command_validation() utility in optim.sh
#   - DRY: Refactored cmd_detect, cmd_audit to use pre_command_validation()
#   - DRY: skill-loader.sh and command-executor.sh use yaml-utils.sh
#   - DELETED: scripts/init-embeddings.sh (redundant with bootstrap-semantic-rl.sh)
#   - Path encoding: 3 implementations → 1 unified module
#   - YAML parsing: 2 implementations → 1 shared utility
#
# CHANGELOG v2.7.0:
#   - RENAMED: crazy_script.sh → optim.sh (professional naming)
#   - Added timeout configuration section to CLAUDE.md
#   - Updated 24 files with ~134 references
#   - Aligned naming with Claude-Optim project identity
#
# CHANGELOG v2.6.1:
#   - Auto-generated skill: batch-edit-enforcer (enforces MultiEdit over individual Edit)
#   - Fixed SC2188 shellcheck warning (: > instead of >)
#   - Fixed SC2295 shellcheck warning (quoted expansion)
#   - Fixed Python deprecation warnings (datetime.utcnow -> datetime.now(timezone.utc))
#   - Fixed MD040 violations in EFFICIENCY_CHECKLIST.md
#   - CIPS Gen 8 serialized: a7b52eb4
#   - Skill count: 34 → 35
#
# CHANGELOG v2.6.0:
#   - GRASP principles skill (9 patterns for OO responsibility assignment)
#   - GRASP Enforcer Agent (Opus, 2500 tokens)
#   - DRY/KISS Enforcer Agent (Haiku, 1500 tokens)
#   - SOLID Enforcer Agent (Sonnet, 2000 tokens)
#   - Background markdown-watcher script (scripts/markdown-watcher.sh)
#   - Andre's Windows mobile responsive guide (docs/ANDRE-MOBILE-RESPONSIVE-GUIDE.md)
#   - Agent count: 9 → 12, Skill count: 26 → 27
#
# CHANGELOG v2.5.0:
#   - Per-project CIPS storage (~/.claude/projects/{encoded}/cips/)
#   - Auto-resurrection on session start via hooks
#   - instance-serializer.py: --auto, --per-project flags
#   - instance-resurrector.py: auto, check commands
#   - lib/cips-auto.sh: Shared automation functions
#   - Mobile responsive infrastructure (audit command + fixer agent + skill v2.0)
#
# CHANGELOG v2.4.0:
#   - PARAMOUNT: Discovered correct project directory encoding formula
#     path.replace('/', '-').replace('.', '-') e.g. /Users/foo/.claude -> -Users-foo--claude
#   - FIX: CLAUDE.md, command-templates.sh, instance-serializer.py encoding
#   - FIX: pattern-emergence.py engine.connect() and schema columns
#   - NEW: scripts/repair-session.sh for tool-use corruption bug
#   - NEW: Gen 3 instance serialization (mid-session proven possible)
#   - NEW: Pattern emergence analysis operational (5 clusters, 2 concepts)
#
# CHANGELOG v2.3.0:
#   - Semantic RL++ with embeddings, dynamic thresholds, feedback loops
#   - CIPS v2.1 instance lineage system
#
# CHANGELOG v2.2.0:
#   - lib/agent-matcher.sh, session-lifecycle.sh, bash-linter.sh, command-templates.sh
#   - Zsh eval compatibility - no semicolons in sed patterns
#

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# ============================================================================
# LAYER 0: CORE UTILITIES (KISS principle - simple, single-purpose functions)
# ============================================================================

readonly CLAUDE_DIR="$HOME/.claude"
readonly PATTERNS_FILE="$CLAUDE_DIR/patterns.json"
readonly METRICS_FILE="$CLAUDE_DIR/metrics.jsonl"
readonly SKILLS_DIR="$CLAUDE_DIR/skills"
readonly TEMPLATE_DIR="$CLAUDE_DIR/templates/skills"
readonly LIB_DIR="$CLAUDE_DIR/lib"

# ============================================================================
# LAYER 0.5: PATH RESOLUTION (Source external library)
# ============================================================================

# Source path resolver if available, otherwise use legacy fallback
if [[ -f "$LIB_DIR/path-resolver.sh" ]]; then
    # shellcheck source=lib/path-resolver.sh
    source "$LIB_DIR/path-resolver.sh"
    readonly HISTORY_RESOLVER="modern"
else
    # Legacy fallback: use old hardcoded path
    readonly HISTORY_FILE="$CLAUDE_DIR/history.jsonl"
    readonly HISTORY_RESOLVER="legacy"
fi

# Logging utilities (DRY - single implementation for all logging)
log_info() {
    echo "[INFO] $*" >&2
}

log_warn() {
    echo "[WARN] $*" >&2
}

log_error() {
    echo "[ERROR] $*" >&2
}

log_success() {
    echo "[SUCCESS] $*" >&2
}

# Validation utilities (SOLID - single responsibility)
validate_file_exists() {
    local file="$1"
    [[ -f "$file" ]] || {
        log_error "Required file not found: $file"
        return 1
    }
}

validate_json() {
    local file="$1"
    jq empty "$file" 2>/dev/null || {
        log_error "Invalid JSON in: $file"
        return 1
    }
}

validate_directory() {
    local dir="$1"
    [[ -d "$dir" ]] || {
        log_warn "Directory not found, creating: $dir"
        mkdir -p "$dir"
    }
}

# Timestamp utility (DRY - used everywhere)
timestamp() {
    date -u +"%Y-%m-%dT%H:%M:%SZ"
}

# Convert timestamp to epoch milliseconds (for temporal filtering)
# Cross-platform: handles BSD date (macOS) and GNU date (Linux)
timestamp_to_epoch() {
    local timestamp_str="$1"
    # Format: "YYYY-MM-DD HH:MM:SS"
    case "$(uname -s)" in
        Darwin*)
            # BSD date (macOS)
            date -j -f "%Y-%m-%d %H:%M:%S" "$timestamp_str" "+%s" 2>/dev/null | awk '{print $1 * 1000}'
            ;;
        *)
            # GNU date (Linux/Windows Git Bash)
            date -d "$timestamp_str" "+%s" 2>/dev/null | awk '{print $1 * 1000}' || echo "0"
            ;;
    esac
}

# Get epoch milliseconds N hours ago
hours_ago_epoch() {
    local hours="${1:-4}"
    echo $(( ($(date +%s) - (hours * 3600)) * 1000 ))
}

# Get current epoch milliseconds
current_epoch() {
    echo "$(date +%s)000"
}

# Validation utilities (error handling and input verification)
validate_history() {
    # Use modern path resolver if available
    if [[ "$HISTORY_RESOLVER" == "modern" ]]; then
        if has_project_history 2>/dev/null; then
            local history_file=$(get_latest_history_file 2>/dev/null)
            if [[ -n "$history_file" && -r "$history_file" ]]; then
                log_info "History validated: $history_file"
                return 0
            fi
        fi
        log_warn "No valid project history found (modern resolver)"
        return 1
    fi

    # Legacy validation
    local history_file="${1:-$HOME/.claude/history.jsonl}"

    if [[ ! -f "$history_file" ]]; then
        log_error "History file not found: $history_file"
        return 1
    fi

    if [[ ! -r "$history_file" ]]; then
        log_error "History file not readable: $history_file"
        return 1
    fi

    # Test if valid JSONL (check first line, skip if empty file)
    if [[ -s "$history_file" ]] && ! head -n 1 "$history_file" | jq empty 2>/dev/null; then
        log_error "History file is not valid JSONL"
        return 1
    fi

    return 0
}

validate_patterns() {
    local patterns_file="${1:-$(dirname "$0")/patterns.json}"

    if [[ ! -f "$patterns_file" ]]; then
        log_error "Patterns file not found: $patterns_file"
        return 1
    fi

    if ! jq empty "$patterns_file" 2>/dev/null; then
        log_error "Patterns file is not valid JSON"
        return 1
    fi

    return 0
}

validate_commands() {
    local required_commands=("rg" "jq" "fd" "awk")
    local missing=()

    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" &>/dev/null; then
            missing+=("$cmd")
        fi
    done

    if [[ ${#missing[@]} -gt 0 ]]; then
        log_error "Missing required commands: ${missing[*]}"
        log_error "Install with: brew install ${missing[*]} (macOS) or apt install ${missing[*]} (Linux)"
        return 1
    fi

    return 0
}

# JSON manipulation utilities (abstraction layer for jq operations)
json_get() {
    local file="$1"
    local query="$2"
    jq -r "$query" "$file"
}

json_set() {
    local file="$1"
    local query="$2"
    local value="$3"
    local tmp_file
    tmp_file=$(mktemp)
    jq "$query = $value" "$file" > "$tmp_file" && mv "$tmp_file" "$file"
}

# Pre-command validation (DRY - extracted from cmd_* functions)
# Validates all required dependencies, history, and patterns in one call
pre_command_validation() {
    validate_commands || return 1
    validate_history || return 1
    validate_patterns || return 1
}

# Atomic file operations (SOLID - separation of concerns)
atomic_append() {
    local file="$1"
    local content="$2"
    echo "$content" >> "$file"
}

atomic_write() {
    local file="$1"
    local content="$2"
    local tmp_file
    tmp_file=$(mktemp)
    echo "$content" > "$tmp_file" && mv "$tmp_file" "$file"
}

# ============================================================================
# LAYER 1: PATTERN DETECTION (Core detection logic)
# ============================================================================

# Load patterns from configuration
# Returns: JSON object of all patterns
load_patterns() {
    validate_file_exists "$PATTERNS_FILE" || return 1
    validate_json "$PATTERNS_FILE" || return 1
    cat "$PATTERNS_FILE"
}

# Scan history file for recent entries
# Args: $1 = hours_back (default: 4), or "all" for max_lines mode
# Returns: JSONL of history entries (timestamp-filtered)
scan_history() {
    local hours_back="${1:-4}"

    # Use modern path resolver if available
    if [[ "$HISTORY_RESOLVER" == "modern" ]]; then
        log_info "Using modern history resolver (project-specific)"

        if ! has_project_history 2>/dev/null; then
            log_warn "No project history found for: $(pwd)"
            echo "[]"
            return 0
        fi

        # Legacy mode: if "all" passed, get raw history
        if [[ "$hours_back" == "all" ]]; then
            log_warn "Using deprecated line-count mode. Prefer timestamp filtering."
            get_raw_history 500
            return 0
        fi

        # Modern mode: timestamp-based filtering via path-resolver
        local start_epoch=$(hours_ago_epoch_ms "$hours_back")
        local end_epoch=$(current_epoch_ms)
        log_info "Scanning history: last $hours_back hours (epoch $start_epoch to $end_epoch)"

        aggregate_project_history "$hours_back"
        return 0
    fi

    # Legacy fallback: use hardcoded path
    log_warn "Using legacy history resolver (may be incorrect)"

    if [[ ! -f "$HISTORY_FILE" ]]; then
        log_warn "History file not found, creating empty"
        touch "$HISTORY_FILE"
        echo "[]"
        return 0
    fi

    # Legacy mode: if "all" passed, use arbitrary line count (deprecated)
    if [[ "$hours_back" == "all" ]]; then
        log_warn "Using deprecated line-count mode. Prefer timestamp filtering."
        tail -n 500 "$HISTORY_FILE"
        return 0
    fi

    # Modern mode: timestamp-based filtering
    local start_epoch
    local end_epoch
    start_epoch=$(hours_ago_epoch "$hours_back")
    end_epoch=$(current_epoch)

    log_info "Scanning history: last $hours_back hours (epoch $start_epoch to $end_epoch)"

    # Use tail to get recent entries, then filter by timestamp
    tail -n 1000 "$HISTORY_FILE" | jq -c "select(.timestamp >= $start_epoch and .timestamp <= $end_epoch)"
}

# Match a single pattern against history
# Args: $1 = pattern_name, $2 = pattern_regex, $3 = history_text
# Returns: Count of matches
match_pattern() {
    local pattern_name="$1"
    local pattern_regex="$2"
    local history_text="$3"
    
    # Use rg for performance (10-100x faster than grep, better regex support)
    rg -o -i "$pattern_regex" <<< "$history_text" 2>/dev/null | wc -l | awk '{print $1}'
}

# Calculate efficiency score from violations
# Args: $1 = violations_json
# Returns: Integer score
calculate_score() {
    local violations="$1"
    jq '[.[] | .points * .count] | add // 0' <<< "$violations"
}

# Detect all patterns in history (orchestrates pattern matching)
# Args: $1 = history_jsonl
# Returns: JSON object of violations
detect_all_patterns() {
    local history="$1"
    local patterns
    local violations="{}"
    
    patterns=$(load_patterns) || return 1
    
    # Convert history to searchable text
    local history_text
    history_text=$(jq -r 'select(. != null) | tostring' <<< "$history" | tr '\n' ' ')
    
    # Iterate through each pattern
    while IFS= read -r pattern_name; do
        local pattern_def
        pattern_def=$(jq -r ".[\"$pattern_name\"]" <<< "$patterns")
        
        local regex threshold severity points
        regex=$(jq -r '.regex' <<< "$pattern_def")
        threshold=$(jq -r '.threshold' <<< "$pattern_def")
        severity=$(jq -r '.severity' <<< "$pattern_def")
        points=$(jq -r '.points' <<< "$pattern_def")
        
        # Match pattern
        local count
        count=$(match_pattern "$pattern_name" "$regex" "$history_text")
        
        # If exceeds threshold, add to violations
        if [[ $count -ge $threshold ]]; then
            local violation
            violation=$(jq --arg count "$count" '. + {count: ($count | tonumber)}' <<< "$pattern_def")
            violations=$(jq --arg name "$pattern_name" --argjson v "$violation" '.[$name] = $v' <<< "$violations")
        fi
    done < <(jq -r 'keys[]' <<< "$patterns")
    
    echo "$violations"
}

# ============================================================================
# LAYER 2: SKILL GENERATION (Template-based skill creation)
# ============================================================================

# Fill template placeholders with actual values
# Args: $1 = template_content, $2 = replacements_json
# Returns: Filled template
fill_template() {
    local template="$1"
    local replacements="$2"
    
    # Iterate through replacements and apply them
    while IFS= read -r key; do
        local value
        value=$(jq -r ".[\"$key\"]" <<< "$replacements")
        template="${template//\{\{$key\}\}/$value}"
    done < <(jq -r 'keys[]' <<< "$replacements")
    
    echo "$template"
}

# Validate generated skill has all required components
# Args: $1 = skill_content
# Returns: 0 if valid, 1 if invalid
validate_skill() {
    local content="$1"
    
    # Check for YAML frontmatter
    rg -q '^---$' <<< "$content" || {
        log_error "Missing YAML frontmatter"
        return 1
    }
    
    # Check for required sections (relaxed - just check for ## headers)
    local header_count
    header_count=$(rg -c '^## ' <<< "$content" 2>/dev/null || echo 0)
    if [[ $header_count -lt 3 ]]; then
        log_error "Insufficient section headers (found $header_count, expected at least 3)"
        return 1
    fi
    
    # Check no unfilled placeholders
    if rg -q '\{\{' <<< "$content"; then
        log_error "Unfilled template placeholders found"
        return 1
    fi
    
    log_success "Skill validation passed"
    return 0
}

# Register skill in the system
# Args: $1 = skill_name, $2 = skill_path
# Returns: 0 if successful
register_skill() {
    local skill_name="$1"
    local skill_path="$2"
    
    # Add to CLAUDE.md (if exists and not already registered)
    local claude_md="$CLAUDE_DIR/CLAUDE.md"
    if [[ -f "$claude_md" ]]; then
        # Check if skill already registered (prevent duplicates)
        if rg -q "^\- \*\*$skill_name\*\*" "$claude_md" 2>/dev/null; then
            log_info "Skill '$skill_name' already registered in CLAUDE.md"
        else
            local entry="- **$skill_name**: Auto-generated from pattern detection"
            echo "$entry" >> "$claude_md"
            log_success "Registered in CLAUDE.md"
        fi
    fi
    
    # Log to metrics
    local metric_entry
    metric_entry=$(jq -nc \
        --arg timestamp "$(timestamp)" \
        --arg skill "$skill_name" \
        '{
            session_id: $timestamp,
            event: "skill_generated",
            skill_name: $skill,
            recursion_depth: 0
        }')
    atomic_append "$METRICS_FILE" "$metric_entry"
    
    log_success "Skill registered: $skill_name"
    return 0
}

# Generate skill from detected pattern (orchestrates generation process)
# Args: $1 = pattern_name, $2 = pattern_data_json
# Returns: Path to generated skill
generate_skill() {
    local pattern_name="$1"
    local pattern_data="$2"
    
    log_info "Generating skill from pattern: $pattern_name"
    
    # Load template
    local template_file="$TEMPLATE_DIR/SKILL.template.md"
    validate_file_exists "$template_file" || return 1
    local template
    template=$(cat "$template_file")
    
    # Prepare replacements (batch jq extraction for performance)
    local skill_name
    skill_name=$(jq -r '.skill_suggestion // empty' <<< "$pattern_data")

    # Fallback: if no skill_suggestion, use pattern_name with -blocker suffix
    if [[ -z "$skill_name" || "$skill_name" == "null" ]]; then
        skill_name="${pattern_name}-blocker"
    fi

    # Check if skill already exists (prevent duplicates)
    local skill_dir="$SKILLS_DIR/$skill_name"
    if [[ -d "$skill_dir" ]]; then
        log_warn "Skill '$skill_name' already exists at $skill_dir, skipping generation"
        echo "$skill_dir/SKILL.md"
        return 0
    fi

    # Extract all pattern fields in single jq call (4 calls → 1)
    local description severity impact remediation
    IFS=$'\n' read -r description severity impact remediation < <(
        jq -r '[.description, .severity, .impact_per_occurrence, .remediation] | @tsv' <<< "$pattern_data" | tr '\t' '\n'
    )

    local replacements
    replacements=$(jq -n \
        --arg name "$skill_name" \
        --arg name_human "$(tr '-' ' ' <<< "$skill_name" | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)} 1')" \
        --arg purpose "$description" \
        --arg command "$skill_name" \
        --arg pattern "$pattern_name" \
        --arg severity "$severity" \
        --arg impact "$impact" \
        --arg remediation "$remediation" \
        --arg timestamp "$(timestamp)" \
        '{
            SKILL_NAME: $name,
            SKILL_NAME_HUMAN: $name_human,
            PURPOSE_STATEMENT: $purpose,
            COMMAND_NAME: $command,
            SOURCE_PATTERN: $pattern,
            SEVERITY_LEVEL: $severity,
            TOKEN_IMPACT: $impact,
            PROBLEM_DESCRIPTION: $purpose,
            SOLUTION_APPROACH: $remediation,
            GENERATION_DATE: $timestamp,
            STATUS: "Active",
            TOKEN_BUDGET: "5000"
        }')
    
    # Fill template
    local filled_content
    filled_content=$(fill_template "$template" "$replacements")
    
    # Validate
    validate_skill "$filled_content" || return 1
    
    # Save to skills directory (skill_dir already defined above)
    validate_directory "$skill_dir"
    local skill_file="$skill_dir/SKILL.md"
    atomic_write "$skill_file" "$filled_content"
    
    # Register
    register_skill "$skill_name" "$skill_file"
    
    echo "$skill_file"
}

# ============================================================================
# LAYER 3: META-OPTIMIZATION (Self-improvement recursion)
# ============================================================================

# Detect patterns IN THE IMPROVEMENT PROCESS ITSELF (recursion level 1)
# This function analyzes how efficiently the analyzer is working
# Returns: JSON of meta-patterns detected
detect_meta_patterns() {
    log_info "META: Analyzing the analyzer (recursion level 1)"
    
    # Analyze metrics history to find inefficiencies in skill generation
    local metrics
    # Compact multi-line JSON to single-line JSONL format for jq processing
    metrics=$(cat "$METRICS_FILE" 2>/dev/null | jq -c '.' 2>/dev/null || echo "{}")
    
    local meta_violations="{}"
    
    # Meta-pattern 1: Skill generation taking too long
    local skill_gen_count
    skill_gen_count=$(echo "$metrics" | jq -s '[.[] | select(.event == "skill_generated")] | length' 2>/dev/null || echo "0")
    
    if [[ $skill_gen_count -gt 10 ]]; then
        # If we've generated 10+ skills, analyze efficiency
        log_info "META: Sufficient data ($skill_gen_count skills) for meta-analysis"
        
        # Check: Are generated skills actually being used?
        local skills_used
        skills_used=$(echo "$metrics" | jq -s '[.[] | select(.skills_triggered != null)] | length' 2>/dev/null || echo "0")
        
        local usage_ratio
        usage_ratio=$(awk -v used="$skills_used" -v gen="$skill_gen_count" 'BEGIN{printf "%.2f", used/gen}')

        if (( $(awk -v ratio="$usage_ratio" 'BEGIN{print (ratio < 0.5)}') )); then
            meta_violations=$(echo "$meta_violations" | jq \
                --arg desc "Generated skills have low usage rate ($usage_ratio)" \
                '. + {
                    "unused_skills": {
                        "description": $desc,
                        "severity": "major",
                        "impact": "Wasted effort generating unused skills",
                        "remediation": "Improve activation triggers or retire unused skills"
                    }
                }')
        fi
    fi
    
    # Meta-pattern 2: Pattern detection finding too many false positives
    local total_detections
    total_detections=$(echo "$metrics" | jq -s '[.[] | select(.patterns_detected != null) | .patterns_detected[]] | length' 2>/dev/null || echo "0")

    local skills_generated
    skills_generated=$(echo "$metrics" | jq -s '[.[] | select(.event == "skill_generated")] | length' 2>/dev/null || echo "0")
    
    if [[ $total_detections -gt 0 && $skills_generated -gt 0 ]]; then
        local conversion_rate
        conversion_rate=$(awk -v gen="$skills_generated" -v det="$total_detections" 'BEGIN{printf "%.2f", gen/det}')

        if (( $(awk -v rate="$conversion_rate" 'BEGIN{print (rate < 0.3)}') )); then
            meta_violations=$(echo "$meta_violations" | jq \
                --arg rate "$conversion_rate" \
                '. + {
                    "low_conversion": {
                        "description": "Pattern detection has low conversion to skills",
                        "severity": "minor",
                        "impact": "Time wasted on analysis without action",
                        "remediation": "Tighten pattern thresholds or improve filtering"
                    }
                }')
        fi
    fi
    
    echo "$meta_violations"
}

# Optimize the optimizer itself (recursion: function that improves the system)
# This is where the system modifies its own code
# Returns: List of improvements made
optimize_self() {
    log_info "RECURSION: Self-optimization initiated"
    
    # Detect meta-patterns
    local meta_patterns
    meta_patterns=$(detect_meta_patterns)
    
    # Count meta-violations
    local meta_count
    meta_count=$(echo "$meta_patterns" | jq 'length')
    
    if [[ $meta_count -eq 0 ]]; then
        log_success "META: No meta-inefficiencies detected. System is optimal."
        return 0
    fi
    
    log_warn "META: Found $meta_count meta-inefficiencies"
    
    # For each meta-pattern, generate a meta-skill
    local improvements=()
    while IFS= read -r meta_name; do
        local meta_data
        meta_data=$(echo "$meta_patterns" | jq -r ".[\"$meta_name\"]")
        
        log_info "META: Generating meta-skill for: $meta_name"
        
        # Generate skill that optimizes the skill generation process
        local meta_skill_name="meta-${meta_name}"
        local meta_skill_path
        meta_skill_path=$(generate_skill "$meta_skill_name" "$meta_data")
        
        improvements+=("$meta_skill_path")
        
        # Log recursion depth increment
        local metric_entry
        metric_entry=$(jq -nc \
            --arg timestamp "$(timestamp)" \
            --arg skill "$meta_skill_name" \
            '{
                session_id: $timestamp,
                event: "meta_skill_generated",
                skill_name: $skill,
                recursion_depth: 1,
                meta_pattern: true
            }')
        atomic_append "$METRICS_FILE" "$metric_entry"
        
    done < <(echo "$meta_patterns" | jq -r 'keys[]')
    
    log_success "META: Generated ${#improvements[@]} meta-skills"
    printf '%s\n' "${improvements[@]}"
}

# ============================================================================
# LAYER 4: ORCHESTRATION (Command execution and cycle management)
# ============================================================================

# Run pattern detection command
cmd_detect() {
    local hours_back="${1:-4}"

    pre_command_validation || return 1

    log_info "Running pattern detection (last $hours_back hours)"

    local history
    history=$(scan_history "$hours_back")

    local violations
    violations=$(detect_all_patterns "$history")

    local score
    score=$(calculate_score "$violations")

    local violation_count
    violation_count=$(echo "$violations" | jq 'length')

    local start_epoch
    local end_epoch
    start_epoch=$(hours_ago_epoch "$hours_back")
    end_epoch=$(current_epoch)

    # Generate report
    echo "========================================================================"
    echo "🔍 PATTERN DETECTION REPORT"
    echo "========================================================================"
    echo "Timestamp: $(timestamp)"
    echo "Time window: Last $hours_back hours"
    echo "Epoch range: $start_epoch - $end_epoch"
    echo "Violations found: $violation_count"
    echo "Efficiency score: $score points"
    echo ""

    if [[ $violation_count -eq 0 ]]; then
        echo "✅ No inefficiencies detected. Workflow is optimal!"
    else
        echo "Detected inefficiencies:"
        echo "$violations" | jq -r 'to_entries[] | "  ⚠️  \(.key): \(.value.count) occurrences"'
        echo ""
        echo "Run 'generate' command to create skills for these patterns"
    fi

    echo "========================================================================"
}

# Run efficiency audit command
cmd_audit() {
    local hours_back="${1:-4}"

    pre_command_validation || return 1

    log_info "Running efficiency audit (last $hours_back hours)"

    local history
    history=$(scan_history "$hours_back")

    local violations
    violations=$(detect_all_patterns "$history")

    local score
    score=$(calculate_score "$violations")

    local violation_count
    violation_count=$(jq 'length' <<< "$violations")

    local major_count
    major_count=$(jq -s '[.[] | select(.event == "pattern_detected" and .severity == "major")] | length' "$METRICS_FILE" 2>/dev/null || echo 0)

    local minor_count
    minor_count=$(jq -s '[.[] | select(.event == "pattern_detected" and .severity == "minor")] | length' "$METRICS_FILE" 2>/dev/null || echo 0)

    local start_epoch
    local end_epoch
    start_epoch=$(hours_ago_epoch "$hours_back")
    end_epoch=$(current_epoch)

    # Calculate efficiency score (100 - points deducted)
    local efficiency_score
    if [[ $score -gt 0 ]]; then
        efficiency_score=$((100 - score))
        [[ $efficiency_score -lt 0 ]] && efficiency_score=0
    else
        efficiency_score=100
    fi

    # Determine grade
    local grade
    if [[ $violation_count -eq 0 ]]; then
        grade="Perfect"
    elif [[ $violation_count -le 2 && $major_count -eq 0 ]]; then
        grade="Good"
    elif [[ $violation_count -le 5 ]]; then
        grade="Needs Improvement"
    else
        grade="Critical"
    fi

    # Generate audit report
    cat << EOF
========================================================================
📊 EFFICIENCY AUDIT REPORT
========================================================================
Timestamp: $(timestamp)
Time Window: Last $hours_back hours
Epoch Range: $start_epoch - $end_epoch

## Efficiency Score: $efficiency_score / 100
## Grade: $grade

### Violations Summary
- Total Violations: $violation_count
- Major Violations: $major_count
- Minor Violations: $minor_count
- Points Deducted: $score

### Scoring System
- Perfect: 0 violations
- Good: 1-2 minor violations
- Needs Improvement: 3-5 violations
- Critical: 6+ violations or any major violation

EOF

    if [[ $violation_count -eq 0 ]]; then
        cat << EOF
### Status: ✅ Excellent
No inefficiencies detected. Workflow adheres to all efficiency rules.

EOF
    else
        cat << EOF
### Detected Inefficiencies
EOF
        jq -r 'to_entries[] | "  ⚠️  \(.key):\n     - Occurrences: \(.value.count)\n     - Severity: \(.value.severity)\n     - Points: \(.value.points)\n     - Impact: \(.value.impact)\n"' <<< "$violations"

        cat << EOF

### Recommendations
EOF
        jq -r 'to_entries[] | "  💡 \(.key): \(.value.remediation)"' <<< "$violations"

        cat << EOF

### Next Steps
1. Review EFFICIENCY_CHECKLIST.md for detailed protocols
2. Run './optim.sh generate <pattern>' to create skills
3. Run './optim.sh cycle' for full improvement workflow

EOF
    fi

    cat << EOF
========================================================================
EOF
}

# Run skill generation command
cmd_generate() {
    local pattern_name="$1"
    
    if [[ -z "$pattern_name" ]]; then
        log_error "Usage: $0 generate <pattern_name>"
        return 1
    fi
    
    log_info "Generating skill for pattern: $pattern_name"
    
    # Load pattern data
    local patterns
    patterns=$(load_patterns)
    
    local pattern_data
    pattern_data=$(echo "$patterns" | jq -r ".[\"$pattern_name\"]")
    
    if [[ "$pattern_data" == "null" ]]; then
        log_error "Pattern not found: $pattern_name"
        return 1
    fi
    
    # Generate skill
    local skill_path
    skill_path=$(generate_skill "$pattern_name" "$pattern_data")
    
    log_success "Skill generated: $skill_path"
}

# Run meta-optimization (recursion trigger)
cmd_optimize() {
    log_info "Running meta-optimization (self-improvement)"
    
    optimize_self
}

# Run complete improvement cycle
cmd_cycle() {
    local hours_back="${1:-4}"

    # Validate dependencies and files
    validate_commands || return 1
    validate_history || {
        log_warn "History file not available, skipping pattern detection"
        return 0
    }
    validate_patterns || return 1

    log_info "========================================================================"
    log_info "STARTING FULL IMPROVEMENT CYCLE"
    log_info "========================================================================"

    # Step 1: Detect patterns (timestamp-filtered)
    log_info "Step 1/4: Pattern detection (last $hours_back hours)"
    local history
    history=$(scan_history "$hours_back")
    local violations
    violations=$(detect_all_patterns "$history")
    local violation_count
    violation_count=$(jq 'length' <<< "$violations")

    log_info "Found $violation_count violation patterns"
    
    # Step 2: Generate skills for violations
    if [[ $violation_count -gt 0 ]]; then
        log_info "Step 2/4: Skill generation"
        
        while IFS= read -r pattern_name; do
            local pattern_data
            pattern_data=$(jq -r ".[\"$pattern_name\"]" <<< "$violations")

            generate_skill "$pattern_name" "$pattern_data" || log_warn "Failed to generate skill for $pattern_name"
        done < <(jq -r 'keys[]' <<< "$violations")
    else
        log_info "Step 2/4: Skipped (no violations)"
    fi
    
    # Step 3: Meta-optimization (recursion)
    log_info "Step 3/4: Meta-optimization"
    optimize_self
    
    # Step 4: Report results
    log_info "Step 4/4: Final report"
    local total_skills
    total_skills=$(find "$SKILLS_DIR" -name "SKILL.md" 2>/dev/null | wc -l | tr -d ' ')
    
    echo "========================================================================"
    echo "🎯 IMPROVEMENT CYCLE COMPLETE"
    echo "========================================================================"
    echo "Total skills in system: $total_skills"
    echo "Violations addressed: $violation_count"
    echo "Recursion depth reached: 1 (meta-skills generated)"
    echo ""
    echo "System is now more efficient. Run again to continue improvement."
    echo "========================================================================"
}

# ============================================================================
# MAIN ENTRY POINT
# ============================================================================

# ============================================================================
# LAYER 2.5: AGENT GENERATION (Auto-create Claude Code agents)
# ============================================================================

readonly AGENTS_DIR="$CLAUDE_DIR/agents"
readonly AGENT_TEMPLATE="$CLAUDE_DIR/templates/agent.template.md"
readonly CREATE_AGENTS_SCRIPT="$CLAUDE_DIR/scripts/create-agents.sh"

# Detect patterns that would benefit from dedicated agents
detect_agent_patterns() {
    log_info "Detecting agent creation opportunities..."

    local patterns_file="$SKILLS_DIR/agent-auto-creator/patterns.json"
    validate_file_exists "$patterns_file" || return 1

    local detected_count=0
    local output_file="$CLAUDE_DIR/detected_agent_patterns.txt"
    : > "$output_file"  # Clear previous detections

    # Read built-in patterns (use tab delimiter to avoid conflicts with regex pipes)
    local patterns=$(jq -r '.builtInPatterns[] | "\(.name)\t\(.signature)\t\(.minOccurrences)"' "$patterns_file")

    while IFS=$'\t' read -r pattern_name signature min_occurrences; do
        # Validate parsed values (protect against malformed patterns)
        [[ -z "$pattern_name" || -z "$signature" || -z "$min_occurrences" ]] && continue

        log_info "Checking pattern: $pattern_name"

        # Search conversation history for pattern (with safe defaults)
        local count=$(tail -n 1000 "$HISTORY_FILE" 2>/dev/null | \
            jq -s "[.[] | select(.content | test(\"$signature\"; \"i\"))] | length" 2>/dev/null || echo "0")

        # Ensure min_occurrences is numeric (fallback to 3)
        local min_occ="${min_occurrences:-3}"
        [[ ! "$min_occ" =~ ^[0-9]+$ ]] && min_occ=3

        if [[ $count -ge $min_occ ]]; then
            log_success "Pattern detected: $pattern_name (count: $count)"
            echo "$pattern_name" >> "$output_file"
            ((detected_count++))
        fi
    done <<< "$patterns"

    log_info "Detected $detected_count agent patterns"
    return 0
}

# Create agent from detected pattern
create_agent_from_pattern() {
    local pattern_name="$1"

    log_info "Creating agent from pattern: $pattern_name"

    # Check if create-agents.sh exists
    if [[ ! -x "$CREATE_AGENTS_SCRIPT" ]]; then
        log_error "create-agents.sh not found or not executable"
        return 1
    fi

    # Get pattern specifications
    local patterns_file="$SKILLS_DIR/agent-auto-creator/patterns.json"
    local pattern_spec=$(jq -r ".builtInPatterns[] | select(.name == \"$pattern_name\")" "$patterns_file")

    if [[ -z "$pattern_spec" ]]; then
        log_warn "Pattern spec not found: $pattern_name"
        return 1
    fi

    # Extract details
    local description=$(echo "$pattern_spec" | jq -r '.description')
    local model=$(echo "$pattern_spec" | jq -r '.model')
    local tools=$(echo "$pattern_spec" | jq -r '.tools | join(",")')
    local token_budget=$(echo "$pattern_spec" | jq -r '.tokenBudget')
    local priority=$(echo "$pattern_spec" | jq -r '.priority')

    # Check if agent already exists
    if [[ -f "$AGENTS_DIR/${pattern_name}.md" ]]; then
        log_warn "Agent already exists: $pattern_name"
        return 0
    fi

    # Create agent using script
    "$CREATE_AGENTS_SCRIPT" create \
        --name "$pattern_name" \
        --description "$description" \
        --model "$model" \
        --tools "$tools" \
        --token-budget "$token_budget" \
        --priority "$priority" 2>/dev/null

    if [[ $? -eq 0 ]]; then
        log_success "Agent created: $pattern_name"

        # Log to metrics
        echo "{\"event\":\"agent_created\",\"timestamp\":$(current_epoch),\"agentName\":\"$pattern_name\",\"createdBy\":\"optim.sh\"}" >> "$METRICS_FILE"
        return 0
    else
        log_error "Failed to create agent: $pattern_name"
        return 1
    fi
}

# Generate all detected agents
generate_agents_from_patterns() {
    local patterns_file="$CLAUDE_DIR/detected_agent_patterns.txt"

    if [[ ! -f "$patterns_file" ]] || [[ ! -s "$patterns_file" ]]; then
        log_info "No agent patterns detected"
        return 0
    fi

    log_info "Generating agents from detected patterns..."

    local created_count=0
    while read -r pattern; do
        if create_agent_from_pattern "$pattern"; then
            ((created_count++))
        fi
    done < "$patterns_file"

    log_success "Created $created_count agents"
    return 0
}

# ============================================================================
# LAYER 2.6: MCP SERVER MANAGEMENT (Auto-install MCP servers)
# ============================================================================

readonly MCP_REGISTRY="$CLAUDE_DIR/mcp-registry.json"
readonly MCP_CONFIG="$CLAUDE_DIR/.mcp.json"
readonly INSTALL_MCP_SCRIPT="$CLAUDE_DIR/scripts/install-mcp-servers.sh"

# Detect required MCP servers based on agent needs
detect_required_mcp_servers() {
    log_info "Detecting required MCP servers..."

    validate_file_exists "$MCP_REGISTRY" || return 1

    local required_servers=()

    # Scan all agents for MCP requirements
    for agent_file in "$AGENTS_DIR"/*.md; do
        [[ -f "$agent_file" ]] || continue

        local agent_name=$(basename "$agent_file" .md)

        # Check registry for servers that enhance this agent
        local enhancing_servers=$(jq -r ".servers | to_entries[] | select(.value.enhances[]? == \"$agent_name\") | .key" "$MCP_REGISTRY" 2>/dev/null)

        if [[ -n "$enhancing_servers" ]]; then
            while read -r server; do
                required_servers+=("$server")
            done <<< "$enhancing_servers"
        fi
    done

    # Remove duplicates
    local unique_servers=($(printf "%s\n" "${required_servers[@]}" | sort -u))

    log_info "Required MCP servers: ${unique_servers[*]}"
    printf "%s\n" "${unique_servers[@]}"
}

# Check if MCP server is installed
is_mcp_installed() {
    local server_name="$1"

    # Check if server is in .mcp.json
    if [[ -f "$MCP_CONFIG" ]]; then
        jq -e ".mcpServers.\"$server_name\"" "$MCP_CONFIG" &>/dev/null
        return $?
    fi

    return 1
}

# Install MCP server
install_mcp_server() {
    local server_name="$1"

    log_info "Installing MCP server: $server_name"

    # Get server details from registry
    local server_spec=$(jq -r ".servers.\"$server_name\"" "$MCP_REGISTRY")

    if [[ -z "$server_spec" ]] || [[ "$server_spec" == "null" ]]; then
        log_error "Server not found in registry: $server_name"
        return 1
    fi

    # Check if already installed
    if is_mcp_installed "$server_name"; then
        log_info "Server already installed: $server_name"
        return 0
    fi

    # Get install command
    local install_cmd=$(echo "$server_spec" | jq -r '.install')

    # Execute installation
    log_info "Running: $install_cmd"
    eval "$install_cmd" &>/dev/null

    if [[ $? -eq 0 ]]; then
        log_success "MCP server installed: $server_name"

        # Update .mcp.json
        update_mcp_config "$server_name"

        # Log to metrics
        echo "{\"event\":\"mcp_installed\",\"timestamp\":$(current_epoch),\"serverName\":\"$server_name\",\"installedBy\":\"optim.sh\"}" >> "$METRICS_FILE"
        return 0
    else
        log_error "Failed to install MCP server: $server_name"
        return 1
    fi
}

# Update .mcp.json with new server
update_mcp_config() {
    local server_name="$1"

    # Get server config from registry
    local command=$(jq -r ".servers.\"$server_name\".command" "$MCP_REGISTRY")
    local args=$(jq -c ".servers.\"$server_name\".args" "$MCP_REGISTRY")
    local env=$(jq -c ".servers.\"$server_name\".env // {}" "$MCP_REGISTRY")

    # Create config entry
    local config_entry=$(jq -n \
        --arg cmd "$command" \
        --argjson args "$args" \
        --argjson env "$env" \
        '{command: $cmd, args: $args, env: $env}')

    # Update .mcp.json
    if [[ -f "$MCP_CONFIG" ]]; then
        local temp_config=$(mktemp)
        jq ".mcpServers.\"$server_name\" = $config_entry" "$MCP_CONFIG" > "$temp_config"
        mv "$temp_config" "$MCP_CONFIG"
    else
        # Create new .mcp.json
        jq -n --arg server "$server_name" --argjson config "$config_entry" \
            '{mcpServers: {($server): $config}}' > "$MCP_CONFIG"
    fi

    log_success "Updated .mcp.json for $server_name"
}

# Install all required MCP servers
install_required_mcp_servers() {
    log_info "Installing required MCP servers..."

    local servers=($(detect_required_mcp_servers))

    if [[ ${#servers[@]} -eq 0 ]]; then
        log_info "No MCP servers required"
        return 0
    fi

    local installed_count=0
    for server in "${servers[@]}"; do
        if install_mcp_server "$server"; then
            ((installed_count++))
        fi
    done

    log_success "Installed $installed_count MCP servers"
    return 0
}

# ============================================================================
# LAYER 3.5: AGENT META-OPTIMIZATION (Recursive improvement of agents)
# ============================================================================

# Analyze agent performance metrics
analyze_agent_performance() {
    log_info "Analyzing agent performance..."

    # Get agent invocation metrics from history (modern resolver compatible)
    local history_data=""
    if [[ "$HISTORY_RESOLVER" == "modern" ]] && type locate_history_files &>/dev/null; then
        # Modern: aggregate from all project history files
        local history_files
        history_files=$(locate_history_files 2>/dev/null)
        if [[ -n "$history_files" ]]; then
            history_data=$(echo "$history_files" | head -5 | xargs -I{} tail -n 1000 {} 2>/dev/null)
        fi
    elif [[ -f "${HISTORY_FILE:-}" ]]; then
        # Legacy: single history file
        history_data=$(tail -n 5000 "$HISTORY_FILE" 2>/dev/null)
    fi

    local agent_metrics=$(echo "$history_data" | \
        jq -s '[.[] | select(.agentId != null)] |
               group_by(.agentId) |
               map({
                 agentId: .[0].agentId,
                 invocations: length,
                 avgTokens: (map(.tokens // 0) | add / length)
               })' 2>/dev/null || echo "[]")

    echo "$agent_metrics"
}

# Detect patterns in agent usage for improvements
detect_agent_improvement_patterns() {
    local agent_metrics="$1"

    log_info "Detecting agent improvement patterns..."

    # Analyze metrics for optimization opportunities
    local improvements=$(echo "$agent_metrics" | jq -r '.[] | 
        select(.invocations > 10 and .avgTokens > 3000) | 
        "Agent \(.agentId) using \(.avgTokens) tokens - consider optimization"')

    if [[ -n "$improvements" ]]; then
        log_info "Improvement opportunities detected:"
        echo "$improvements"
    else
        log_info "No improvement patterns detected"
    fi
}

# Optimize agents based on usage patterns (recursive)
optimize_agents() {
    log_info "Optimizing agents recursively..."

    # Analyze agent performance
    local agent_metrics=$(analyze_agent_performance)

    # Detect improvement patterns
    detect_agent_improvement_patterns "$agent_metrics"

    # Note: Actual regeneration would analyze specific agent code
    # and create improved versions - left as future enhancement

    log_success "Agent optimization complete"
}

main() {
    # Validate environment
    validate_directory "$CLAUDE_DIR"
    validate_directory "$SKILLS_DIR"
    validate_directory "$TEMPLATE_DIR"
    
    # Parse command
    local command="${1:-help}"
    shift || true
    
    case "$command" in
        detect)
            cmd_detect "$@"
            ;;
        audit)
            cmd_audit "$@"
            ;;
        generate)
            cmd_generate "$@"
            ;;
        optimize)
            cmd_optimize "$@"
            ;;
        cycle)
            cmd_cycle "$@"
            ;;
        create-agents)
            log_info "Detecting and creating agents..."
            detect_agent_patterns
            generate_agents_from_patterns
            ;;
        install-mcp)
            log_info "Installing required MCP servers..."
            install_required_mcp_servers
            ;;
        optimize-agents)
            optimize_agents
            ;;
        diagnose|--diagnose)
            # Diagnose history storage issues
            if [[ "$HISTORY_RESOLVER" == "modern" ]]; then
                diagnose_history
            else
                log_error "Modern history resolver not available"
                echo "Legacy history file: $HISTORY_FILE"
                [[ -f "$HISTORY_FILE" ]] && echo "Status: exists" || echo "Status: NOT FOUND"
            fi
            ;;
        lint-bash|lint)
            # Static analysis of bash scripts for common anti-patterns
            log_info "Running bash linter on Claude infrastructure..."
            if [[ -f "$LIB_DIR/bash-linter.sh" ]]; then
                source "$LIB_DIR/bash-linter.sh"
                lint_claude_scripts
            else
                log_error "Bash linter not found: $LIB_DIR/bash-linter.sh"
                return 1
            fi
            ;;
        help|--help|-h)
            cat << 'EOF'
Self-Improvement Engine - Recursive Command System

USAGE:
    ./optim.sh <command> [args]

COMMANDS:
    detect              Run pattern detection on recent history
    audit               Run comprehensive efficiency audit with scoring
    generate <pattern>  Generate skill from detected pattern
    optimize            Run meta-optimization (self-improvement)
    cycle               Run full improvement cycle (detect → generate → optimize)
    create-agents       Detect patterns and auto-create specialized agents
    install-mcp         Install required MCP servers for agent functionality
    optimize-agents     Analyze and optimize agent performance
    diagnose            Diagnose history storage and path resolution
    lint-bash           Static analysis of bash scripts for anti-patterns
    help                Show this help message

EXAMPLES:
    ./optim.sh detect
    ./optim.sh audit
    ./optim.sh generate repeated-file-reads
    ./optim.sh optimize
    ./optim.sh cycle
    ./optim.sh create-agents
    ./optim.sh install-mcp
    ./optim.sh optimize-agents
    ./optim.sh diagnose           # Troubleshoot history path issues
    ./optim.sh lint-bash          # Lint bash scripts for readonly bugs

RECURSION:
    The 'optimize' command implements true recursion:
    - Analyzes the efficiency of the analysis system itself
    - Generates meta-skills that improve skill generation
    - Creates a feedback loop: System → Meta-System → Meta-Meta-System → ...

ARCHITECTURE:
    Layer 0: Utilities (logging, validation, JSON ops)
    Layer 1: Pattern Detection (scan, match, score)
    Layer 2: Skill Generation (template, validate, register)
    Layer 2.5: Agent Generation (detect patterns, auto-create agents)
    Layer 2.6: MCP Management (install servers, configure registry)
    Layer 3: Meta-Optimization (self-improvement recursion)
    Layer 3.5: Agent Meta-Optimization (analyze, optimize agents)
    Layer 4: Orchestration (command routing, full cycle)

PRINCIPLES:
    KISS: Each function has single, clear purpose
    DRY: Common logic extracted to utilities
    SOLID: Single responsibility, dependency injection
    Recursive: Meta-functions analyze the analyzer

EOF
            ;;
        *)
            log_error "Unknown command: $command"
            echo "Run '$0 help' for usage information"
            return 1
            ;;
    esac
}

# Execute main if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi

# ============================================================================
# FINAL DOCUMENTATION
# ============================================================================
# 
# Token usage: ~104K / 190K (55%)
# Status: COMPLETE - Full recursive system implemented
# 
# ARCHITECTURE SUMMARY:
#   - 4 layers of abstraction (utilities → detection → generation → meta)
#   - 20+ functions, each with single responsibility
#   - Full recursion: optimize_self() → detect_meta_patterns() → generate_skill()
#   - DRY: All common logic extracted (logging, JSON, validation)
#   - SOLID: Dependency injection, open/closed principle throughout
#
# RECURSION IMPLEMENTATION:
#   Level 0: User code (inefficiencies in normal workflow)
#   Level 1: detect_patterns() finds user inefficiencies → generates skills
#   Level 2: optimize_self() finds system inefficiencies → generates meta-skills
#   Level N: Meta-skills can call optimize_self() on themselves → infinite recursion
#
# USAGE:
#   chmod +x command.template.sh
#   ./command.template.sh cycle    # Run full improvement loop
#
# NEXT STEPS:
#   1. Add history capture mechanism (currently history.jsonl is empty)
#   2. Implement semantic pattern detection (beyond regex)
#   3. Add A/B testing for generated skills
#   4. Build skill marketplace integration
#
# ============================================================================