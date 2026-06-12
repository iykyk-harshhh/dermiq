import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/dermiq_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../auth/providers/auth_provider.dart';

/// Account → Edit Profile. Lets the user change their display name (persisted
/// into the auth session). Email/password changes require Firebase verification
/// and are surfaced as read-only here until configured.
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _nameCtrl;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authStateProvider);
    _nameCtrl = TextEditingController(text: user?.displayName ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      AppSnackbar.show(context, 'Please enter your name');
      return;
    }
    final user = ref.read(authStateProvider);
    if (user != null) {
      ref.read(authStateProvider.notifier).state = AppUser(
        id: user.id,
        displayName: name,
        email: user.email,
        photoUrl: user.photoUrl,
        isAnonymous: user.isAnonymous,
      );
    }
    AppSnackbar.success(context, 'Profile updated');
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider);
    final email = user?.email ?? 'Not set';

    return Scaffold(
      backgroundColor: context.dColors.background,
      appBar: const AppTopBar(title: 'Edit Profile'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        children: [
          // Avatar
          Center(
            child: Stack(
              children: [
                Container(
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
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onTap: () => AppSnackbar.show(
                        context, 'Photo upload coming soon'),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: context.dColors.background, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt_rounded,
                          size: 14, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Name field
          Text('Full Name', style: AppTypography.labelMedium),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: context.dColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.dColors.borderLight),
            ),
            child: TextField(
              controller: _nameCtrl,
              onChanged: (_) => setState(() {}),
              style: AppTypography.bodyLarge
                  .copyWith(color: context.dColors.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Your name',
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Email (read-only)
          Text('Email', style: AppTypography.labelMedium),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: context.dColors.surfaceDim,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(email,
                      style: AppTypography.bodyMedium
                          .copyWith(color: context.dColors.textSecondary)),
                ),
                Icon(Icons.lock_outline_rounded,
                    size: 16, color: context.dColors.textTertiary),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text('Email and password changes require verification.',
              style: AppTypography.caption
                  .copyWith(color: context.dColors.textTertiary)),

          const SizedBox(height: 28),
          AppButton(label: 'Save Changes', onPressed: _save),
        ],
      ),
    );
  }
}
