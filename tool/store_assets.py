#!/usr/bin/env python3
"""Builds store images from simulator captures made by tool/store_screenshots.sh.

    python3 tool/store_assets.py <captures-dir>

<captures-dir> holds iphone-en/, iphone-ar/, ipad-en/, ipad-ar/ (PNG per
screen). Writes:
  ios/fastlane/screenshots/<locale>/        App Store iPhone 6.9" + iPad 13"
  android/fastlane/metadata/android/<locale>/images/
      phoneScreenshots/  iPhone captures minus the iOS status bar and home
                         indicator (also brings them inside Play's 2:1 limit)
      featureGraphic.png 1024x500, localized
      icon.png           512x512 (default locale only; others inherit it)

Needs Pillow built with libraqm so Arabic is shaped correctly.
"""
import shutil
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont, features

ROOT = Path(__file__).resolve().parent.parent
FONTS = ROOT / "assets/fonts/almarai"
IOS_SHOTS = ROOT / "ios/fastlane/screenshots"
PLAY_META = ROOT / "android/fastlane/metadata/android"

# iPhone 6.9" safe-area insets at 3x: 62pt status bar, 34pt home indicator.
STATUS_BAR_PX, HOME_INDICATOR_PX = 186, 102

LOCALES = {
    # capture suffix: (App Store locale, Play locale)
    "en": ("en-US", "en-US"),
    "ar": ("ar-SA", "ar"),
}

COPY = {
    "en": ("Qima", "Every asset you hold. One number.", "Gold · Silver · Crypto · Stocks · Currencies"),
    "ar": ("قيمة", "كل ما تملكه. في رقم واحد.", "ذهب · فضة · عملات رقمية · أسهم · عملات"),
}

BG_TOP, BG_BOTTOM, GOLD = (15, 17, 22), (8, 9, 12), (230, 186, 77)


def font(weight: str, size: int) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(str(FONTS / f"Almarai-{weight}.ttf"), size, layout_engine=ImageFont.Layout.RAQM)


def rounded(image: Image.Image, radius: int) -> Image.Image:
    mask = Image.new("L", image.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, *image.size), radius, fill=255)
    out = image.convert("RGBA")
    out.putalpha(mask)
    return out


def feature_graphic(lang: str, phone_shot: Path, icon: Path) -> Image.Image:
    w, h = 1024, 500
    canvas = Image.new("RGB", (w, h))
    draw = ImageDraw.Draw(canvas)
    for y in range(h):
        t = y / (h - 1)
        draw.line([(0, y), (w, y)], fill=tuple(round(a + (b - a) * t) for a, b in zip(BG_TOP, BG_BOTTOM)))

    rtl = lang == "ar"
    # Soft gold glow behind the phone.
    glow = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    gx = 230 if rtl else 800
    ImageDraw.Draw(glow).ellipse((gx - 260, -120, gx + 260, 400), fill=(*GOLD, 70))
    canvas.paste(glow.filter(ImageFilter.GaussianBlur(90)), (0, 0), glow.filter(ImageFilter.GaussianBlur(90)))

    # Phone: the real watchlist capture, cropped by the bottom edge.
    phone = Image.open(phone_shot)
    phone = phone.resize((300, round(phone.height * 300 / phone.width)), Image.LANCZOS)
    phone = rounded(phone, 42)
    px = 90 if rtl else w - 90 - phone.width
    shadow = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    ImageDraw.Draw(shadow).rounded_rectangle((px, 58, px + phone.width, 58 + phone.height), 42, fill=(0, 0, 0, 160))
    shadow = shadow.filter(ImageFilter.GaussianBlur(24))
    canvas.paste(shadow, (0, 0), shadow)
    canvas.paste(phone, (px, 44), phone)
    ImageDraw.Draw(canvas).rounded_rectangle((px, 44, px + phone.width - 1, 44 + phone.height), 42, outline=(52, 55, 64), width=2)

    # Brand block.
    title, tagline, classes = COPY[lang]
    logo = rounded(Image.open(icon).resize((104, 104), Image.LANCZOS), 24)
    text = ImageDraw.Draw(canvas)
    edge = w - 64 if rtl else 64
    anchor = "ra" if rtl else "la"
    direction = "rtl" if rtl else "ltr"
    canvas.paste(logo, (edge - 104 if rtl else edge, 96), logo)
    text.text((edge, 228), title, font=font("ExtraBold", 76), fill=(255, 255, 255), anchor=anchor, direction=direction)
    text.text((edge, 330), tagline, font=font("Bold", 30), fill=(255, 255, 255), anchor=anchor, direction=direction)
    text.text((edge, 382), classes, font=font("Regular", 22), fill=GOLD, anchor=anchor, direction=direction)
    return canvas


def main() -> None:
    if not features.check("raqm"):
        sys.exit("Pillow was built without libraqm; Arabic text would not be shaped.")
    captures = Path(sys.argv[1]).resolve()
    icon = ROOT / "assets/icon/app_icon.png"

    for lang, (ios_locale, play_locale) in LOCALES.items():
        ios_dir = IOS_SHOTS / ios_locale
        shutil.rmtree(ios_dir, ignore_errors=True)
        ios_dir.mkdir(parents=True)
        for device in ("iphone", "ipad"):
            for shot in sorted((captures / f"{device}-{lang}").glob("*.png")):
                shutil.copy(shot, ios_dir / f"{device}_{shot.name}")

        images = PLAY_META / play_locale / "images"
        phone_dir = images / "phoneScreenshots"
        shutil.rmtree(phone_dir, ignore_errors=True)
        phone_dir.mkdir(parents=True)
        shots = sorted((captures / f"iphone-{lang}").glob("*.png"))
        for index, shot in enumerate(shots, start=1):
            image = Image.open(shot).convert("RGB")
            image.crop((0, STATUS_BAR_PX, image.width, image.height - HOME_INDICATOR_PX)).save(phone_dir / f"{index}.png")

        feature_graphic(lang, shots[0], icon).save(images / "featureGraphic.png")

    Image.open(icon).convert("RGB").resize((512, 512), Image.LANCZOS).save(PLAY_META / "en-US/images/icon.png")
    print("Store assets written.")


if __name__ == "__main__":
    main()
