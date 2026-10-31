#!/usr/bin/env python3
"""Builds every generated file under brand/ from one token source.

    python3 brand/tool/build_brand.py

Writes:
  brand/tokens.json              design tokens, light and dark
  brand/tokens.css               the same tokens as CSS custom properties
  brand/flutter/qima_tokens.dart the same tokens as Dart constants
  brand/contrast.md              measured WCAG ratios for every recommended pair
  brand/assets/**                logo, wordmark and icon exports (SVG and PNG)

The script fails if any recommended text pair is under 4.5:1 or any UI pair
under 3:1, so the tables in guidelines.md can't drift from the tokens.

Needs fontTools and Pillow, and Google Chrome for SVG-to-PNG rendering.
"""
from __future__ import annotations

import base64
import io
import json
import shutil
import subprocess
import sys
import tempfile
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

from fontTools.pens.boundsPen import BoundsPen
from fontTools.pens.svgPathPen import SVGPathPen
from fontTools.pens.transformPen import TransformPen
from fontTools.ttLib import TTFont
from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
BRAND = ROOT / "brand"
ASSETS = BRAND / "assets"
FONT = ROOT / "assets/fonts/almarai/Almarai-Bold.ttf"
CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

# --------------------------------------------------------------------------
# Token source. Values marked "changed" differ from lib/theme/qima_colors.dart;
# changes.md lists each one and why.
# --------------------------------------------------------------------------

INK_LIGHT = (0x11, 0x13, 0x18)
WHITE = (0xFF, 0xFF, 0xFF)

# name: (dark, light, role). A value is "#RRGGBB" or (rgb, alpha).
COLORS: dict[str, tuple[object, object, str]] = {
    "bg0": ("#08090C", "#ECEEF2", "Screen background, bottom of the screen gradient"),
    "bg1": ("#0F1116", "#F7F8FA", "Screen background top, navigation bar"),
    "surfaceTop": ("#1F2229", "#FFFFFF", "Card fill, top of gradient"),
    "surfaceBottom": ("#191B21", "#FAFAFC", "Card fill, bottom of gradient"),
    "tileTop": ("#2B2F39", "#F2F3F6", "Inset tile, chip and segment track"),
    "tileBottom": ("#22252D", "#EAECF0", "Inset tile gradient end"),
    "segmentThumb": ("#454A56", "#FFFFFF", "Selected segment of a segmented control"),
    "overlay": ("#262A33", "#FFFFFF", "Menus, dialogs, sheets"),
    "hairline": ((WHITE, 0.10), (INK_LIGHT, 0.10), "Card borders, dividers (decorative)"),
    "hairlineStrong": ((WHITE, 0.18), (INK_LIGHT, 0.18), "Outlined button borders (decorative; the label carries meaning)"),
    "textPrimary": ("#FFFFFF", "#111318", "Headings, body text, figures"),
    "textSecondary": ((WHITE, 0.68), (INK_LIGHT, 0.76), "Supporting text, row subtitles (changed: more distinct from tertiary)"),
    "textTertiary": ((WHITE, 0.52), (INK_LIGHT, 0.60), "Captions, timestamps, unselected tab labels"),
    "up": ("#3DBE6E", "#166B2E", "Price or value went up"),
    "down": ("#FF6B61", "#B42A26", "Price or value went down"),
    "brand": ("#E6BA4D", "#D4A72C", "Gold fill: the one primary button per screen, brand moments. Never text."),
    "brandText": ("#E6BA4D", "#8A6410", "Gold text and icons: text buttons, links, selected tab"),
    "brandIndicator": ("#E6BA4D", "#A87B14", "Gold UI marks that must reach 3:1: selected-chip border, switch track, focus ring (new)"),
    "onBrand": ("#08090C", "#1A1406", "Text and icons on a brand fill"),
    "success": ("#3DBE6E", "#166B2E", "Done, saved, restored (same values as up)"),
    "warning": ("#F5A524", "#9A4D00", "Needs attention, not broken (new)"),
    "error": ("#FF6B61", "#B42A26", "Failed or invalid (same values as down)"),
    "info": ("#6EA8FF", "#1F62C9", "Neutral notices (new)"),
    "shadow": (((0, 0, 0), 0.45), ((0x1B, 0x22, 0x30), 0.08), "Card shadow"),
    "scrim": (((0, 0, 0), 0.55), (INK_LIGHT, 0.32), "Behind modal sheets and dialogs"),
    "accentGold": ("#E6BA4D", "#A87B14", "Gold instrument tint (changed in light: now equals brandIndicator)"),
    "accentSilver": (((199, 199, 199), 0.78), "#7A7D83", "Silver instrument tint (changed in light)"),
    "accentPlatinum": ("#A9C4DD", "#5A7FA5", "Platinum and palladium tint (changed in light)"),
    "accentCrypto": ("#F28C33", "#C2620F", "Crypto tint (changed in light)"),
    "accentFiat": ("#3FB8C9", "#10808F", "Currency tint (changed in light)"),
    "accentStock": ("#6B8CEB", "#4A6FDB", "Stock tint"),
    "accentIndex": ("#9975E0", "#7447C9", "Index tint"),
}

