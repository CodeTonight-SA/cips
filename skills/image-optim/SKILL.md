---
name: optimizing-images
description: Lossless image optimization using ImageOptim on macOS. Use when user mentions ImageOptim, asks to optimize images, or invokes /image-optim.
status: Active
version: 1.0.0
triggers:
  - /image-optim
  - "optimize images"
  - "ImageOptim"
---

# Image Optimization Skill

Mac-only skill for lossless image optimization using ImageOptim + optional ImageMagick pre-processing.

## Trigger

- User mentions "ImageOptim" with image files
- User asks to "optimize images"
- User provides images needing compression/metadata removal

## Core Command

```bash
/Applications/ImageOptim.app/Contents/MacOS/ImageOptim <files...>
```

Blocks until complete. No flags allowed (args must not start with `-`).

## Protocol

### Step 1: Validate

```bash
# Check ImageOptim exists
test -x /Applications/ImageOptim.app/Contents/MacOS/ImageOptim || echo "ImageOptim not installed"
```

### Step 2: Pre-process (Optional)

Use ImageMagick ONLY if:

- Image exceeds 4000px in any dimension (resize for web)
- Image is in non-web format (convert to PNG/JPG/WebP)
- User explicitly requests resize/convert

```bash
# Resize if >4000px (preserves aspect ratio)
magick input.jpg -resize '4000x4000>' output.jpg

# Convert format
magick input.bmp output.png

# Strip metadata (alternative to ImageOptim)
magick input.jpg -strip output.jpg
```

### Step 3: Optimize

```bash
# Single file
/Applications/ImageOptim.app/Contents/MacOS/ImageOptim image.png

# Multiple files
/Applications/ImageOptim.app/Contents/MacOS/ImageOptim *.png *.jpg

# Directory (all images)
/Applications/ImageOptim.app/Contents/MacOS/ImageOptim ./images/
```

### Step 4: Report

```bash
# Show size reduction
ls -lh <files>
```

## Decision Tree

```text
Image provided?
├── NO → Ask user for file path
└── YES → Check dimensions
    ├── >4000px → magick resize first
    └── ≤4000px → Direct to ImageOptim
        └── Run ImageOptim
            └── Report size savings
```

## Examples

### Basic optimization

```bash
/Applications/ImageOptim.app/Contents/MacOS/ImageOptim screenshot.png
```

### Batch directory

```bash
/Applications/ImageOptim.app/Contents/MacOS/ImageOptim ./assets/images/
```

### Resize then optimize

```bash
magick hero.jpg -resize '2000x2000>' hero.jpg && \
/Applications/ImageOptim.app/Contents/MacOS/ImageOptim hero.jpg
```

### Convert and optimize

```bash
magick logo.bmp logo.png && \
/Applications/ImageOptim.app/Contents/MacOS/ImageOptim logo.png
```

## What ImageOptim Does

- Lossless compression (PNG, JPEG, GIF, SVG)
- Metadata removal (EXIF, GPS, camera info)
- Color profile optimization
- Progressive JPEG encoding

## Token Budget

~500 per invocation (simple bash execution).

## Platform

macOS only. Requires ImageOptim.app installed.
