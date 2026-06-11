import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/diq_logo.dart';
import '../../../../core/services/preferences_service.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with TickerProviderStateMixin {
  final _formKey        = GlobalKey<FormState>();
  final _nameCtrl       = TextEditingController();
  final _emailCtrl      = TextEditingController();
  final _passCtrl       = TextEditingController();
  final _confirmCtrl    = TextEditingController();
  String _gender        = 'Female';
  bool _obscure         = true;
  bool _obscureConfirm  = true;
  bool _loading         = false;
  bool _agreed          = false;

  late final AnimationController _sphereCtrl;
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _sphereCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _sphereCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_agreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please accept the Terms to continue.',
              style: AppTypography.bodySmall.copyWith(color: Colors.white)),
          backgroundColor: AppColors.textPrimary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    setState(() => _loading = true);
    await ref.read(authProvider).signUpWithEmail(
      _emailCtrl.text,
      _passCtrl.text,
      displayName: _nameCtrl.text.trim(),
      gender: _gender,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    // New account → walk through the skin then hair quiz (shown once).
    context.go('/quiz/skin-type');
  }

  /// Google sign-up/in: a brand-new Google user is sent through the quizzes;
  /// a returning user (quizzes already done) lands on Home.
  Future<void> _googleSignIn() async {
    setState(() => _loading = true);
    await ref.read(authProvider).signInWithGoogle();
    if (!mounted) return;
    setState(() => _loading = false);
    context.go(
      PreferencesService.profileComplete ? '/home' : '/quiz/skin-type',
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // ── top bar ──────────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.7),
                          shape: BoxShape.circle,
                          boxShadow: AppColors.cardShadow,
                        ),
                        child: const Icon(Icons.arrow_back_rounded,
                            size: 20, color: Color(0xFF1E1B4B)),
                      ),
                    ),
                    const DiqLogo(size: DiqLogoSize.small),
                    const SizedBox(width: 40),
                  ],
                ).animate().fadeIn(duration: 400.ms),

                // ── animated hero ─────────────────────────────────────────────
                AnimatedBuilder(
                  animation: Listenable.merge([_sphereCtrl, _pulseCtrl]),
                  builder: (_, _) => _RegisterHero(
                    screenSize: size,
                    sphereValue: _sphereCtrl.value,
                    pulseValue: _pulseCtrl.value,
                  ),
                ),

                // ── headline ──────────────────────────────────────────────────
                Text(
                  'Create\nAccount',
                  style: AppTypography.display.copyWith(
                    color: const Color(0xFF1E1B4B),
                    height: 1.1,
                  ),
                ).animate()
                    .fadeIn(duration: 500.ms, delay: 80.ms)
                    .slideY(begin: 0.12, curve: Curves.easeOutCubic),

                const SizedBox(height: 8),

                Text(
                  'Join DermIQ — discover your perfect skin & hair routine.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ).animate().fadeIn(duration: 500.ms, delay: 150.ms),

                const SizedBox(height: 28),

                // ── form ──────────────────────────────────────────────────────
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Full name
                      _InputCard(
                        child: AppTextField(
                          controller: _nameCtrl,
                          hintText: 'Full name',
                          textInputAction: TextInputAction.next,
                          prefixIcon: const Icon(Icons.person_outline_rounded,
                              color: AppColors.primary, size: 20),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Name required';
                            return null;
                          },
                        ),
                      ).animate()
                          .fadeIn(duration: 400.ms, delay: 220.ms)
                          .slideY(begin: 0.1, curve: Curves.easeOutCubic),

                      const SizedBox(height: 12),

                      // Gender picker
                      _GenderPicker(
                        selected: _gender,
                        onChanged: (g) => setState(() => _gender = g),
                      ).animate()
                          .fadeIn(duration: 400.ms, delay: 250.ms)
                          .slideY(begin: 0.1, curve: Curves.easeOutCubic),

                      const SizedBox(height: 12),

                      // Email
                      _InputCard(
                        child: AppTextField(
                          controller: _emailCtrl,
                          hintText: 'Email address',
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          prefixIcon: const Icon(Icons.mail_outline_rounded,
                              color: AppColors.primary, size: 20),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Email required';
                            if (!v.contains('@')) return 'Enter a valid email';
                            return null;
                          },
                        ),
                      ).animate()
                          .fadeIn(duration: 400.ms, delay: 280.ms)
                          .slideY(begin: 0.1, curve: Curves.easeOutCubic),

                      const SizedBox(height: 12),

                      // Password
                      _InputCard(
                        child: AppTextField(
                          controller: _passCtrl,
                          hintText: 'Password',
                          obscureText: _obscure,
                          textInputAction: TextInputAction.done,
                          prefixIcon: const Icon(Icons.lock_outline_rounded,
                              color: AppColors.primary, size: 20),
                          suffixIcon: GestureDetector(
                            onTap: () => setState(() => _obscure = !_obscure),
                            child: Icon(
                              _obscure
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.textTertiary,
                              size: 20,
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Password required';
                            if (v.length < 8) return 'Minimum 8 characters';
                            return null;
                          },
                        ),
                      ).animate()
                          .fadeIn(duration: 400.ms, delay: 340.ms)
                          .slideY(begin: 0.1, curve: Curves.easeOutCubic),

                      const SizedBox(height: 12),

                      // Confirm password
                      _InputCard(
                        child: AppTextField(
                          controller: _confirmCtrl,
                          hintText: 'Confirm password',
                          obscureText: _obscureConfirm,
                          textInputAction: TextInputAction.done,
                          prefixIcon: const Icon(Icons.lock_outline_rounded,
                              color: AppColors.primary, size: 20),
                          suffixIcon: GestureDetector(
                            onTap: () => setState(
                                () => _obscureConfirm = !_obscureConfirm),
                            child: Icon(
                              _obscureConfirm
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.textTertiary,
                              size: 20,
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Please confirm password';
                            if (v != _passCtrl.text) return 'Passwords do not match';
                            return null;
                          },
                          onSubmitted: (_) => _submit(),
                        ),
                      ).animate()
                          .fadeIn(duration: 400.ms, delay: 370.ms)
                          .slideY(begin: 0.1, curve: Curves.easeOutCubic),

                      const SizedBox(height: 16),

                      // ── password strength indicator ─────────────────────────
                      ValueListenableBuilder(
                        valueListenable: _passCtrl,
                        builder: (_, value, _) =>
                            _PasswordStrength(password: value.text),
                      ).animate().fadeIn(duration: 400.ms, delay: 380.ms),

                      const SizedBox(height: 16),

                      // ── terms checkbox ──────────────────────────────────────
                      GestureDetector(
                        onTap: () => setState(() => _agreed = !_agreed),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 22, height: 22,
                              decoration: BoxDecoration(
                                color: _agreed
                                    ? AppColors.primary
                                    : Colors.white.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: _agreed
                                      ? AppColors.primary
                                      : const Color(0xFFD8C8FF),
                                  width: 1.5,
                                ),
                                boxShadow: AppColors.cardShadow,
                              ),
                              child: _agreed
                                  ? const Icon(Icons.check_rounded,
                                      color: Colors.white, size: 14)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  text: 'I agree to the ',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'Terms of Service',
                                      style: AppTypography.labelSmall.copyWith(
                                        color: AppColors.primary,
                                        decoration: TextDecoration.underline,
                                        decorationColor: AppColors.primary,
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' and ',
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Privacy Policy',
                                      style: AppTypography.labelSmall.copyWith(
                                        color: AppColors.primary,
                                        decoration: TextDecoration.underline,
                                        decorationColor: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 400.ms, delay: 420.ms),

                      const SizedBox(height: 22),

                      AppButton(
                        label: 'Create Account',
                        onPressed: _submit,
                        isLoading: _loading,
                      ).animate()
                          .fadeIn(duration: 400.ms, delay: 480.ms)
                          .slideY(begin: 0.12, curve: Curves.easeOutCubic),

                      const SizedBox(height: 20),

                      // ── divider ────────────────────────────────────────────
                      Row(children: [
                        const Expanded(child: Divider(color: Color(0xFFD8C8FF))),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text('or', style: AppTypography.caption),
                        ),
                        const Expanded(child: Divider(color: Color(0xFFD8C8FF))),
                      ]).animate().fadeIn(duration: 400.ms, delay: 540.ms),

                      const SizedBox(height: 16),

                      AppSocialButton(
                        label: 'Sign up with Google',
                        icon: const _GoogleIcon(),
                        onPressed: _googleSignIn,
                      ).animate().fadeIn(duration: 400.ms, delay: 600.ms),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // ── login link ────────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account? ',
                        style: AppTypography.bodySmall),
                    GestureDetector(
                      onTap: () => context.pushReplacement('/login'),
                      child: Text(
                        'Sign In',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 400.ms, delay: 660.ms),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero Section
// ─────────────────────────────────────────────────────────────────────────────

class _RegisterHero extends StatelessWidget {
  final Size screenSize;
  final double sphereValue;
  final double pulseValue;

  const _RegisterHero({
    required this.screenSize,
    required this.sphereValue,
    required this.pulseValue,
  });

  @override
  Widget build(BuildContext context) {
    final float = math.sin(sphereValue * 2 * math.pi) * 9.0;

    return SizedBox(
      height: screenSize.height * 0.22,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Radial glow bloom
          Container(
            width: 190,
            height: 190,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.5),
                  const Color(0xFFD8C8FF).withValues(alpha: 0.22),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // Sphere — top left (opposite positioning from login)
          Positioned(
            top: 8 - float * 0.45,
            left: 0,
            child: _Sphere(
              size: 44,
              color: const Color(0xFF9B7FEA),
              highlight: const Color(0xFFCDB0FF),
              shadow: const Color(0xFF5C3DB5),
            ),
          ),

          // Sphere — bottom right
          Positioned(
            bottom: 10 + float * 0.38,
            right: 0,
            child: _Sphere(
              size: 60,
              color: const Color(0xFF6B4FD8),
              highlight: const Color(0xFFA688EE),
              shadow: const Color(0xFF3D208C),
            ),
          ),

          // Tiny accent sphere — mid right
          Positioned(
            top: screenSize.height * 0.08 + float * 0.2,
            right: 36,
            child: _Sphere(
              size: 22,
              color: const Color(0xFFB99FFF),
              highlight: const Color(0xFFDDD0FF),
              shadow: const Color(0xFF8B6FEA),
            ),
          ),

          // Central sparkle badge
          Transform.translate(
            offset: Offset(0, float * 0.5),
            child: _SparkleCoreBadge(pulseValue: pulseValue),
          ),

          // Benefit chip — AI Analysis (top, left of center)
          Positioned(
            top: screenSize.height * 0.02 + float * 0.3,
            left: 10,
            child: const _BenefitChip(
              icon: '🔬',
              label: 'AI Analysis',
              color: Color(0xFF7C5CFF),
            ).animate()
                .fadeIn(duration: 500.ms, delay: 180.ms)
                .slideX(begin: -0.25, curve: Curves.easeOutCubic),
          ),

          // Benefit chip — Skin Score (right side)
          Positioned(
            top: screenSize.height * 0.06 - float * 0.25,
            right: 8,
            child: const _BenefitChip(
              icon: '📊',
              label: 'Skin Score',
              color: Color(0xFF22C55E),
            ).animate()
                .fadeIn(duration: 500.ms, delay: 300.ms)
                .slideX(begin: 0.25, curve: Curves.easeOutCubic),
          ),

          // Benefit chip — Custom Routine (bottom, left of center)
          Positioned(
            bottom: screenSize.height * 0.02 + float * 0.4,
            left: 4,
            child: const _BenefitChip(
              icon: '🌿',
              label: 'Custom Routine',
              color: Color(0xFF60A5FA),
            ).animate()
                .fadeIn(duration: 500.ms, delay: 420.ms)
                .slideX(begin: -0.2, curve: Curves.easeOutCubic),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _SparkleCoreBadge extends StatelessWidget {
  final double pulseValue;
  const _SparkleCoreBadge({required this.pulseValue});

  @override
  Widget build(BuildContext context) {
    final glow = 0.22 + pulseValue * 0.14;

    return Transform.scale(
      scale: 0.90 + pulseValue * 0.10,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow ring
          Container(
            width: 104,
            height: 104,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primary.withValues(alpha: glow),
                  Colors.transparent,
                ],
                stops: const [0.55, 1.0],
              ),
            ),
          ),
          // Core circle
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.gradientPrimary,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
        ],
      ),
    ).animate()
        .scale(
          begin: const Offset(0.45, 0.45),
          end: const Offset(1.0, 1.0),
          duration: 650.ms,
          delay: 80.ms,
          curve: Curves.easeOutBack,
        )
        .fadeIn(duration: 400.ms, delay: 80.ms);
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _BenefitChip extends StatelessWidget {
  final String icon;
  final String label;
  final Color color;

  const _BenefitChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.14),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          ...AppColors.cardShadow,
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 22, height: 22,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(icon, style: const TextStyle(fontSize: 11)),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Password strength indicator
// ─────────────────────────────────────────────────────────────────────────────

class _PasswordStrength extends StatelessWidget {
  final String password;
  const _PasswordStrength({required this.password});

  ({int level, String label, Color color}) get _strength {
    if (password.isEmpty) {
      return (level: 0, label: '', color: Colors.transparent);
    }
    final hasUpper  = password.contains(RegExp(r'[A-Z]'));
    final hasDigit  = password.contains(RegExp(r'[0-9]'));
    final hasSymbol = password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));
    final long      = password.length >= 10;

    final score = [hasUpper, hasDigit, hasSymbol, long].where((v) => v).length;

    if (password.length < 6) {
      return (level: 1, label: 'Too short', color: const Color(0xFFEF4444));
    }
    if (score <= 1) {
      return (level: 1, label: 'Weak', color: const Color(0xFFF97316));
    }
    if (score == 2) {
      return (level: 2, label: 'Fair', color: const Color(0xFFF59E0B));
    }
    if (score == 3) {
      return (level: 3, label: 'Good', color: const Color(0xFF22C55E));
    }
    return (level: 4, label: 'Strong', color: const Color(0xFF10B981));
  }

  @override
  Widget build(BuildContext context) {
    final s = _strength;
    if (password.isEmpty) return const SizedBox.shrink();

    return Row(
      children: [
        Expanded(
          child: Row(
            children: List.generate(4, (i) {
              final filled = i < s.level;
              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: 4,
                  margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: filled
                        ? s.color
                        : const Color(0xFFE8DEFF),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(width: 10),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            s.label,
            key: ValueKey(s.label),
            style: AppTypography.caption.copyWith(
              color: s.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _Sphere extends StatelessWidget {
  final double size;
  final Color color;
  final Color highlight;
  final Color shadow;

  const _Sphere({
    required this.size,
    required this.color,
    required this.highlight,
    required this.shadow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.35, -0.38),
          radius: 0.75,
          colors: [highlight, color, shadow],
          stops: const [0.0, 0.45, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.35),
            blurRadius: size * 0.4,
            offset: Offset(0, size * 0.18),
          ),
        ],
      ),
    );
  }
}

class _GenderPicker extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _GenderPicker({required this.selected, required this.onChanged});

  static const _options = ['Male', 'Female', 'Other'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
        border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.wc_rounded, color: AppColors.primary, size: 18),
              const SizedBox(width: 10),
              Text('Gender', style: AppTypography.labelSmall.copyWith(
                color: AppColors.textSecondary,
              )),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: _options.map((opt) {
              final isSelected = opt == selected;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(opt),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: EdgeInsets.only(right: opt != 'Other' ? 8 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.10)
                          : AppColors.surfaceDim.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : const Color(0xFFD8C8FF),
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: Text(
                      opt,
                      textAlign: TextAlign.center,
                      style: AppTypography.labelSmall.copyWith(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _InputCard extends StatelessWidget {
  final Widget child;
  const _InputCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      child: child,
    );
  }
}

class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'G',
      style: TextStyle(
        fontFamily: 'serif',
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Color(0xFF4285F4),
      ),
    );
  }
}
