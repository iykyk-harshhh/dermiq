"""Generate DermIQ store assets (app icon, adaptive foreground, splash logo).

Run:  python tool/gen_brand_assets.py
Then: dart run flutter_launcher_icons && dart run flutter_native_splash:create

Pure-PIL, no external binaries. Replace the generated PNGs with final brand
artwork whenever it's ready — the pubspec paths stay the same.
"""
import math
import os
from PIL import Image, ImageDraw, ImageFont

OUT = os.path.join(os.path.dirname(__file__), "..", "assets", "images")
os.makedirs(OUT, exist_ok=True)

# Brand palette (matches splash + theme)
TOP = (138, 109, 255)      # #8A6DFF
BOTTOM = (176, 132, 255)   # #B084FF
DEEP = (47, 33, 111)       # #2F216F ink
LILAC = (233, 222, 255)    # #E9DEFF


def _lerp(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))


def vertical_gradient(size, top, bottom):
    img = Image.new("RGB", (size, size), top)
    px = img.load()
    for y in range(size):
        c = _lerp(top, bottom, y / (size - 1))
        for x in range(size):
            px[x, y] = c
    return img


def load_font(size):
    # Try a few common bold fonts; fall back to PIL default.
    for name in ("seguibold.ttf", "arialbd.ttf", "Arialbd.ttf", "DejaVuSans-Bold.ttf"):
        try:
            return ImageFont.truetype(name, size)
        except OSError:
            continue
    return ImageFont.load_default()


def draw_centered(draw, text, font, size, fill, dy=0):
    bbox = draw.textbbox((0, 0), text, font=font)
    w = bbox[2] - bbox[0]
    h = bbox[3] - bbox[1]
    x = (size - w) / 2 - bbox[0]
    y = (size - h) / 2 - bbox[1] + dy
    draw.text((x, y), text, font=font, fill=fill)


def rounded_icon():
    """1024 full-bleed app icon: gradient bg + soft glow ring + 'd'."""
    S = 1024
    img = vertical_gradient(S, TOP, BOTTOM)
    draw = ImageDraw.Draw(img, "RGBA")
    # subtle radial highlight top-left
    glow = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    gd = ImageDraw.Draw(glow)
    for r in range(420, 0, -8):
        a = int(40 * (1 - r / 420))
        gd.ellipse([300 - r, 220 - r, 300 + r, 220 + r], fill=(255, 255, 255, a))
    img = Image.alpha_composite(img.convert("RGBA"), glow)
    draw = ImageDraw.Draw(img, "RGBA")
    # thin ring
    draw.ellipse([110, 110, S - 110, S - 110], outline=(255, 255, 255, 60), width=10)
    # letter
    font = load_font(620)
    draw_centered(draw, "d", font, S, (255, 255, 255, 255), dy=-10)
    # round the corners (mask) for non-adaptive contexts
    mask = Image.new("L", (S, S), 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, S, S], radius=220, fill=255)
    out = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    out.paste(img, (0, 0), mask)
    out.convert("RGB").save(os.path.join(OUT, "app_icon.png"))


def adaptive_foreground():
    """Transparent foreground for adaptive icon — glyph centered in safe zone."""
    S = 1024
    img = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    font = load_font(440)  # ~43% keeps it inside the adaptive safe area
    draw_centered(draw, "d", font, S, (255, 255, 255, 255), dy=-10)
    img.save(os.path.join(OUT, "app_icon_foreground.png"))


def splash_logo():
    """Transparent wordmark on the light splash bg (#F8F6FF)."""
    W, H = 900, 320
    img = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    font = load_font(180)
    text = "dermiq"
    bbox = draw.textbbox((0, 0), text, font=font)
    w = bbox[2] - bbox[0]
    h = bbox[3] - bbox[1]
    x = (W - w) / 2 - bbox[0]
    y = (H - h) / 2 - bbox[1]
    draw.text((x, y), text, font=font, fill=DEEP)
    img.save(os.path.join(OUT, "splash_logo.png"))


if __name__ == "__main__":
    rounded_icon()
    adaptive_foreground()
    splash_logo()
    print("Wrote app_icon.png, app_icon_foreground.png, splash_logo.png to", os.path.abspath(OUT))