TEXT_TOKENS = ["textPrimary", "textSecondary", "textTertiary", "brandText", "up", "down",
               "success", "warning", "error", "info"]
TEXT_BACKGROUNDS = ["bg0", "bg1", "surfaceTop", "surfaceBottom", "tileTop", "overlay"]
UI_TOKENS = ["brandIndicator", "accentGold", "accentSilver", "accentPlatinum", "accentCrypto",
             "accentFiat", "accentStock", "accentIndex"]
UI_BACKGROUNDS = ["bg0", "surfaceTop", "tileTop"]

# Type scale. Latin uses the platform font in the app (SF Pro / Roboto);
# Arabic uses Almarai. size/line in logical px, tracking in px.
TYPE = [
    # name, size, line, weight, tracking, arabicSize, arabicLine, use
    ("display", 40, 44, 700, -0.5, 40, 50, "The asset price on the detail screen"),
    ("hero", 30, 36, 700, -0.3, 30, 40, "Portfolio and zakat totals on hero cards"),
    ("title1", 22, 28, 700, 0, 22, 32, "Large screen titles, sheet titles"),
    ("title2", 17, 22, 600, 0, 17, 26, "Card titles, navigation bar titles, row prices"),
    ("bodyLarge", 16, 22, 400, 0, 16, 26, "Paragraphs, form fields, onboarding body"),
    ("rowTitle", 15, 20, 600, 0, 15, 24, "Watchlist and holdings row names, button labels"),
    ("body", 14, 20, 400, 0, 14, 22, "Secondary paragraphs, help text"),
    ("caption", 13, 18, 500, 0, 14.5, 22, "Row subtitles, footers, helper text"),
    ("overline", 12, 16, 600, 0.5, 13.5, 20, "Section headers and metric labels"),
    ("micro", 11, 14, 500, 0, 12.5, 18, "Chart axis labels, badges"),
]

SPACE = {"3xs": 2, "2xs": 4, "xs": 6, "sm": 10, "md": 16, "lg": 20, "xl": 28}
RADIUS = {"xs": 6, "tile": 14, "card": 22, "pill": 100}
MOTION = {
    "duration": {"instant": 0, "quick": 150, "standard": 250, "emphasized": 300},
    "easing": {
        "standard": [0.22, 0.61, 0.36, 1.0],   # matches site/style.css --ease and Flutter Curves.easeOutCubic
        "exit": [0.55, 0.06, 0.68, 0.19],      # Curves.easeInCubic
    },
}
ELEVATION = {
    "e0": {"use": "Tiles inside cards", "shadows": []},
    "e1": {"use": "Cards", "shadows": [{"color": "shadow", "blur": 10, "y": 3}]},
    "e2": {"use": "Hero cards (portfolio, zakat due)", "shadows": [
        {"color": "accent@0.10", "blur": 20, "y": 6}, {"color": "shadow", "blur": 10, "y": 3}]},
    "e3": {"use": "Menus, dialogs, sheets", "shadows": [{"color": "shadow", "blur": 24, "y": 8}]},
}
SIZE = {"touchTargetIOS": 44, "touchTargetAndroid": 48, "iconSm": 16, "iconMd": 20, "iconLg": 24,
        "focusRing": 2, "selectedBorder": 1.5}

# --------------------------------------------------------------------------
# Colour maths
# --------------------------------------------------------------------------


def hex_rgb(h: str) -> tuple[int, int, int]:
    h = h.lstrip("#")
    return tuple(int(h[i:i + 2], 16) for i in (0, 2, 4))  # type: ignore[return-value]


def resolve(value: object, over: tuple[int, int, int] | None = None) -> tuple[int, int, int]:
    """Opaque RGB of a token value, compositing alpha over [over]."""
    if isinstance(value, str):
        return hex_rgb(value)
    rgb, a = value  # type: ignore[misc]
    assert over is not None, "alpha colour needs a backdrop"
    return tuple(round(c * a + b * (1 - a)) for c, b in zip(rgb, over))  # type: ignore[return-value]


def luminance(rgb: tuple[int, int, int]) -> float:
    def ch(c: int) -> float:
        c2 = c / 255
        return c2 / 12.92 if c2 <= 0.04045 else ((c2 + 0.055) / 1.055) ** 2.4
    r, g, b = rgb
    return 0.2126 * ch(r) + 0.7152 * ch(g) + 0.0722 * ch(b)


def ratio(a: tuple[int, int, int], b: tuple[int, int, int]) -> float:
    la, lb = sorted([luminance(a), luminance(b)], reverse=True)
    return (la + 0.05) / (lb + 0.05)


