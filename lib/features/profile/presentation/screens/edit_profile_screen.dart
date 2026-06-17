import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/dermiq_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../../core/firebase/repositories/user_repository.dart';

/// Account → Edit Profile. A real, database-backed profile: the user can edit
/// their name plus optional details (date of birth, gender, phone). Everything
/// except the name is optional — it's up to the user to fill in. Saved to
/// `users/{uid}` in Firestore (and the display name into the auth session).
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  DateTime? _dob;
  String? _gender;
  bool _loading = true;
  bool _saving = false;

  static const _genders = ['Female', 'Male', 'Other', 'Prefer not to say'];

  @override
  void initState() {
    super.initState();
    final user = ref.read(authStateProvider);
    _nameCtrl = TextEditingController(text: user?.displayName ?? '');
    _phoneCtrl = TextEditingController();
    _load();
  }

  /// Prefill the optional details from the stored profile document.
  Future<void> _load() async {
    final uid = ref.read(authStateProvider)?.id;
    final repo = ref.read(userRepositoryProvider);
    if (uid != null && repo != null) {
      final u = await repo.fetch(uid);
      if (u != null && mounted) {
        setState(() {
          if ((_nameCtrl.text).isEmpty && u.name != null) _nameCtrl.text = u.name!;
          _phoneCtrl.text = u.phone ?? '';
          _dob = u.dob;
          _gender = u.gender;
        });
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  int? get _age {
    if (_dob == null) return null;
    final now = DateTime.now();
    var age = now.year - _dob!.year;
    if (now.month < _dob!.month ||
        (now.month == _dob!.month && now.day < _dob!.day)) {
      age--;
    }
    return age;
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(now.year - 20, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Select your date of birth',
    );
    if (picked != null && mounted) setState(() => _dob = picked);
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      AppSnackbar.show(context, 'Please enter your name');
      return;
    }
    final user = ref.read(authStateProvider);
    if (user == null) return;

    setState(() => _saving = true);

    // Persist the profile to Firestore (users/{uid}). No-ops gracefully if
    // Firebase is unavailable.
    final phone = _phoneCtrl.text.trim();
    await ref.read(userRepositoryProvider)?.updateFields(user.id, {
      'name': name,
      'dob': _dob?.millisecondsSinceEpoch,
      'age': _age,
      'gender': _gender,
      'phone': phone.isEmpty ? null : phone,
    });

    // Keep the in-session display name in sync.
    ref.read(authStateProvider.notifier).state = AppUser(
      id: user.id,
      displayName: name,
      email: user.email,
      photoUrl: user.photoUrl,
      isAnonymous: user.isAnonymous,
    );

    if (!mounted) return;
    setState(() => _saving = false);
    AppSnackbar.success(context, 'Profile saved');
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider);
    final email = user?.email ?? 'Not set';
    final c = context.dColors;

    return Scaffold(
      backgroundColor: c.background,
      appBar: const AppTopBar(title: 'Edit Profile'),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
              children: [
                // Avatar
                Center(
                  child: Container(
                    width: 88,
                    height: 88,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                          colors: [Color(0xFF8B6FEA), Color(0xFFA78BFA)]),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        (_nameCtrl.text.isNotEmpty ? _nameCtrl.text[0] : 'S')
                            .toUpperCase(),
                        style: AppTypography.h2.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Name (required)
                _Label('Full Name'),
                const SizedBox(height: 8),
                _FieldBox(
                  child: TextField(
                    controller: _nameCtrl,
                    onChanged: (_) => setState(() {}),
                    textCapitalization: TextCapitalization.words,
                    style: AppTypography.bodyLarge.copyWith(color: c.textPrimary),
                    decoration: const InputDecoration(
                      hintText: 'Your name',
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Date of birth (optional) → auto age
                Row(
                  children: [
                    _Label('Date of Birth'),
                    const SizedBox(width: 8),
                    Text('Optional',
                        style: AppTypography.caption.copyWith(color: c.textTertiary)),
                    const Spacer(),
                    if (_age != null)
                      Text('Age $_age',
                          style: AppTypography.labelSmall
                              .copyWith(color: AppColors.primary)),
                  ],
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickDob,
                  child: _FieldBox(
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Row(
                        children: [
                          Icon(Icons.cake_outlined, size: 18, color: c.textSecondary),
                          const SizedBox(width: 10),
                          Text(
                            _dob == null ? 'Select your birth date' : Fmt.date(_dob!),
                            style: AppTypography.bodyMedium.copyWith(
                              color: _dob == null ? c.textTertiary : c.textPrimary,
                            ),
                          ),
                          const Spacer(),
                          Icon(Icons.calendar_today_rounded,
                              size: 16, color: c.textTertiary),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Gender (optional)
                Row(
                  children: [
                    _Label('Gender'),
                    const SizedBox(width: 8),
                    Text('Optional',
                        style: AppTypography.caption.copyWith(color: c.textTertiary)),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _genders.map((g) {
                    final selected = _gender == g;
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _gender = selected ? null : g);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primary.withValues(alpha: 0.10)
                              : c.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selected ? AppColors.primary : c.borderLight,
                            width: selected ? 1.6 : 1.0,
                          ),
                        ),
                        child: Text(
                          g,
                          style: AppTypography.labelSmall.copyWith(
                            color: selected ? AppColors.primary : c.textSecondary,
                            fontWeight:
                                selected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),

                // Phone (optional)
                Row(
                  children: [
                    _Label('Phone'),
                    const SizedBox(width: 8),
                    Text('Optional',
                        style: AppTypography.caption.copyWith(color: c.textTertiary)),
                  ],
                ),
                const SizedBox(height: 8),
                _FieldBox(
                  child: TextField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    style: AppTypography.bodyLarge.copyWith(color: c.textPrimary),
                    decoration: const InputDecoration(
                      hintText: '+91 98765 43210',
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Email (read-only)
                _Label('Email'),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: c.surfaceDim,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(email,
                            style: AppTypography.bodyMedium
                                .copyWith(color: c.textSecondary)),
                      ),
                      Icon(Icons.lock_outline_rounded,
                          size: 16, color: c.textTertiary),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text('Email and password changes require verification.',
                    style: AppTypography.caption.copyWith(color: c.textTertiary)),

                const SizedBox(height: 28),
                AppButton(
                  label: 'Save Changes',
                  isLoading: _saving,
                  onPressed: _saving ? null : _save,
                ),
              ],
            ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) =>
      Text(text, style: AppTypography.labelMedium);
}

class _FieldBox extends StatelessWidget {
  final Widget child;
  const _FieldBox({required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.dColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.dColors.borderLight),
      ),
      child: child,
    );
  }
}
