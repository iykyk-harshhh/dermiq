import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/diq_logo.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  SHARED QUIZ SCAFFOLD  — used by all 10 profile quiz screens
// ─────────────────────────────────────────────────────────────────────────────

class QuizScaffold extends StatelessWidget {
  final int step;
  final int totalSteps;
  final String category;
  final String title;
  final String subtitle;
  final Widget child;
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final String nextLabel;

  const QuizScaffold({
    super.key,
    required this.step,
    required this.totalSteps,
    required this.category,
    required this.title,
    required this.subtitle,
    required this.child,
    this.onBack,
    this.onNext,
    this.nextLabel = 'Continue',
  });

  @override
  Widget build(BuildContext context) {
    final progress = step / totalSteps;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF2EDFF),
              Color(0xFFE8DEFF),
              Color(0xFFD8C8FF),
              Color(0xFFCCB8F5),
            ],
            stops: [0.0, 0.3, 0.65, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Top bar ──────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: onBack,
                      child: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.72),
                          shape: BoxShape.circle,
                          boxShadow: AppColors.cardShadow,
                        ),
                        child: const Icon(Icons.arrow_back_rounded,
                            size: 20, color: Color(0xFF1E1B4B)),
                      ),
                    ),
                    const DiqLogo(size: DiqLogoSize.small),
                    Text('$step / $totalSteps',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                        )),
                  ],
                ),
              ),

              // ── Progress bar ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 4,
                    backgroundColor: const Color(0xFF7C5CFF).withValues(alpha: 0.15),
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF7C5CFF)),
                  ),
                ),
              ),

              // ── Category badge ───────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C5CFF).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      category.toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF7C5CFF),
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              ),

              // ── Title ────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 10, 24, 6),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(title, style: AppTypography.h1.copyWith(
                    color: const Color(0xFF1E1B4B), height: 1.15,
                  )),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(subtitle, style: AppTypography.bodyMedium.copyWith(
                    color: const Color(0xFF6B7280), height: 1.5,
                  )),
                ),
              ),

              // ── Scrollable options ───────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                  child: child,
                ),
              ),

              // ── Next button ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: AppButton(
                  label: nextLabel,
                  onPressed: onNext,
                  icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
