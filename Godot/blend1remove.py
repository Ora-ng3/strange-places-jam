#!/usr/bin/env python3
"""
Recursively delete all .blend1 files (Blender backup files).

Usage:
    python delete_blend1.py /path/to/project --dry-run
    python delete_blend1.py /path/to/project --force
"""

import argparse
from pathlib import Path


def find_blend1_files(root: Path):
    """Yield all .blend1 files recursively."""
    for path in root.rglob("*.blend1"):
        if path.is_file():
            yield path


def main():
    parser = argparse.ArgumentParser(
        description="Recursively delete all .blend1 files."
    )
    parser.add_argument("root", type=Path, help="Root directory to search")
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Show what would be deleted without deleting",
    )
    parser.add_argument(
        "--force",
        action="store_true",
        help="Delete without confirmation",
    )
    parser.add_argument(
        "--verbose",
        action="store_true",
        help="Print every deleted file",
    )

    args = parser.parse_args()

    root = args.root.resolve()

    if not root.exists() or not root.is_dir():
        raise SystemExit(f"Error: {root} is not a valid directory.")

    files = list(find_blend1_files(root))

    if not files:
        print("No .blend1 files found.")
        return

    print(f"Found {len(files)} .blend1 files.")

    if args.dry_run:
        print("\nDry run mode — no files will be deleted.\n")
        for f in files:
            print(f)
        return

    if not args.force:
        confirm = input("Are you sure you want to delete them? (y/N): ").lower()
        if confirm != "y":
            print("Aborted.")
            return

    deleted = 0

    for f in files:
        try:
            f.unlink()
            deleted += 1
            if args.verbose:
                print(f"Deleted: {f}")
        except Exception as e:
            print(f"Error deleting {f}: {e}")

    print(f"\nDeleted {deleted} files.")


if __name__ == "__main__":
    main()