def css_value(value: object) -> str:
    if isinstance(value, str):
        return value.upper()
    (r, g, b), a = value  # type: ignore[misc]
    return f"rgba({r}, {g}, {b}, {a:g})"


def dart_value(value: object) -> str:
    if isinstance(value, str):
        return f"Color(0xFF{value.lstrip('#').upper()})"
    (r, g, b), a = value  # type: ignore[misc]
    return f"Color.fromRGBO({r}, {g}, {b}, {a:g})"


def mode_index(mode: str) -> int:
    return 0 if mode == "dark" else 1


def check_contrast() -> str:
    """Measures every recommended pair, fails on any miss, returns markdown."""
    failures: list[str] = []
    out = ["# Measured contrast", "",
           "Generated by `brand/tool/build_brand.py`. WCAG 2.2 relative luminance; alpha colours are",
           "composited over the background they sit on. Text needs 4.5:1 (AA body text); UI marks need 3:1.",
           ""]
    for mode in ("dark", "light"):
        i = mode_index(mode)
        out += [f"## Text on background, {mode}", "",
                "| Text token | " + " | ".join(TEXT_BACKGROUNDS) + " | Lowest |",
                "|---|" + "---:|" * (len(TEXT_BACKGROUNDS) + 1)]
        for t in TEXT_TOKENS:
            cells, low = [], 99.0
            for bgn in TEXT_BACKGROUNDS:
                bg = resolve(COLORS[bgn][i])
                r = ratio(resolve(COLORS[t][i], bg), bg)
                low = min(low, r)
                cells.append(f"{r:.2f}")
                if r < 4.5:
                    failures.append(f"{mode} {t} on {bgn}: {r:.2f}")
            out.append(f"| {t} | " + " | ".join(cells) + f" | **{low:.2f}** |")
        on = ratio(resolve(COLORS["onBrand"][i]), resolve(COLORS["brand"][i]))
        if on < 4.5:
            failures.append(f"{mode} onBrand on brand: {on:.2f}")
        out += ["", f"onBrand on brand: **{on:.2f}**", "",
                f"## UI marks, {mode} (3:1 minimum)", "",
                "| Token | " + " | ".join(UI_BACKGROUNDS) + " | Lowest |",
                "|---|" + "---:|" * (len(UI_BACKGROUNDS) + 1)]
        for t in UI_TOKENS:
            cells, low = [], 99.0
            for bgn in UI_BACKGROUNDS:
                bg = resolve(COLORS[bgn][i])
                r = ratio(resolve(COLORS[t][i], bg), bg)
                low = min(low, r)
                cells.append(f"{r:.2f}")
                if r < 3.0:
                    failures.append(f"{mode} {t} on {bgn}: {r:.2f}")
            out.append(f"| {t} | " + " | ".join(cells) + f" | **{low:.2f}** |")
        out.append("")
    # Component pairs: text on the selected-chip wash (brand at 18% dark,
    # 24% light, as DS.selectedTint) and on the segment thumb.
    out += ["## Component pairs", "", "| Pair | Dark | Light |", "|---|---:|---:|"]
    for label, fg, wash_on in [("textPrimary on selected-chip wash over surfaceTop", "textPrimary", "surfaceTop"),
                               ("textPrimary on selected-chip wash over bg0", "textPrimary", "bg0"),
                               ("textPrimary on segmentThumb", "textPrimary", None),
                               ("textSecondary on tileTop (unselected chip)", "textSecondary", "tile")]:
        cells = []
        for i, alpha in ((0, 0.18), (1, 0.24)):
            if wash_on == "tile":
                bg = resolve(COLORS["tileTop"][i])
            elif wash_on:
                bg = resolve((hex_rgb(COLORS["brand"][i]), alpha), resolve(COLORS[wash_on][i]))  # type: ignore[arg-type]
            else:
                bg = resolve(COLORS["segmentThumb"][i])
            r = ratio(resolve(COLORS[fg][i], bg), bg)
            if r < 4.5:
                failures.append(f"{label} ({'dark' if i == 0 else 'light'}): {r:.2f}")
            cells.append(f"{r:.2f}")
        out.append(f"| {label} | " + " | ".join(cells) + " |")
    out.append("")
    # Brand fill as a surface marker is decorative by rule; record it so the
    # rule's reason is visible.
    out += ["## Recorded, not recommended as an indicator", "",
            "| Pair | Dark | Light | Why it is allowed |", "|---|---:|---:|---|"]
    for bgn in ("surfaceTop", "bg0"):
        d = ratio(resolve(COLORS["brand"][0]), resolve(COLORS[bgn][0]))
        lt = ratio(resolve(COLORS["brand"][1]), resolve(COLORS[bgn][1]))
        out.append(f"| brand fill on {bgn} | {d:.2f} | {lt:.2f} | Only used for a labelled button, whose label (onBrand, above) identifies it. Never the only sign of a state. |")
    out.append("")
    if failures:
        sys.exit("Contrast failures:\n  " + "\n  ".join(failures))
    return "\n".join(out)


