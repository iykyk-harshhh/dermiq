import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/dermiq_colors.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../profile_quiz/providers/quiz_provider.dart';

class EditSkinProfileScreen extends ConsumerStatefulWidget {
  const EditSkinProfileScreen({super.key});

  @override
  ConsumerState<EditSkinProfileScreen> createState() => _EditSkinProfileScreenState();
}

class _EditSkinProfileScreenState extends ConsumerState<EditSkinProfileScreen> {
  bool _saving = false;

  static const _skinTypes = ['Oily', 'Dry', 'Combination', 'Normal', 'Sensitive'];
  // Must match the quiz's canonical label set (skin_concerns_screen.dart) so
  // edited concerns round-trip and re-select correctly.
  static const _concerns = [
    'Acne', 'Dark Spots', 'Fine Lines', 'Redness',
    'Dullness', 'Large Pores', 'Dehydration', 'Texture'
  ];
  static const _allergies = ['Fragrance', 'Sulfates', 'Parabens', 'Alcohol', 'None'];
  // Canonical Fitzpatrick values are the roman numerals the quiz stores and the
  // _FitzChip maps on ('I'..'VI'), so edited values round-trip.
  static const _fitz = ['I', 'II', 'III', 'IV', 'V', 'VI'];

  Future<void> _save() async {
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _saving = false);
    AppSnackbar.success(context, 'Skin profile updated');
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final quiz = ref.watch(quizProvider);
    final notifier = ref.read(quizProvider.notifier);

    return Scaffold(
      backgroundColor: context.dColors.background,
      appBar: const AppTopBar(title: 'Edit Skin Profile'),
      bottomNavigationBar: AppBottomBar(
        label: 'Save Changes',
        onPressed: _saving ? null : _save,
        loading: _saving,
        icon: Icons.check_rounded,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _IntroBanner(
            icon: Icons.face_retouching_natural_rounded,
            text: 'Keep this updated so your routine and product matches stay accurate.',
          ).animate().fadeIn(duration: 300.ms),

          const SizedBox(height: 16),

          AppSectionCard(
            title: 'Skin Type', hint: 'Choose one', overline: false,
            children: [
              AppChipGroup(
                options: _skinTypes,
                selected: quiz.skinType != null ? [quiz.skinType!] : [],
                singleSelect: true,
                onToggle: notifier.setSkinType,
              ),
            ],
          ).animate().fadeIn(delay: 60.ms, duration: 300.ms),

          const SizedBox(height: 14),

          AppSectionCard(
            title: 'Skin Concerns', hint: 'Select all that apply', overline: false,
            children: [
              AppChipGroup(
                options: _concerns,
                selected: quiz.skinConcerns,
                onToggle: notifier.toggleSkinConcern,
              ),
            ],
          ).animate().fadeIn(delay: 120.ms, duration: 300.ms),

          const SizedBox(height: 14),

          AppSectionCard(
            title: 'Allergies & Sensitivities',
            hint: 'Helps us flag risky ingredients', overline: false,
            children: [
              AppChipGroup(
                options: _allergies,
                selected: quiz.skinAllergies,
                selectedColor: AppColors.error,
                onToggle: notifier.toggleSkinAllergy,
              ),
            ],
          ).animate().fadeIn(delay: 180.ms, duration: 300.ms),

          const SizedBox(height: 14),

          AppSectionCard(
            title: 'Fitzpatrick Type', hint: 'Your skin\'s sun response', overline: false,
            children: [
              AppChipGroup(
                options: _fitz,
                selected: quiz.fitzpatrick != null ? [quiz.fitzpatrick!] : [],
                singleSelect: true,
                onToggle: notifier.setFitzpatrick,
              ),
            ],
          ).animate().fadeIn(delay: 240.ms, duration: 300.ms),
        ],
      ),
    );
  }
}

// ── _IntroBanner ──────────────────────────────────────────────────────────────

class _IntroBanner extends StatelessWidget {
  final IconData icon;
  final String text;
  const _IntroBanner({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.dColors.surfaceDim,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.dColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: AppTypography.bodySmall.copyWith(height: 1.45)),
          ),
        ],
      ),
    );
  }
}
