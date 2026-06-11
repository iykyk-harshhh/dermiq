import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

/// The DermIQ brand logo — "dermiq" in Playfair Display
/// with the ✦ star floating above the "i".
///
/// Renders as: derm✦q (star positioned above the i's dot)
class DiqLogo extends StatelessWidget {
  final DiqLogoSize size;
  final bool onDark;
  final Color? overrideColor;

  const DiqLogo({
    super.key,
    this.size = DiqLogoSize.medium,
    this.onDark = false,
    this.overrideColor,
  });

  double get _fontSize => switch (size) {
        DiqLogoSize.small  => 20,
        DiqLogoSize.medium => 28,
        DiqLogoSize.large  => 36,
      };

  double get _starSize => switch (size) {
        DiqLogoSize.small  => 7,
        DiqLogoSize.medium => 9,
        DiqLogoSize.large  => 11,
      };

  double get _starOffset => switch (size) {
        DiqLogoSize.small  => -7,
        DiqLogoSize.medium => -9,
        DiqLogoSize.large  => -11,
      };

  Color get _color {
    if (overrideColor != null) return overrideColor!;
    return onDark ? Colors.white : AppColors.primary;
  }

  Color get _starColor {
    if (overrideColor != null) return overrideColor!;
    return onDark ? AppColors.lavender : AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.playfairDisplay(
      fontSize: _fontSize,
      fontWeight: FontWeight.w700,
      color: _color,
      letterSpacing: 1.5,
    );

    // Split "dermiq" around the "i": "derm" + "i" + "q"
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text('derm', style: style),

        // "i" with ✦ star above it
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Text('i', style: style),
            Positioned(
              top: _starOffset,
              child: Text(
                '✦',
                style: GoogleFonts.playfairDisplay(
                  fontSize: _starSize,
                  fontWeight: FontWeight.w700,
                  color: _starColor,
                  height: 1.0,
                ),
              ),
            ),
          ],
        ),

        Text('q', style: style),
      ],
    );
  }
}

/// Animated version — star pulses gently.
class DiqLogoAnimated extends StatefulWidget {
  final DiqLogoSize size;
  final bool onDark;

  const DiqLogoAnimated({
    super.key,
    this.size = DiqLogoSize.large,
    this.onDark = false,
  });

  @override
  State<DiqLogoAnimated> createState() => _DiqLogoAnimatedState();
}

class _DiqLogoAnimatedState extends State<DiqLogoAnimated>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.9, end: 1.15).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // We can't easily animate just the star inside DiqLogo,
    // so we rebuild with an animated star overlay manually.
    final fontSize = switch (widget.size) {
      DiqLogoSize.small  => 20.0,
      DiqLogoSize.medium => 28.0,
      DiqLogoSize.large  => 36.0,
    };
    final starSize = switch (widget.size) {
      DiqLogoSize.small  => 7.0,
      DiqLogoSize.medium => 9.0,
      DiqLogoSize.large  => 11.0,
    };
    final starOffset = switch (widget.size) {
      DiqLogoSize.small  => -7.0,
      DiqLogoSize.medium => -9.0,
      DiqLogoSize.large  => -11.0,
    };

    final color      = widget.onDark ? Colors.white     : AppColors.primary;
    final starColor  = widget.onDark ? AppColors.lavender : AppColors.primary;

    final textStyle = GoogleFonts.playfairDisplay(
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      color: color,
      letterSpacing: 1.5,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text('derm', style: textStyle),
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Text('i', style: textStyle),
            Positioned(
              top: starOffset,
              child: AnimatedBuilder(
                animation: _scale,
                builder: (_, _) => Transform.scale(
                  scale: _scale.value,
                  child: Text(
                    '✦',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: starSize,
                      fontWeight: FontWeight.w700,
                      color: starColor,
                      height: 1.0,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        Text('q', style: textStyle),
      ],
    );
  }
}

enum DiqLogoSize { small, medium, large }