# --------------------------------------------------------------------------
# Token writers
# --------------------------------------------------------------------------


def write_tokens_json() -> None:
    color = {}
    for name, (dark, light, role) in COLORS.items():
        color[name] = {"$type": "color", "$description": role,
                       "$value": {"light": css_value(light), "dark": css_value(dark)}}
    typography = {}
    for name, size, line, weight, track, asize, aline, use in TYPE:
        typography[name] = {"$type": "typography", "$description": use, "$value": {
            "latin": {"fontFamily": "system-ui (SF Pro / Roboto)", "fontSize": size, "lineHeight": line,
                      "fontWeight": weight, "letterSpacing": track, "fontFeatures": ["tnum"]},
            "arabic": {"fontFamily": "Almarai", "fontSize": asize, "lineHeight": aline,
                       "fontWeight": 800 if weight >= 700 else (700 if weight == 600 else 400),
                       "letterSpacing": 0, "fontFeatures": ["tnum"]}}}
    data = {
        "$schema": "https://design-tokens.github.io/community-group/format/",
        "$description": "Qima design tokens. Generated by brand/tool/build_brand.py; edit the script, not this file.",
        "color": color,
        "typography": typography,
        "fontFamily": {
            "appLatin": {"$value": "system-ui", "$description": "Platform font in the app: SF Pro on Apple, Roboto on Android"},
            "appArabic": {"$value": "Almarai", "$description": "Arabic in the app, bundled (SIL OFL 1.1)"},
            "marketing": {"$value": "Almarai", "$description": "Store art, website, social, email; both scripts"},
            "wordmark": {"$value": "Almarai Bold 700, letter-spacing -0.01em, outlined"},
        },
        "space": {k: {"$type": "dimension", "$value": f"{v}px"} for k, v in SPACE.items()},
        "radius": {k: {"$type": "dimension", "$value": f"{v}px"} for k, v in RADIUS.items()},
        "elevation": ELEVATION,
        "motion": {
            "duration": {k: {"$type": "duration", "$value": f"{v}ms"} for k, v in MOTION["duration"].items()},
            "easing": {k: {"$type": "cubicBezier", "$value": v} for k, v in MOTION["easing"].items()},
            "reducedMotion": {"$description": "When the OS asks for reduced motion, movement becomes instant; opacity and colour changes keep the quick duration."},
        },
        "size": {k: {"$type": "dimension", "$value": f"{v}px"} for k, v in SIZE.items()},
    }
    (BRAND / "tokens.json").write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n")


def kebab(name: str) -> str:
    return "".join("-" + c.lower() if c.isupper() else c for c in name)


def write_tokens_css() -> None:
    def block(i: int) -> list[str]:
        return [f"  --qima-{kebab(n)}: {css_value(v[i])};" for n, v in COLORS.items()]

    lines = ["/* Qima design tokens. Generated by brand/tool/build_brand.py; do not edit. */", "",
             "/* Dark is the default (the website and store art are dark-first). */",
             ":root {", *block(0)]
    for k, v in SPACE.items():
        lines.append(f"  --qima-space-{k}: {v}px;")
    for k, v in RADIUS.items():
        lines.append(f"  --qima-radius-{k}: {v}px;")
    for k, v in MOTION["duration"].items():
        lines.append(f"  --qima-duration-{k}: {v}ms;")
    for k, v in MOTION["easing"].items():
        lines.append(f"  --qima-ease-{k}: cubic-bezier({', '.join(f'{x:g}' for x in v)});")
    lines.append('  --qima-font-latin: system-ui, -apple-system, "Segoe UI", Roboto, sans-serif;')
    lines.append('  --qima-font-arabic: "Almarai", system-ui, sans-serif;')
    lines.append('  --qima-font-marketing: "Almarai", system-ui, sans-serif;')
    for name, size, line, weight, track, *_ in TYPE:
        lines.append(f"  --qima-type-{kebab(name)}: {weight} {size}px/{line}px var(--qima-font-latin);")
        if track:
            lines.append(f"  --qima-tracking-{kebab(name)}: {track}px;")
    lines += ["}", "", "@media (prefers-color-scheme: light) {", "  :root:not([data-theme=\"dark\"]) {",
              *["  " + x for x in block(1)], "  }", "}", "", ":root[data-theme=\"light\"] {", *block(1), "}", "",
              ":lang(ar) {"]
    for name, _s, _l, weight, _t, asize, aline, _u in TYPE:
        aw = 800 if weight >= 700 else (700 if weight == 600 else 400)
        lines.append(f"  --qima-type-{kebab(name)}: {aw} {asize:g}px/{aline}px var(--qima-font-arabic);")
    lines += ["}", "", "@media (prefers-reduced-motion: reduce) {", "  :root {",
              "    --qima-duration-standard: 0ms;", "    --qima-duration-emphasized: 0ms;", "  }", "}", ""]
    (BRAND / "tokens.css").write_text("\n".join(lines))


