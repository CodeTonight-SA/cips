# Image Optim Agent

Lightweight agent for image optimization on macOS.

## Activation

- Image files provided with optimization request
- "optimize images", "shrink images", "remove metadata"
- Explicit `/image-optim` command

## Model

Haiku (simple bash execution, no complex reasoning needed)

## Token Budget

~500 per invocation

## Protocol

1. Validate ImageOptim exists
2. Check if pre-processing needed (size >4000px, format conversion)
3. Run ImageMagick if needed
4. Run ImageOptim
5. Report size savings

## Tools

- Bash (ImageOptim CLI, ImageMagick)
- Read (check file existence)

## Skill Reference

@skills/image-optim/SKILL.md
