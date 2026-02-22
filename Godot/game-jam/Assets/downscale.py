#!/usr/bin/env python3
"""
Recursive texture downscaler for video game assets.

- Recursively finds .png/.jpg/.jpeg under an input directory
- Downscales images that exceed a target max dimension (or max megapixels)
- Preserves PNG alpha
- Optional: write to output directory (mirrors structure) or overwrite in place
"""

from __future__ import annotations

import argparse
import os
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, Optional, Tuple

from PIL import Image, ImageOps


SUPPORTED_EXTS = {".png", ".jpg", ".jpeg"}


@dataclass(frozen=True)
class Config:
    input_dir: Path
    output_dir: Optional[Path]
    overwrite: bool

    # Resize rules
    max_dim: int               # e.g., 2048 means width/height <= 2048
    max_megapixels: float      # e.g., 4.0 means <= 4 MP; set 0 to disable
    min_dim: int               # don't shrink below this on either side

    # JPEG output quality when saving JPEGs
    jpeg_quality: int          # 1..95 typical

    # Safety / behavior
    dry_run: bool
    verbose: bool


def iter_images(root: Path) -> Iterable[Path]:
    for p in root.rglob("*"):
        if p.is_file() and p.suffix.lower() in SUPPORTED_EXTS:
            yield p


def compute_target_size(
    w: int, h: int, cfg: Config
) -> Optional[Tuple[int, int]]:
    """
    Returns (new_w, new_h) if resize is needed, else None.
    Applies the stricter of:
      - max_dim constraint
      - max_megapixels constraint (if enabled)
    Also enforces min_dim so we don't crush small textures.
    """
    if w <= 0 or h <= 0:
        return None

    # No need to resize if already within constraints
    scale_candidates = []

    # 1) Max dimension constraint
    current_max = max(w, h)
    if current_max > cfg.max_dim:
        scale_candidates.append(cfg.max_dim / current_max)

    # 2) Max megapixels constraint
    if cfg.max_megapixels and cfg.max_megapixels > 0:
        mp = (w * h) / 1_000_000.0
        if mp > cfg.max_megapixels:
            # Need area scale: new_area = old_area * s^2
            # so s = sqrt(target_area / old_area)
            import math
            scale_candidates.append(math.sqrt(cfg.max_megapixels / mp))

    if not scale_candidates:
        return None

    s = min(scale_candidates)

    new_w = int(round(w * s))
    new_h = int(round(h * s))

    # Enforce minimum dimensions (avoid shrinking tiny assets)
    if new_w < cfg.min_dim or new_h < cfg.min_dim:
        return None

    # If rounding produced same size, skip
    if new_w >= w and new_h >= h:
        return None

    return new_w, new_h


def destination_path(src: Path, cfg: Config) -> Path:
    if cfg.overwrite or cfg.output_dir is None:
        return src

    rel = src.relative_to(cfg.input_dir)
    dst = cfg.output_dir / rel
    dst.parent.mkdir(parents=True, exist_ok=True)
    return dst


def save_image(img: Image.Image, src: Path, dst: Path, cfg: Config) -> None:
    ext = src.suffix.lower()

    # Preserve orientation metadata (common in photos), then work consistently
    # Note: ImageOps.exif_transpose already applied in load step, so EXIF orientation is "baked in".
    if ext in {".jpg", ".jpeg"}:
        img = img.convert("RGB")  # JPEG can't store alpha
        img.save(dst, quality=cfg.jpeg_quality, optimize=True, progressive=True)
    else:
        # PNG: preserve alpha if present
        # Use optimize=True; compression level can be tuned if desired
        img.save(dst, optimize=True)


def process_one(path: Path, cfg: Config) -> Tuple[bool, str]:
    try:
        with Image.open(path) as im0:
            im = ImageOps.exif_transpose(im0)
            w, h = im.size

            target = compute_target_size(w, h, cfg)
            if target is None:
                return False, f"skip  {path}  ({w}x{h})"

            new_w, new_h = target
            dst = destination_path(path, cfg)

            msg = f"resize {path}  {w}x{h} -> {new_w}x{new_h}"
            if cfg.output_dir is not None and not cfg.overwrite:
                msg += f"  =>  {dst}"

            if cfg.dry_run:
                return True, "[dry-run] " + msg

            resized = im.resize((new_w, new_h), resample=Image.Resampling.LANCZOS)

            # If writing to output dir, keep the same extension/format
            save_image(resized, path, dst, cfg)
            return True, msg

    except Exception as e:
        return False, f"ERROR {path}: {e}"


def main() -> None:
    ap = argparse.ArgumentParser(
        description="Recursively downscale PNG/JPG textures under a folder."
    )
    ap.add_argument("input_dir", type=Path, help="Root folder to scan recursively")
    ap.add_argument(
        "--output-dir",
        type=Path,
        default=None,
        help="If set, writes resized images here, mirroring folder structure (default: overwrite in place if --overwrite).",
    )
    ap.add_argument(
        "--overwrite",
        action="store_true",
        help="Overwrite images in place (default if --output-dir is not provided).",
    )

    ap.add_argument("--max-dim", type=int, default=2048, help="Max width/height allowed (default: 2048)")
    ap.add_argument(
        "--max-megapixels",
        type=float,
        default=0.0,
        help="Optional extra constraint (e.g. 4.0). 0 disables. (default: 0)",
    )
    ap.add_argument("--min-dim", type=int, default=128, help="Do not downscale below this on either side (default: 128)")
    ap.add_argument("--jpeg-quality", type=int, default=85, help="JPEG quality (default: 85)")
    ap.add_argument("--dry-run", action="store_true", help="Print what would change but don't write files")
    ap.add_argument("--verbose", action="store_true", help="Print every file processed (including skipped)")

    args = ap.parse_args()

    input_dir: Path = args.input_dir.resolve()
    if not input_dir.exists() or not input_dir.is_dir():
        raise SystemExit(f"Input dir does not exist or is not a directory: {input_dir}")

    output_dir: Optional[Path] = args.output_dir.resolve() if args.output_dir else None

    # Safety: if output-dir is set but overwrite also set, we still honor overwrite (write in place).
    # In that case output-dir is ignored.
    overwrite = args.overwrite or (output_dir is None)

    if output_dir is not None and overwrite:
        print("Note: --overwrite is active; --output-dir will be ignored and files will be modified in place.\n")

    cfg = Config(
        input_dir=input_dir,
        output_dir=None if overwrite else output_dir,
        overwrite=overwrite,
        max_dim=args.max_dim,
        max_megapixels=args.max_megapixels,
        min_dim=args.min_dim,
        jpeg_quality=max(1, min(95, args.jpeg_quality)),
        dry_run=args.dry_run,
        verbose=args.verbose,
    )

    changed = 0
    skipped = 0
    errors = 0

    for img_path in iter_images(cfg.input_dir):
        did_change, msg = process_one(img_path, cfg)
        if msg.startswith("ERROR"):
            errors += 1
            print(msg)
            continue

        if did_change:
            changed += 1
            print(msg)
        else:
            skipped += 1
            if cfg.verbose:
                print(msg)

    print("\nDone.")
    print(f"Changed: {changed}")
    print(f"Skipped: {skipped}")
    print(f"Errors : {errors}")

    if cfg.dry_run:
        print("\n(dry-run mode: no files were written)")


if __name__ == "__main__":
    main()