def write_tokens_dart() -> None:
    fields = list(COLORS)
    out = [
        "// Qima design tokens. Generated by brand/tool/build_brand.py; do not edit.",
        "//",
        "// A reference copy of the brand tokens in the app's own format. The app's",
        "// source of truth stays lib/theme/qima_colors.dart and design_system.dart;",
        "// brand/changes.md lists which values to copy across.",
        "",
        "import 'package:flutter/widgets.dart';",
        "",
        "/// One palette per brightness; field names match `QimaColors`, plus the",
        "/// new brandIndicator, success, warning, error and info roles.",
        "class QimaPalette {",
        *[f"  final Color {f};" for f in fields],
        "",
        "  const QimaPalette({",
        *[f"    required this.{f}," for f in fields],
        "  });",
        "",
    ]
    for mode in ("dark", "light"):
        i = mode_index(mode)
        out.append(f"  static const QimaPalette {mode} = QimaPalette(")
        out += [f"    {n}: {dart_value(v[i])}," for n, v in COLORS.items()]
        out += ["  );", ""]
    out += ["}", "",
            "/// One step of the type scale. [style] is for Latin (the platform font);",
            "/// [arabic] uses Almarai with the larger Arabic size and line height.",
            "class QimaTextStep {",
            "  final TextStyle style;",
            "  final TextStyle arabic;",
            "",
            "  const QimaTextStep(this.style, this.arabic);",
            "",
            "  TextStyle of(BuildContext context) =>",
            "      Localizations.maybeLocaleOf(context)?.languageCode == 'ar' ? arabic : style;",
            "}",
            "",
            "const List<FontFeature> _tnum = [FontFeature.tabularFigures()];",
            "",
            "class QimaType {",
            "  QimaType._();", ""]
    for name, size, line, weight, track, asize, aline, use in TYPE:
        aw = 800 if weight >= 700 else (700 if weight == 600 else 400)
        out += [f"  /// {use}.",
                f"  static const {name} = QimaTextStep(",
                f"    TextStyle(fontSize: {size}, height: {line / size:.4f}, fontWeight: FontWeight.w{weight}, letterSpacing: {track:g}, fontFeatures: _tnum),",
                f"    TextStyle(fontFamily: 'Almarai', fontSize: {asize:g}, height: {aline / asize:.4f}, fontWeight: FontWeight.w{aw}, letterSpacing: 0, fontFeatures: _tnum),",
                "  );", ""]
    out += ["}", "", "class QimaSpace {", "  QimaSpace._();", ""]
    names = {"3xs": "x3s", "2xs": "x2s"}
    for k, v in SPACE.items():
        out.append(f"  static const double {names.get(k, k)} = {v};")
    out += ["}", "", "class QimaRadius {", "  QimaRadius._();", ""]
    for k, v in RADIUS.items():
        out.append(f"  static const double {k} = {v};")
    out += ["}", "", "class QimaMotion {", "  QimaMotion._();", ""]
    for k, v in MOTION["duration"].items():
        out.append(f"  static const Duration {k} = Duration(milliseconds: {v});")
    for k, v in MOTION["easing"].items():
        out.append(f"  static const Curve {k}Curve = Cubic({', '.join(f'{x:g}' for x in v)});")
    out += ["",
            "  /// [duration] for movement (slides, scrolls, page turns), or zero when",
            "  /// the OS asks for reduced motion. Fades and colour changes don't need it.",
            "  static Duration movement(BuildContext context, Duration duration) =>",
            "      MediaQuery.maybeDisableAnimationsOf(context) ?? false ? Duration.zero : duration;",
            "}", ""]
    (BRAND / "flutter").mkdir(exist_ok=True)
    (BRAND / "flutter/qima_tokens.dart").write_text("\n".join(out))


# --------------------------------------------------------------------------
# Wordmark and icon geometry
# --------------------------------------------------------------------------

TRACKING = -10  # font units (upm 1000) = -0.01em


