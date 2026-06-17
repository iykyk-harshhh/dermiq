"""Turn assets/images/logo_source.png into the app icon assets, using the logo
AS-IS (no trimming/re-centering — original framing preserved).

- app_icon.png            logo_source composited on lavender (#F4F0FF) — iOS strips alpha.
- app_icon_foreground.png logo_source as-is, transparent — Android adaptive foreground.
- splash_logo.png         logo_source as-is, transparent — native splash.
"""
from PIL import Image

SRC = "assets/images/logo_source.png"
ICON_BG = (244, 240, 255, 255)  # #F4F0FF

src = Image.open(SRC).convert("RGBA")

# iOS / legacy: flatten onto lavender so transparency doesn't become black.
flat = Image.new("RGBA", src.size, ICON_BG)
flat.alpha_composite(src)
flat.save("assets/images/app_icon.png")

# Adaptive foreground + splash: the original, untouched.
src.save("assets/images/app_icon_foreground.png")
src.save("assets/images/splash_logo.png")

print("done: used logo_source.png as-is")
