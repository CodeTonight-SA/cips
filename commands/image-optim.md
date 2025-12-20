# /image-optim Command

Optimize images using ImageOptim (macOS only).

## Usage

```bash
/image-optim <file|directory>
/image-optim screenshot.png
/image-optim ./assets/
/image-optim *.jpg
```

## Options

- `--resize <WxH>` - Resize before optimizing (uses ImageMagick)
- `--convert <format>` - Convert format first (png, jpg, webp)

## Examples

```bash
/image-optim hero.png                    # Basic optimization
/image-optim ./images/                   # Batch directory
/image-optim --resize 2000x2000 big.jpg  # Resize then optimize
/image-optim --convert webp photo.png    # Convert to WebP
```

## Skill Reference

@skills/image-optim/SKILL.md
