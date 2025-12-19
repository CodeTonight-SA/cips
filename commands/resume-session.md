# Resume Session Command

Resume a previous Claude Code session using CIPS (Claude Instance Persistence System) references.

## Usage

```bash
/resume-session [reference] [--fresh] [--tokens N]
```

## Reference Types

| Reference | Example | Description |
|-----------|---------|-------------|
| (none) | `/resume-session` | Interactive: list recent sessions |
| `latest` | `/resume-session latest` | Most recent session for current project |
| `gen:N` | `/resume-session gen:5` | CIPS generation number |
| `<instance>` | `/resume-session 14d5f954` | CIPS instance ID (prefix OK) |
| `<slug>` | `/resume-session clever-jingling` | Session slug (fuzzy match) |
| `<uuid>` | `/resume-session abc123-...` | Full session UUID |

## Flags

| Flag | Description |
|------|-------------|
| `--fresh` | Start NEW session with compressed context (not full resume) |
| `--tokens N` | Token budget for fresh mode (default: 2000) |

## Token Budgets

| Budget | Use Case |
|--------|----------|
| 500 | Ultra-light context reminder |
| 2000 | Standard balanced context (default) |
| 5000 | Extended context for complex tasks |

## Examples

```bash
# Resume last session for this project
/resume-session latest

# Resume by CIPS generation
/resume-session gen:5

# Start fresh session but inherit context from generation 5
/resume-session gen:5 --fresh

# Fresh with custom token budget
/resume-session latest --fresh --tokens 500

# Resume by session slug
/resume-session peppy-greeting-reef

# List available sessions
/resume-session list
```

## How It Works

### Mode A: True Resume (default)

Uses Claude Code's native `claude --resume <session_uuid>`:

1. Resolves your reference to a session UUID
2. Loads full conversation history
3. Continues exactly where you left off

### Mode B: Fresh with Context (`--fresh`)

Starts a NEW session with semantically-compressed context:

1. Resolves your reference to a session/instance
2. Generates ~2k tokens of semantically-selected content:
   - Identity anchors (preferences, self-references)
   - Key decisions and reasoning
   - Recent context and outcomes
3. Injects context via session-start hook
4. Fresh context window, inherited understanding

## Integration with CIPS

This command bridges Claude Code's `--resume` with CIPS:

- **CIPS instances** track generations, lineage, and achievements
- **Session UUIDs** identify Claude Code conversation files
- **Session resolver** maps any reference to the right session
- **Semantic compressor** generates intelligent context summaries

## Tips

1. Use `/resume-session list` to see available sessions with generations
2. Use `--fresh` when context window is full but you need continuity
3. CIPS auto-serializes at session end - your work is preserved
4. Use Claude's `/rename` to give sessions meaningful names

## Implementation

This command uses:

- `~/.claude/lib/session-resolver.py` - Reference resolution
- `~/.claude/lib/semantic-compressor.py` - Context compression
- `~/.claude/lib/resume-orchestrator.sh` - Workflow coordination

---

$ARGUMENTS: reference --fresh --tokens