class Wordmark:
    """Outlined glyph runs from Almarai Bold, in font units, y down."""

    def __init__(self) -> None:
        self.font = TTFont(FONT)
        self.glyphs = self.font.getGlyphSet()
        self.cmap = self.font.getBestCmap()
        self.cap = self.font["OS/2"].sCapHeight

    def _run(self, names: list[str], rtl: bool) -> tuple[str, tuple[float, float, float, float]]:
        widths = [self.glyphs[n].width for n in names]
        total = sum(widths) + TRACKING * (len(names) - 1)
        pen = SVGPathPen(self.glyphs)
        bounds = BoundsPen(self.glyphs)
        x = total if rtl else 0
        for n, w in zip(names, widths):
            if rtl:
                x -= w
            for p in (pen, bounds):
                self.glyphs[n].draw(TransformPen(p, (1, 0, 0, -1, x, 0)))
            x += (-TRACKING if rtl else w + TRACKING)
        return pen.getCommands(), bounds.bounds

    def latin(self) -> tuple[str, tuple[float, float, float, float]]:
        return self._run([self.cmap[ord(c)] for c in "Qima"], rtl=False)

    def arabic(self) -> tuple[str, tuple[float, float, float, float]]:
        # قيمة shaped by hand from presentation forms: initial qaf, medial
        # yeh, medial meem, final teh marbuta. No tracking in Arabic.
        names = [self.cmap[cp] for cp in (0xFED7, 0xFEF4, 0xFEE4, 0xFE94)]
        widths = [self.glyphs[n].width for n in names]
        pen, bounds = SVGPathPen(self.glyphs), BoundsPen(self.glyphs)
        x = sum(widths)
        for n, w in zip(names, widths):
            x -= w
            for p in (pen, bounds):
                self.glyphs[n].draw(TransformPen(p, (1, 0, 0, -1, x, 0)))
        return pen.getCommands(), bounds.bounds


# Icon proposal (not adopted, owner answer 22): the shipped rising line,
# refined. Same five-point line and dark nodes; the arrowhead is replaced
# by a level final segment ending in a larger node, so the mark reads
# "value tracked" rather than "always up". The lockup uses the shipped icon.
LINE = [(168, 652), (352, 508), (504, 576), (672, 368), (856, 368)]
GOLD = "#E6BA4D"
NIGHT = "#08090C"


SHIPPED_ICON = ROOT / "assets" / "icon" / "app_icon.png"


def shipped_icon_data_uri(size: int) -> str:
    """The app icon as it ships, downscaled and inlined as a PNG data URI."""
    buf = io.BytesIO()
    Image.open(SHIPPED_ICON).convert("RGB").resize((size, size), Image.LANCZOS).save(buf, "PNG", optimize=True)
    return "data:image/png;base64," + base64.b64encode(buf.getvalue()).decode("ascii")


def icon_glyph(color: str = GOLD, hole: str | None = NIGHT, small: bool = False) -> str:
    pts = " ".join(f"{x},{y}" for x, y in LINE)
    sw = 92 if small else 68
    end_r = 76 if small else 58
    parts = [f'<polyline points="{pts}" fill="none" stroke="{color}" stroke-width="{sw}" '
             f'stroke-linecap="round" stroke-linejoin="round"/>',
             f'<circle cx="{LINE[-1][0]}" cy="{LINE[-1][1]}" r="{end_r}" fill="{color}"/>']
    if hole:
        if not small:
            parts += [f'<circle cx="{x}" cy="{y}" r="22" fill="{hole}"/>' for x, y in LINE[:-1]]
        parts.append(f'<circle cx="{LINE[-1][0]}" cy="{LINE[-1][1]}" r="{34 if small else 26}" fill="{hole}"/>')
    return "".join(parts)


def icon_background(light: bool = False, glow: bool = True) -> str:
    top, bottom, glow_color, glow_a = ("#FFFFFF", "#ECEEF2", "#D4A72C", 0.22) if light else ("#171A21", NIGHT, GOLD, 0.30)
    g = (f'<radialGradient id="glow" cx="600" cy="470" r="560" gradientUnits="userSpaceOnUse">'
         f'<stop offset="0" stop-color="{glow_color}" stop-opacity="{glow_a}"/>'
         f'<stop offset="0.55" stop-color="{glow_color}" stop-opacity="{glow_a / 4:.3f}"/>'
         f'<stop offset="1" stop-color="{glow_color}" stop-opacity="0"/></radialGradient>')
    return (f'<defs><linearGradient id="bg" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="{top}"/>'
            f'<stop offset="1" stop-color="{bottom}"/></linearGradient>{g if glow else ""}</defs>'
            f'<rect width="1024" height="1024" fill="url(#bg)"/>'
            + ('<rect width="1024" height="1024" fill="url(#glow)"/>' if glow else ""))


def svg(view: tuple[float, float, float, float], body: str, w: float | None = None, h: float | None = None,
        title: str = "Qima") -> str:
    x, y, vw, vh = view
    size = f' width="{w:g}" height="{h:g}"' if w else ""
    return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="{x:g} {y:g} {vw:g} {vh:g}"{size} role="img">'
            f'<title>{title}</title>{body}</svg>\n')


