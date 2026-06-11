import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/firebase/repositories/user_repository.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../profile_quiz/providers/quiz_provider.dart';
import '../../providers/auth_provider.dart';

/// First-launch profile setup. Fields in the spec order:
/// Full Name → Gender → Email → Age → Skin Type → Hair Type.
class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  String? _gender;
  String? _skinType;
  String? _hairType;

  static const _genders = ['Male', 'Female', 'Other', 'Prefer Not To Say'];
  static const _skinTypes = ['Oily', 'Dry', 'Combination', 'Normal', 'Sensitive'];
  static const _hairTypes = ['Straight', 'Wavy', 'Curly', 'Coily'];

  @override
  void initState() {
    super.initState();
    // Prefill from the authenticated account (Google / email).
    final user = ref.read(authStateProvider);
    _nameCtrl.text = user?.displayName ?? '';
    _emailCtrl.text = user?.email ?? '';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  bool get _valid => _nameCtrl.text.trim().isNotEmpty && _gender != null;

  void _continue() {
    if (!_valid) {
      AppSnackbar.error(context, 'Please enter your name and select a gender.');
      return;
    }
    final q = ref.read(quizProvider.notifier);
    q.setName(_nameCtrl.text.trim());
    q.setGender(_gender!);
    if (_emailCtrl.text.trim().isNotEmpty) q.setEmail(_emailCtrl.text.trim());
    final age = int.tryParse(_ageCtrl.text.trim());
    if (age != null) q.setAge(age);
    if (_skinType != null) q.setSkinType(_skinType!);
    if (_hairType != null) q.setHairType(_hairType!);

    // Persist to Firestore users/{uid} when signed in to a real backend.
    final uid = ref.read(authStateProvider)?.id;
    final repo = ref.read(userRepositoryProvider);
    if (uid != null && repo != null) {
      repo.updateFields(uid, {
        'name': _nameCtrl.text.trim(),
        'gender': _gender,
        'age': ?age,
        if (_skinType != null) 'skinType': _skinType,
        if (_hairType != null) 'hairType': _hairType,
      });
    }

    context.push('/quiz/skin-type');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: AppBottomBar(
        label: 'Continue',
        icon: Icons.arrow_forward_rounded,
        onPressed: _continue,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          children: [
            Text('Set up your profile', style: AppTypography.h2)
                .animate().fadeIn(duration: 350.ms).slideY(begin: 0.06),
            const SizedBox(height: 6),
            Text('A few details so DermIQ can personalise your routine.',
                    style: AppTypography.bodyMedium)
                .animate().fadeIn(delay: 60.ms, duration: 300.ms),
            const SizedBox(height: 22),

            // 1. Full Name
            AppSectionCard(
              title: 'Full Name', overline: false,
              children: [
                AppTextField(
                  controller: _nameCtrl,
                  hintText: 'Your name',
                  textInputAction: TextInputAction.next,
                  onChanged: (_) => setState(() {}),
                ),
              ],
            ).animate().fadeIn(delay: 80.ms, duration: 300.ms),
            const SizedBox(height: 14),

            // 2. Gender
            AppSectionCard(
              title: 'Gender', overline: false,
              children: [
                AppChipGroup(
                  options: _genders,
                  selected: _gender != null ? [_gender!] : const [],
                  singleSelect: true,
                  onToggle: (v) => setState(() => _gender = v),
                ),
              ],
            ).animate().fadeIn(delay: 120.ms, duration: 300.ms),
            const SizedBox(height: 14),

            // 3. Email
            AppSectionCard(
              title: 'Email', overline: false,
              children: [
                AppTextField(
                  controller: _emailCtrl,
                  hintText: 'you@email.com',
                  keyboardType: TextInputType.emailAddress,
                ),
              ],
            ).animate().fadeIn(delay: 160.ms, duration: 300.ms),
            const SizedBox(height: 14),

            // 4. Age
            AppSectionCard(
              title: 'Age', overline: false,
              children: [
                AppTextField(
                  controller: _ageCtrl,
                  hintText: 'Your age',
                  keyboardType: TextInputType.number,
                ),
              ],
            ).animate().fadeIn(delay: 200.ms, duration: 300.ms),
            const SizedBox(height: 14),

            // 5. Skin Type
            AppSectionCard(
              title: 'Skin Type', hint: 'Optional — refined later', overline: false,
              children: [
                AppChipGroup(
                  options: _skinTypes,
                  selected: _skinType != null ? [_skinType!] : const [],
                  singleSelect: true,
                  onToggle: (v) => setState(() => _skinType = v),
                ),
              ],
            ).animate().fadeIn(delay: 240.ms, duration: 300.ms),
            const SizedBox(height: 14),

            // 6. Hair Type
            AppSectionCard(
              title: 'Hair Type', hint: 'Optional — refined later', overline: false,
              children: [
                AppChipGroup(
                  options: _hairTypes,
                  selected: _hairType != null ? [_hairType!] : const [],
                  singleSelect: true,
                  selectedColor: const Color(0xFFEC4899),
                  onToggle: (v) => setState(() => _hairType = v),
                ),
              ],
            ).animate().fadeIn(delay: 280.ms, duration: 300.ms),
          ],
        ),
      ),
    );
  }
}
