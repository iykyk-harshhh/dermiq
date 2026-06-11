import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/dermiq_colors.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../profile_quiz/providers/quiz_provider.dart';

class EditHairProfileScreen extends ConsumerStatefulWidget {
  const EditHairProfileScreen({super.key});

  @override
  ConsumerState<EditHairProfileScreen> createState() => _EditHairProfileScreenState();
}

class _EditHairProfileScreenState extends ConsumerState<EditHairProfileScreen> {
  bool _saving = false;

  static const _hairTypes = ['Straight', 'Wavy', 'Curly', 'Coily'];
  static const _scalpTypes = ['Oily', 'Dry', 'Balanced', 'Flaky'];
  static const _concerns = [
    'Hair Fall', 'Dandruff', 'Frizz', 'Thinning', 'Damage', 'Split Ends', 'Greying'
  ];
  static const _treatments = ['Color', 'Keratin', 'Bleach', 'Relaxing', 'Perm', 'None'];

  static const _hairAccent = Color(0xFFEC4899);

  Future<void> _save() async {
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _saving = false);
    AppSnackbar.success(context, 'Hair profile updated');
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final quiz = ref.watch(quizProvider);
    final notifier = ref.read(quizProvider.notifier);

    return Scaffold(
      backgroundColor: context.dColors.background,
      appBar: const AppTopBar(title: 'Edit Hair Profile'),
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
            icon: Icons.cut_rounded,
            text: 'Tell us about your hair so we can tailor scalp and hair-care advice.',
          ).animate().fadeIn(duration: 300.ms),

          const SizedBox(height: 16),

          AppSectionCard(
            title: 'Hair Type', hint: 'Choose one', overline: false,
            children: [
              AppChipGroup(
                options: _hairTypes,
                selected: quiz.hairType != null ? [quiz.hairType!] : [],
                singleSelect: true,
                selectedColor: _hairAccent,
                onToggle: notifier.setHairType,
              ),
            ],
          ).animate().fadeIn(delay: 60.ms, duration: 300.ms),

          const SizedBox(height: 14),

          AppSectionCard(
            title: 'Scalp Type', hint: 'Choose one', overline: false,
            children: [
              AppChipGroup(
                options: _scalpTypes,
                selected: quiz.scalpType != null ? [quiz.scalpType!] : [],
                singleSelect: true,
                selectedColor: _hairAccent,
                onToggle: notifier.setScalpType,
              ),
            ],
          ).animate().fadeIn(delay: 120.ms, duration: 300.ms),

          const SizedBox(height: 14),

          AppSectionCard(
            title: 'Hair Concerns', hint: 'Select all that apply', overline: false,
            children: [
              AppChipGroup(
                options: _concerns,
                selected: quiz.hairConcerns,
                selectedColor: _hairAccent,
                onToggle: notifier.toggleHairConcern,
              ),
            ],
          ).animate().fadeIn(delay: 180.ms, duration: 300.ms),

          const SizedBox(height: 14),

          AppSectionCard(
            title: 'Chemical Treatments', hint: 'Recent or ongoing', overline: false,
            children: [
              AppChipGroup(
                options: _treatments,
                selected: quiz.hairTreatments,
                selectedColor: _hairAccent,
                onToggle: notifier.toggleHairTreatment,
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
              color: const Color(0xFFEC4899).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: const Color(0xFFEC4899), size: 18),
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