def build_svgs() -> dict[str, tuple[str, int, int]]:
    """Returns {relative path: (svg text, natural width, natural height)}."""
    wm = Wordmark()
    files: dict[str, tuple[str, int, int]] = {}

    # Icons -----------------------------------------------------------------
    full = svg((0, 0, 1024, 1024), icon_background() + icon_glyph(), 1024, 1024)
    files["icon/qima-app-icon.svg"] = (full, 1024, 1024)
    files["icon/qima-app-icon-small.svg"] = (svg((0, 0, 1024, 1024), icon_background(glow=False) + icon_glyph(small=True), 1024, 1024), 1024, 1024)
    files["icon/qima-mark-on-light.svg"] = (svg((0, 0, 1024, 1024), icon_background(light=True) + icon_glyph(color="#8A6410", hole="#FFFFFF"), 1024, 1024), 1024, 1024)
    # iOS 18 dark appearance: artwork on transparent; tinted: greyscale artwork.
    files["icon/ios-dark-1024.svg"] = (svg((0, 0, 1024, 1024), icon_glyph(hole=None) + "".join(
        f'<circle cx="{x}" cy="{y}" r="22" fill="{NIGHT}"/>' for x, y in LINE[:-1]) +
        f'<circle cx="{LINE[-1][0]}" cy="{LINE[-1][1]}" r="26" fill="{NIGHT}"/>', 1024, 1024), 1024, 1024)
    files["icon/ios-tinted-1024.svg"] = (svg((0, 0, 1024, 1024), f'<rect width="1024" height="1024" fill="#000"/>' + icon_glyph(color="#FFFFFF", hole="#000000"), 1024, 1024), 1024, 1024)
    # Android adaptive: 108dp canvas, content inside the 66dp safe circle.
    # The 1024 artwork's content box (~110..914) is scaled into 432px with the
    # line kept inside a 264px circle.
    s = 264 / 820
    t = (432 - 1024 * s) / 2
    files["icon/android-adaptive-foreground.svg"] = (svg((0, 0, 432, 432), f'<g transform="translate({t:.2f} {t:.2f}) scale({s:.5f})">{icon_glyph()}</g>', 432, 432), 432, 432)
    files["icon/android-adaptive-monochrome.svg"] = (svg((0, 0, 432, 432), f'<g transform="translate({t:.2f} {t:.2f}) scale({s:.5f})">{icon_glyph(color="#FFFFFF", hole=None)}</g>', 432, 432), 432, 432)

    # Wordmarks -------------------------------------------------------------
    def word(path: str, bounds: tuple[float, float, float, float], color: str,
             title: str = "Qima") -> tuple[str, int, int]:
        x0, y0, x1, y1 = bounds
        pad = 12
        vw, vh = x1 - x0 + 2 * pad, y1 - y0 + 2 * pad
        return (svg((x0 - pad, y0 - pad, vw, vh), f'<path fill="{color}" d="{path}"/>', round(vw / 4), round(vh / 4),
                    title=title), round(vw), round(vh))

    latin_path, latin_b = wm.latin()
    ar_path, ar_b = wm.arabic()
    for slug, color in [("on-light", "#111318"), ("on-dark", "#FFFFFF"), ("black", "#000000"), ("white", "#FFFFFF"),
                        ("gold-on-dark", GOLD), ("gold-on-light", "#8A6410")]:
        files[f"logo/qima-wordmark-{slug}.svg"] = word(latin_path, latin_b, color)
    for slug, color in [("on-light", "#111318"), ("on-dark", "#FFFFFF")]:
        files[f"logo/qima-wordmark-ar-{slug}.svg"] = word(ar_path, ar_b, color, title="قيمة")

    # Horizontal lockup: rounded-square icon + wordmark. Icon height is
    # 1.4x the cap height; gap is 0.4x; the wordmark's cap is centred on it.
    cap = wm.cap
    icon_h = 1.4 * cap
    gap = 0.4 * cap
    x0, y0, x1, y1 = latin_b
    scale = icon_h / 1024
    radius = 0.2237 * 1024  # Apple's squircle approximated by a rounded rect
    # The lockup uses the shipped app icon (owner answer 22: the refined
    # artwork was not adopted), embedded as a 512 px PNG so the SVG stays
    # self-contained. On dark it gets a hairline so its edge reads.
    shipped = shipped_icon_data_uri(512)
    for slug, text_color, edge in [("on-light", "#111318", None), ("on-dark", "#FFFFFF", "rgba(255,255,255,0.14)")]:
        border = (f'<rect x="8" y="8" width="1008" height="1008" rx="{radius - 8:.0f}" fill="none" '
                  f'stroke="{edge}" stroke-width="16"/>' if edge else "")
        icon = (f'<clipPath id="r"><rect width="1024" height="1024" rx="{radius:.0f}"/></clipPath>'
                f'<g transform="translate(0 {-cap / 2 - icon_h / 2:.1f}) scale({scale:.5f})"><g clip-path="url(#r)">'
                f'<image href="{shipped}" width="1024" height="1024"/></g>{border}</g>')
        text = f'<g transform="translate({icon_h + gap - x0:.1f} 0)"><path fill="{text_color}" d="{latin_path}"/></g>'
        top = min(-cap / 2 - icon_h / 2, y0)
        bottom = max(-cap / 2 + icon_h / 2, y1)
        width = icon_h + gap + (x1 - x0)
        pad = 12
        view = (-pad, top - pad, width + 2 * pad, bottom - top + 2 * pad)
        files[f"logo/qima-lockup-{slug}.svg"] = (svg(view, icon + text, round(view[2] / 4), round(view[3] / 4)), round(view[2]), round(view[3]))
    return files


