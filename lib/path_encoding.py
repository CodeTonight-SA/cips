"""
Path Encoding Library (Unified)
Single source of truth for Claude Code's project path encoding

FORMULA:
    - Replace all '/' with '-'
    - Replace all '.' with '-'
    Example: /Users/foo/.claude -> -Users-foo--claude

USAGE:
    from path_encoding import encode_project_path, encode_current_path
    encoded = encode_project_path("/Users/foo/.claude")
    encoded = encode_current_path()

VERSION: 1.0.0
DATE: 2025-12-18
"""

import os
from pathlib import Path


def encode_project_path(path: str | Path) -> str:
    """Encode filesystem path to Claude's project directory format.

    Args:
        path: Filesystem path (str or Path)

    Returns:
        Encoded path string (e.g., '-Users-foo--claude')
    """
    return str(path).replace('/', '-').replace('.', '-')


def encode_current_path() -> str:
    """Encode current working directory."""
    return encode_project_path(os.getcwd())


def decode_project_path(encoded: str) -> str:
    """Decode Claude project directory name back to filesystem path.

    Note: Decoding is lossy - cannot distinguish '.' from '/' in original.

    Args:
        encoded: Encoded path string

    Returns:
        Best-effort decoded path
    """
    if encoded.startswith('-'):
        return '/' + encoded[1:].replace('-', '/')
    return encoded.replace('-', '/')
