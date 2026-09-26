#!/usr/bin/env python3
"""Builds the macOS app icon master from the shared square app icon.

    python3 tool/macos_icon.py && dart run flutter_launcher_icons

iOS and Android mask a full-bleed square icon themselves; macOS does not.
Mac icons follow Apple's grid instead: an 824x824 rounded square with a soft
drop shadow, centred on a transparent 1024x1024 canvas. This writes that
master to assets/icon/app_icon_macos.png, which the `macos` section of
flutter_launcher_icons (pubspec.yaml) turns into the Mac icon set.

Needs Pillow.
"""
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter

ROOT = Path(__file__).resolve().parent.parent
SOURCE = ROOT / "assets/icon/app_icon.png"
TARGET = ROOT / "assets/icon/app_icon_macos.png"

CANVAS = 1024
BODY = 824  # Apple's macOS icon grid
RADIUS = 185
SCALE = 4  # draw the mask large, then downsample, for smooth corners


def rounded_mask(size: int, radius: int) -> Image.Image:
    big = Image.new("L", (size * SCALE, size * SCALE), 0)
    ImageDraw.Draw(big).rounded_rectangle(
        (0, 0, size * SCALE - 1, size * SCALE - 1), radius=radius * SCALE, fill=255
    )
    return big.resize((size, size), Image.LANCZOS)


def main() -> None:
    art = Image.open(SOURCE).convert("RGBA").resize((BODY, BODY), Image.LANCZOS)
    mask = rounded_mask(BODY, RADIUS)
    offset = (CANVAS - BODY) // 2

    shadow = Image.new("RGBA", (CANVAS, CANVAS), (0, 0, 0, 0))
    shadow_body = Image.new("RGBA", (BODY, BODY), (0, 0, 0, 90))
    shadow.paste(shadow_body, (offset, offset + 12), mask)
    shadow = shadow.filter(ImageFilter.GaussianBlur(14))

    icon = Image.new("RGBA", (CANVAS, CANVAS), (0, 0, 0, 0))
    icon.alpha_composite(shadow)
    body = Image.new("RGBA", (BODY, BODY), (0, 0, 0, 0))
    body.paste(art, (0, 0), mask)
    icon.alpha_composite(body, (offset, offset))

    icon.save(TARGET)
    print(f"wrote {TARGET.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