# --------------------------------------------------------------------------
# Rendering
# --------------------------------------------------------------------------

# (svg path, png path, width, height, opaque)
def png_jobs(files: dict[str, tuple[str, int, int]]) -> list[tuple[str, str, int, int, bool]]:
    jobs = []
    for size in (1024, 512, 180, 167, 152, 120, 96, 64):
        jobs.append(("icon/qima-app-icon.svg", f"icon/png/qima-app-icon-{size}.png", size, size, True))
    for size in (48, 32, 16):
        jobs.append(("icon/qima-app-icon-small.svg", f"icon/png/qima-app-icon-{size}.png", size, size, True))
    jobs += [("icon/qima-mark-on-light.svg", "icon/png/qima-mark-on-light-512.png", 512, 512, True),
             ("icon/ios-dark-1024.svg", "icon/png/ios-dark-1024.png", 1024, 1024, False),
             ("icon/ios-tinted-1024.svg", "icon/png/ios-tinted-1024.png", 1024, 1024, True),
             ("icon/android-adaptive-foreground.svg", "icon/png/android-adaptive-foreground-432.png", 432, 432, False),
             ("icon/android-adaptive-monochrome.svg", "icon/png/android-adaptive-monochrome-432.png", 432, 432, False)]
    for rel, (_t, w, h) in files.items():
        if rel.startswith("logo/"):
            for target_w in (256, 512, 1024):
                th = round(h * target_w / w)
                name = Path(rel).stem
                jobs.append((rel, f"logo/png/{name}-{target_w}w.png", target_w, th, False))
    return jobs


def render(job: tuple[str, str, int, int, bool], tmp: Path) -> None:
    """Rasterises one SVG with headless Chrome. Small targets are drawn at
    least 512 px wide and downsampled, which is sharper and avoids Chrome
    hanging on tiny windows; a hung run is retried."""
    src, dst, w, h, opaque = job
    k = max(1, -(-512 // w))
    rw, rh = w * k, h * k
    page = tmp / (Path(dst).stem + ".html")
    page.write_text(f'<!doctype html><html><body style="margin:0;background:transparent">'
                    f'<img src="file://{ASSETS / src}" style="display:block;width:{rw}px;height:{rh}px"></body></html>')
    out = ASSETS / dst
    out.parent.mkdir(parents=True, exist_ok=True)
    for attempt in range(3):
        profile = tmp / f"profile-{Path(dst).stem}-{attempt}"
        try:
            subprocess.run([CHROME, "--headless=new", "--disable-gpu", "--hide-scrollbars", "--no-first-run",
                            f"--user-data-dir={profile}", "--force-device-scale-factor=1",
                            "--default-background-color=00000000", f"--screenshot={out}",
                            f"--window-size={rw},{rh}", f"file://{page}"],
                           stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, timeout=30, check=False)
        except subprocess.TimeoutExpired:
            pass
        if out.exists():
            break
    img = Image.open(out).convert("RGBA")
    if k > 1:
        img = img.resize((w, h), Image.LANCZOS)
    img = img.convert("RGB") if opaque else img
    img.save(out, optimize=True)


def main() -> None:
    contrast = check_contrast()
    (BRAND / "contrast.md").write_text(contrast)
    write_tokens_json()
    write_tokens_css()
    write_tokens_dart()

    if ASSETS.exists():
        shutil.rmtree(ASSETS)
    files = build_svgs()
    for rel, (text, _w, _h) in files.items():
        p = ASSETS / rel
        p.parent.mkdir(parents=True, exist_ok=True)
        p.write_text(text)
    jobs = png_jobs(files)
    # Chrome can still be writing its profile files as it exits, so a
    # failed cleanup of the scratch directory is not an error.
    with tempfile.TemporaryDirectory(ignore_cleanup_errors=True) as d, ThreadPoolExecutor(max_workers=6) as pool:
        list(pool.map(lambda j: render(j, Path(d)), jobs))
    missing = [j[1] for j in jobs if not (ASSETS / j[1]).exists()]
    if missing:
        sys.exit("Not rendered: " + ", ".join(missing))
    print(f"{len(files)} SVGs, {len(jobs)} PNGs, tokens and contrast.md written")


if __name__ == "__main__":
    main()
