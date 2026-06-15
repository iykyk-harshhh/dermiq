import 'dart:math' as math;
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/diq_logo.dart';
import '../../providers/auth_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen>
    with TickerProviderStateMixin {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();

  int  _step    = 0; // 0=email, 1=sent (check your email)
  bool _loading = false;

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
    _emailCtrl.dispose();
    _sphereCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  /// Sends a real Firebase password-reset email. The user completes the reset
  /// via the secure link Firebase emails them — no client-side OTP.
  Future<void> _submitEmail() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    try {
      await ref.read(authProvider).sendPasswordReset(_emailCtrl.text.trim());
      if (!mounted) return;
      setState(() { _loading = false; _step = 1; });
    } on fb.FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      // Don't reveal whether an account exists — generic message either way.
      final msg = e.code == 'invalid-email'
          ? 'Please enter a valid email address.'
          : "If an account exists for that email, we've sent a reset link.";
      ScaffoldMessenger.of(context).showSnackBar(_snackBar(msg));
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(_snackBar('Something went wrong. Please try again.'));
    }
  }

  SnackBar _snackBar(String msg) => SnackBar(
        content: Text(msg,
            style: AppTypography.bodySmall.copyWith(color: Colors.white)),
        backgroundColor: AppColors.textPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      );

  Widget _buildStepView() {
    switch (_step) {
      case 1:
        return _ResetSuccessView(
          key: const ValueKey('success'),
          email: _emailCtrl.text.trim(),
          onBack: () => context.go('/login'),
        );
      default:
        return AnimatedBuilder(
          key: const ValueKey('email'),
          animation: Listenable.merge([_sphereCtrl, _pulseCtrl]),
          builder: (_, _) => _EmailFormContent(
            sphereValue: _sphereCtrl.value,
            pulseValue: _pulseCtrl.value,
            formKey: _formKey,
            emailCtrl: _emailCtrl,
            loading: _loading,
            onSubmit: _submitEmail,
            onSignIn: () => context.pop(),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // ── top bar ───────────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (_step > 0) {
                          setState(() => _step = _step - 1);
                        } else {
                          context.pop();
                        }
                      },
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
                    // Step indicator dots
                    _StepDots(current: _step, total: 2),
                  ],
                ).animate().fadeIn(duration: 400.ms),

                // ── body — animated switch between steps ──────────────────────
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 380),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: SlideTransition(
                        position: Tween(
                          begin: const Offset(0, 0.06),
                          end: Offset.zero,
                        ).animate(anim),
                        child: child,
                      ),
                    ),
                    child: _buildStepView(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _StepDots extends StatelessWidget {
  final int current;
  final int total;
  const _StepDots({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (i) {
        final done = i < current;
        final active = i == current && current < total;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: active ? 20 : 6,
          height: 6,
          margin: EdgeInsets.only(right: i < total - 1 ? 4 : 0),
          decoration: BoxDecoration(
            color: done
                ? AppColors.success
                : active
                    ? AppColors.primary
                    : Colors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 0 — Email entry
// ─────────────────────────────────────────────────────────────────────────────

class _EmailFormContent extends StatelessWidget {
  final double sphereValue;
  final double pulseValue;
  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
  final bool loading;
  final VoidCallback onSubmit;
  final VoidCallback onSignIn;

  const _EmailFormContent({
    required this.sphereValue,
    required this.pulseValue,
    required this.formKey,
    required this.emailCtrl,
    required this.loading,
    required this.onSubmit,
    required this.onSignIn,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final float = math.sin(sphereValue * 2 * math.pi) * 8.0;

    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: IntrinsicHeight(
            child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),

        // ── hero ──────────────────────────────────────────────────────────────
        SizedBox(
          height: size.height * 0.22,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 195, height: 195,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.5),
                      const Color(0xFFE8DEFF).withValues(alpha: 0.22),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 12 + float * 0.38, left: 8,
                child: _Sphere(
                  size: 52,
                  color: const Color(0xFF7258BC),
                  highlight: const Color(0xFFAA88EE),
                  shadow: const Color(0xFF412A8C),
                ),
              ),
              Positioned(
                top: 6 - float * 0.4, right: 8,
                child: _Sphere(
                  size: 38,
                  color: const Color(0xFF9B7FEA),
                  highlight: const Color(0xFFCDB0FF),
                  shadow: const Color(0xFF5C3DB5),
                ),
              ),
              Positioned(
                top: size.height * 0.08 - float * 0.2, left: 40,
                child: _Sphere(
                  size: 18,
                  color: const Color(0xFFB99FFF),
                  highlight: const Color(0xFFDDD0FF),
                  shadow: const Color(0xFF8B6FEA),
                ),
              ),
              Transform.translate(
                offset: Offset(0, float * 0.5),
                child: _LockBadge(pulseValue: pulseValue),
              ),
              Positioned(
                top: size.height * 0.065 + float * 0.35, left: 0,
                child: _InfoChip(
                  icon: '🔑',
                  label: 'Secure Process',
                  color: const Color(0xFFF59E0B),
                ).animate()
                    .fadeIn(duration: 500.ms, delay: 180.ms)
                    .slideX(begin: -0.25, curve: Curves.easeOutCubic),
              ),
              Positioned(
                bottom: size.height * 0.04 - float * 0.28, right: 0,
                child: _InfoChip(
                  icon: '📧',
                  label: 'Quick & Easy',
                  color: const Color(0xFF60A5FA),
                ).animate()
                    .fadeIn(duration: 500.ms, delay: 320.ms)
                    .slideX(begin: 0.25, curve: Curves.easeOutCubic),
              ),
            ],
          ),
        ),

        Text(
          'Forgot\nPassword?',
          style: AppTypography.display.copyWith(
            color: const Color(0xFF1E1B4B),
            height: 1.1,
          ),
        ).animate()
            .fadeIn(duration: 500.ms, delay: 80.ms)
            .slideY(begin: 0.12, curve: Curves.easeOutCubic),

        const SizedBox(height: 8),

        Text(
          "Enter your email and we'll send you a password-reset link.",
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ).animate().fadeIn(duration: 500.ms, delay: 150.ms),

        const SizedBox(height: 28),

        Form(
          key: formKey,
          child: _InputCard(
            child: AppTextField(
              controller: emailCtrl,
              hintText: 'Email address',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              prefixIcon: const Icon(Icons.mail_outline_rounded,
                  color: AppColors.primary, size: 20),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Email required';
                if (!v.contains('@')) return 'Enter a valid email';
                return null;
              },
              onSubmitted: (_) => onSubmit(),
            ),
          ),
        ).animate()
            .fadeIn(duration: 400.ms, delay: 220.ms)
            .slideY(begin: 0.1, curve: Curves.easeOutCubic),

        const SizedBox(height: 20),

        AppButton(
          label: 'Send Reset Link',
          onPressed: onSubmit,
          isLoading: loading,
        ).animate()
            .fadeIn(duration: 400.ms, delay: 300.ms)
            .slideY(begin: 0.12, curve: Curves.easeOutCubic),

        const Spacer(),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Remember your password? ', style: AppTypography.bodySmall),
            GestureDetector(
              onTap: onSignIn,
              child: Text(
                'Sign In',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ).animate().fadeIn(duration: 400.ms, delay: 400.ms),

        const SizedBox(height: 20),
      ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 1 — Email sent (check your inbox)
// ─────────────────────────────────────────────────────────────────────────────

class _ResetSuccessView extends StatelessWidget {
  final String email;
  final VoidCallback onBack;

  const _ResetSuccessView({super.key, required this.email, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: IntrinsicHeight(
            child: Column(
      children: [
        const Spacer(flex: 2),

        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 120, height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF22C55E).withValues(alpha: 0.10),
                ),
              ),
              Container(
                width: 104, height: 104,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF22C55E).withValues(alpha: 0.15),
                ),
              ),
              Container(
                width: 86, height: 86,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF34D399), Color(0xFF10B981)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF22C55E).withValues(alpha: 0.35),
                      blurRadius: 24,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(Icons.check_circle_outline_rounded,
                    color: Colors.white, size: 42),
              ),
            ],
          ),
        ).animate()
            .scale(
              begin: const Offset(0.4, 0.4),
              end: const Offset(1.0, 1.0),
              duration: 650.ms,
              curve: Curves.easeOutBack,
            )
            .fadeIn(duration: 400.ms),

        const SizedBox(height: 8),

        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF22C55E).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF22C55E).withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6, height: 6,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF22C55E),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Email Sent!',
                  style: AppTypography.labelSmall.copyWith(
                    color: const Color(0xFF16A34A),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ).animate()
            .fadeIn(duration: 400.ms, delay: 300.ms)
            .slideY(begin: 0.15, curve: Curves.easeOutCubic),

        const SizedBox(height: 24),

        Text(
          'Check Your Email',
          textAlign: TextAlign.center,
          style: AppTypography.display.copyWith(
            color: const Color(0xFF1E1B4B),
            height: 1.1,
          ),
        ).animate()
            .fadeIn(duration: 400.ms, delay: 200.ms)
            .slideY(begin: 0.1, curve: Curves.easeOutCubic),

        const SizedBox(height: 12),

        Text(
          email.isEmpty
              ? "If an account exists for that address, we've sent a password-reset link.\nOpen it to set a new password, then sign in."
              : "We've sent a password-reset link to $email.\nOpen it to set a new password, then sign in.",
          textAlign: TextAlign.center,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            height: 1.6,
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 280.ms),

        const SizedBox(height: 32),

        AppButton(
          label: 'Back to Sign In',
          onPressed: onBack,
        ).animate()
            .fadeIn(duration: 400.ms, delay: 400.ms)
            .slideY(begin: 0.1, curve: Curves.easeOutCubic),

        const Spacer(flex: 2),
      ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Lock badge (hero center, email form)
// ─────────────────────────────────────────────────────────────────────────────

class _LockBadge extends StatelessWidget {
  final double pulseValue;
  const _LockBadge({required this.pulseValue});

  @override
  Widget build(BuildContext context) {
    final glowAlpha = 0.20 + pulseValue * 0.16;

    return Transform.scale(
      scale: 0.90 + pulseValue * 0.10,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 108, height: 108,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primary.withValues(alpha: glowAlpha),
                  Colors.transparent,
                ],
                stops: const [0.5, 1.0],
              ),
            ),
          ),
          Container(
            width: 88, height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.gradientPrimary,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.32),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: const Icon(
              Icons.lock_reset_rounded,
              color: Colors.white,
              size: 38,
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

class _InfoChip extends StatelessWidget {
  final String icon;
  final String label;
  final Color color;

  const _InfoChip({
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
      width: size, height: size,
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
