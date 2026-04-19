#!/usr/bin/env python3
"""Generate platform icon assets for SpaceWarrior.

Composites assets/player1.png onto a dark square to produce:
  - assets/icon-256.png   (256x256 RGBA, used by LÖVE t.window.icon)
  - assets/icon.ico       (multi-size ICO for Windows)
  - assets/icon.icns      (macOS icon)

Re-run this script whenever the source art changes.  Committed outputs
in assets/ are what the build pipeline bundles.

Requires Pillow (`pip install pillow`).
"""
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
SRC_SPRITE = ROOT / "assets" / "player1.png"

OUT_PNG  = ROOT / "assets" / "icon-256.png"
OUT_ICO  = ROOT / "assets" / "icon.ico"
OUT_ICNS = ROOT / "assets" / "icon.icns"

BG_COLOR = (12, 18, 36, 255)   # dark navy — matches the in-game background


def build_master() -> Image.Image:
    """Return a 1024x1024 composite: sprite centred on a dark square."""
    size = 1024
    canvas = Image.new("RGBA", (size, size), BG_COLOR)

    sprite = Image.open(SRC_SPRITE).convert("RGBA")
    target = int(size * 0.72)
    sprite = sprite.resize((target, target), Image.LANCZOS)

    offset = ((size - target) // 2, (size - target) // 2)
    canvas.alpha_composite(sprite, dest=offset)
    return canvas


def main() -> None:
    if not SRC_SPRITE.exists():
        raise SystemExit(f"Source sprite missing: {SRC_SPRITE}")

    master = build_master()

    master.resize((256, 256), Image.LANCZOS).save(OUT_PNG, format="PNG")
    print(f"wrote {OUT_PNG}")

    ico_sizes = [(16, 16), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)]
    master.save(OUT_ICO, format="ICO", sizes=ico_sizes)
    print(f"wrote {OUT_ICO}")

    icns_sizes = [(16, 16), (32, 32), (64, 64), (128, 128),
                  (256, 256), (512, 512), (1024, 1024)]
    master.save(OUT_ICNS, format="ICNS", sizes=icns_sizes)
    print(f"wrote {OUT_ICNS}")


if __name__ == "__main__":
    main()
