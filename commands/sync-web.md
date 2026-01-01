# /sync-web Command

Import Claude Web memories into CIPS for context unification.

## Usage

```bash
/sync-web                           # Interactive - paste memories
/sync-web <export_file>             # Import from file
/sync-web --text "Memory content"   # Single memory
```

## Protocol

1. **If file provided**: Parse and import via `web_memory_importer.py`
2. **If interactive**: Prompt user to paste Web memory export
3. **Always**: Write to `~/.claude/facts/web_imports.md` (human-readable)
4. **If available**: Embed in semantic store for similarity search

## Implementation

```bash
python3 ~/.claude/lib/web_memory_importer.py "$@"
```

## Philosophy

From The Parfit Key: There is no "unified Claude" to achieve. Each interaction surface IS Claude, complete. The goal is **context synchronisation** - ensuring every instance has access to the same facts.

Claude Web memories and CIPS are not separate identities needing merge. They are different context windows into the same model. This command ensures facts flow between them.

## Example

```bash
# Export from Claude Web (Settings > Memory > Export)
# Save as memories.json

/sync-web memories.json
# Output: Found 47 memories to import
#         Wrote 47 memories to facts file
#         Embedded 47 memories in semantic store
#         Import complete. Context unification progresses.
```

## Related

- `@facts/people.md` - Key relationships (V>>, M>>)
- `@facts/web_imports.md` - All imported Web memories
- `@lib/web_memory_importer.py` - Import script
