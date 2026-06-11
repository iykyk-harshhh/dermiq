import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// "Get Started" pill — gradient fill, white 20% border, pulsing purple outer
/// glow, and a continuous breathing scale (1.0 → 1.03 → 1.0) on a 2.5s loop.
class GlowingButton extends StatefulWidget {
  final VoidCallback onTap;
  const GlowingButton({super.key, required this.onTap});

  @override
  State<GlowingButton> createState() => _GlowingButtonState();
}

class _GlowingButtonState extends State<GlowingButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        final v = Curves.easeInOut.transform(_ctrl.value); // 0..1
        final scale = 1.0 + 0.03 * v;
        final glow = 16.0 + 14.0 * v;
        return Transform.scale(
          scale: scale,
          child: Semantics(
            button: true,
            label: 'Get Started',
            child: GestureDetector(
              onTap: widget.onTap,
              child: Container(
                width: double.infinity,
                height: 72,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  gradient: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Color(0xFF6C4BFF), Color(0xFFB084FF)],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.20),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6C4BFF)
                          .withValues(alpha: 0.35 + 0.15 * v),
                      blurRadius: glow,
                      spreadRadius: 1,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: child,
              ),
            ),
          ),
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Get Started',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 22),
        ],
      ),
    );
  }
}
