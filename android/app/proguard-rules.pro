# DermIQ R8/ProGuard keep rules for release builds.

# ── Flutter ──────────────────────────────────────────────────────────────────
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.embedding.** { *; }

# ── Google ML Kit (text recognition / barcode) ───────────────────────────────
# ML Kit loads models via reflection; keep its classes and ignore optional deps.
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.internal.mlkit_** { *; }
-dontwarn com.google.mlkit.**

# Optional ML Kit language models referenced but not bundled.
-dontwarn com.google.android.gms.internal.mlkit_vision_text_common.**

# ── Firebase ─────────────────────────────────────────────────────────────────
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# ── mobile_scanner ───────────────────────────────────────────────────────────
-keep class com.google.zxing.** { *; }
-dontwarn com.google.zxing.**

# ── Play Core (deferred components / split installs used by Flutter) ──────────
-dontwarn com.google.android.play.core.**

# Keep annotations / generic signatures used for reflection.
-keepattributes *Annotation*, Signature, InnerClasses, EnclosingMethod
