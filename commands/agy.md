# /agy Command

Open file in Google Antigravity IDE with intelligent file inference.

## Usage

```bash
/agy <target>
```

Where `<target>` can be:

- Exact filename: `/agy CLAUDE.md`
- Partial match: `/agy auth`
- Description: `/agy the hook we worked on`

## Inference Priority

1. Exact path match
2. Exact filename anywhere in project
3. Fuzzy match (case-insensitive, most recent)
4. Recent git files
5. Description pattern matching

## Examples

| Command | Resolves To |
|---------|-------------|
| `/agy CLAUDE.md` | `./CLAUDE.md` |
| `/agy skill` | Most recent `*skill*` file |
| `/agy auth controller` | `AuthController.ts` |
| `/agy schema` | `schema.prisma` |
| `/agy readme` | `README.md` |

## Fast-Fail

If no match found in <3 seconds:

```text
File not inferred. Be more specific.
```

## Helper Script

```bash
~/.claude/lib/agy.sh <target>
```

## Aliases

- `/antigravity`
- `/ag`

## Related

- Antigravity binary: `~/.antigravity/antigravity/bin/antigravity`
- Skill definition: `~/.claude/skills/agy/SKILL.md`
