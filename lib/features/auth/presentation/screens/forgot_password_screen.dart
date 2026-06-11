import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/diq_logo.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with TickerProviderStateMixin {
  final _formKey       = GlobalKey<FormState>();
  final _emailCtrl     = TextEditingController();
  final _codeCtrl      = TextEditingController();
  final _newPassCtrl   = TextEditingController();
  final _confirmCtrl   = TextEditingController();

  int  _step           = 0; // 0=email, 1=code, 2=new password, 3=success
  bool _loading        = false;
  bool _resendLoading  = false;
  bool _obscureNew     = true;
  bool _obscureConfirm = true;

  // OTP state. Until Firebase is wired, the code is generated + verified
  // locally (mock). Swap `_sendOtp`/`_submitCode` for FirebaseAuth's
  // `sendPasswordResetEmail` / a Firestore-backed OTP when configured.
  static const _maxAttempts = 5;
  static const _resendSeconds = 60;
  static const _otpTtl = Duration(minutes: 5);

  String? _otp;            // the active code (mock)
  DateTime? _otpSentAt;    // when it was issued (for 5-min expiry)
  int _attempts = 0;       // wrong-code attempts (max 5)
  int _resendCountdown = 0; // seconds left before resend is allowed
  Timer? _resendTimer;

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
    _resendTimer?.cancel();
    _emailCtrl.dispose();
    _codeCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmCtrl.dispose();
    _sphereCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  /// Issues a fresh OTP, resets attempts/expiry and starts the resend timer.
  /// (Mock: reveals the code in a snackbar so the flow is testable until
  /// Firebase delivers the real one.)
  void _sendOtp() {
    final code = (math.Random().nextInt(900000) + 100000).toString();
    _otp = code;
    _otpSentAt = DateTime.now();
    _attempts = 0;
    _codeCtrl.clear();
    _startResendCountdown();
    ScaffoldMessenger.of(context).showSnackBar(
      _snackBar('Demo code: $code  ·  Firebase will send the real code once configured.'),
    );
  }

  void _startResendCountdown() {
    _resendTimer?.cancel();
    setState(() => _resendCountdown = _resendSeconds);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      if (_resendCountdown <= 1) {
        t.cancel();
        setState(() => _resendCountdown = 0);
      } else {
        setState(() => _resendCountdown--);
      }
    });
  }

  Future<void> _submitEmail() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    setState(() { _loading = false; _step = 1; });
    _sendOtp();
  }

  Future<void> _submitCode() async {
    final code = _codeCtrl.text.trim();
    if (code.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(_snackBar('Enter the 6-digit code.'));
      return;
    }
    // Expiry — 5-minute window.
    if (_otpSentAt == null ||
        DateTime.now().difference(_otpSentAt!) > _otpTtl) {
      ScaffoldMessenger.of(context)
          .showSnackBar(_snackBar('OTP expired. Please resend a new code.'));
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _loading = false);

    if (code != _otp) {
      _attempts++;
      final left = _maxAttempts - _attempts;
      if (left <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          _snackBar('Too many attempts. Please resend a new code.'));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          _snackBar('Invalid OTP. $left ${left == 1 ? "attempt" : "attempts"} left.'));
      }
      return;
    }
    setState(() => _step = 2);
  }

  Future<void> _submitPassword() async {
    final pw = _newPassCtrl.text;
    final String? err = switch (pw) {
      _ when pw.length < 8 => 'Password must be at least 8 characters.',
      _ when !pw.contains(RegExp(r'[A-Z]')) => 'Add at least one uppercase letter.',
      _ when !pw.contains(RegExp(r'[a-z]')) => 'Add at least one lowercase letter.',
      _ when !pw.contains(RegExp(r'[0-9]')) => 'Add at least one number.',
      _ => null,
    };
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(_snackBar(err));
      return;
    }
    if (pw != _confirmCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(_snackBar('Passwords do not match.'));
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    setState(() { _loading = false; _step = 3; });
  }

  Future<void> _resend() async {
    if (_resendCountdown > 0) return; // guarded by the 60s timer
    setState(() => _resendLoading = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() => _resendLoading = false);
    _sendOtp();
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
        return _CodeFormContent(
          key: const ValueKey('code'),
          email: _emailCtrl.text,
          codeCtrl: _codeCtrl,
          loading: _loading,
          resendLoading: _resendLoading,
          resendCountdown: _resendCountdown,
          onSubmit: _submitCode,
          onResend: _resend,
          onBack: () => setState(() { _step = 0; _codeCtrl.clear(); }),
        );
      case 2:
        return _NewPasswordContent(
          key: const ValueKey('password'),
          newPassCtrl: _newPassCtrl,
          confirmCtrl: _confirmCtrl,
          obscureNew: _obscureNew,
          obscureConfirm: _obscureConfirm,
          loading: _loading,
          onToggleNew: () => setState(() => _obscureNew = !_obscureNew),
          onToggleConfirm: () =>
              setState(() => _obscureConfirm = !_obscureConfirm),
          onSubmit: _submitPassword,
        );
      case 3:
        return _ResetSuccessView(
          key: const ValueKey('success'),
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
                    _StepDots(current: _step, total: 4),
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
          "Enter your email and we'll send you a verification code.",
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
          label: 'Send Code',
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
// Step 1 — Verification code
// ─────────────────────────────────────────────────────────────────────────────

class _CodeFormContent extends StatelessWidget {
  final String email;
  final TextEditingController codeCtrl;
  final bool loading;
  final bool resendLoading;
  final int resendCountdown;
  final VoidCallback onSubmit;
  final VoidCallback onResend;
  final VoidCallback onBack;

  const _CodeFormContent({
    super.key,
    required this.email,
    required this.codeCtrl,
    required this.loading,
    required this.resendLoading,
    required this.resendCountdown,
    required this.onSubmit,
    required this.onResend,
    required this.onBack,
  });

  static String _fmtCountdown(int s) {
    final m = s ~/ 60;
    final sec = (s % 60).toString().padLeft(2, '0');
    return '$m:$sec';
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: IntrinsicHeight(
            child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),

        // ── Email badge ───────────────────────────────────────────────────────
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 120, height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.08),
                ),
              ),
              Container(
                width: 96, height: 96,
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
                child: const Icon(Icons.mark_email_unread_rounded,
                    color: Colors.white, size: 42),
              ),
            ],
          ),
        ).animate()
            .scale(
              begin: const Offset(0.4, 0.4),
              end: const Offset(1.0, 1.0),
              duration: 600.ms,
              curve: Curves.easeOutBack,
            )
            .fadeIn(duration: 400.ms),

        const SizedBox(height: 28),

        Text(
          'Check Your\nEmail',
          style: AppTypography.display.copyWith(
            color: const Color(0xFF1E1B4B),
            height: 1.1,
          ),
        ).animate()
            .fadeIn(duration: 400.ms, delay: 80.ms)
            .slideY(begin: 0.1, curve: Curves.easeOutCubic),

        const SizedBox(height: 10),

        RichText(
          text: TextSpan(
            text: "We sent a 6-digit code to ",
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            children: [
              TextSpan(
                text: email,
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 140.ms),

        const SizedBox(height: 24),

        _InputCard(
          child: AppTextField(
            controller: codeCtrl,
            hintText: '6-digit code',
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            prefixIcon: const Icon(Icons.pin_outlined,
                color: AppColors.primary, size: 20),
            onSubmitted: (_) => onSubmit(),
          ),
        ).animate()
            .fadeIn(duration: 400.ms, delay: 200.ms)
            .slideY(begin: 0.1, curve: Curves.easeOutCubic),

        const SizedBox(height: 20),

        AppButton(
          label: 'Verify Code',
          onPressed: onSubmit,
          isLoading: loading,
        ).animate()
            .fadeIn(duration: 400.ms, delay: 280.ms)
            .slideY(begin: 0.12, curve: Curves.easeOutCubic),

        const SizedBox(height: 20),

        // ── spam tip ──────────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.20),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded,
                  size: 18, color: Color(0xFFF59E0B)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Don't see it? Check your spam folder.",
                  style: AppTypography.caption.copyWith(
                    color: const Color(0xFF92400E),
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 360.ms),

        const Spacer(),

        Center(
          child: GestureDetector(
            onTap: (resendLoading || resendCountdown > 0) ? null : onResend,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: resendLoading
                  ? SizedBox(
                      key: const ValueKey('spinner'),
                      width: 18, height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary.withValues(alpha: 0.6),
                      ),
                    )
                  : resendCountdown > 0
                      ? Text(
                          key: const ValueKey('timer'),
                          'Resend code in ${_fmtCountdown(resendCountdown)}',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        )
                      : Text(
                          key: const ValueKey('resend'),
                          "Didn't receive it? Resend code",
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.primary,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.primary,
                          ),
                        ),
            ),
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 440.ms),

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
// Step 2 — New password
// ─────────────────────────────────────────────────────────────────────────────

class _NewPasswordContent extends StatelessWidget {
  final TextEditingController newPassCtrl;
  final TextEditingController confirmCtrl;
  final bool obscureNew;
  final bool obscureConfirm;
  final bool loading;
  final VoidCallback onToggleNew;
  final VoidCallback onToggleConfirm;
  final VoidCallback onSubmit;

  const _NewPasswordContent({
    super.key,
    required this.newPassCtrl,
    required this.confirmCtrl,
    required this.obscureNew,
    required this.obscureConfirm,
    required this.loading,
    required this.onToggleNew,
    required this.onToggleConfirm,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),

          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 120, height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.08),
                  ),
                ),
                Container(
                  width: 96, height: 96,
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
                  child: const Icon(Icons.lock_reset_rounded,
                      color: Colors.white, size: 42),
                ),
              ],
            ),
          ).animate()
              .scale(
                begin: const Offset(0.4, 0.4),
                end: const Offset(1.0, 1.0),
                duration: 600.ms,
                curve: Curves.easeOutBack,
              )
              .fadeIn(duration: 400.ms),

          const SizedBox(height: 28),

          Text(
            'Reset\nPassword',
            style: AppTypography.display.copyWith(
              color: const Color(0xFF1E1B4B),
              height: 1.1,
            ),
          ).animate()
              .fadeIn(duration: 400.ms, delay: 80.ms)
              .slideY(begin: 0.1, curve: Curves.easeOutCubic),

          const SizedBox(height: 8),

          Text(
            'Create a new password. Make it strong!',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 140.ms),

          const SizedBox(height: 24),

          _InputCard(
            child: AppTextField(
              controller: newPassCtrl,
              hintText: 'New password',
              obscureText: obscureNew,
              textInputAction: TextInputAction.next,
              prefixIcon: const Icon(Icons.lock_outline_rounded,
                  color: AppColors.primary, size: 20),
              suffixIcon: GestureDetector(
                onTap: onToggleNew,
                child: Icon(
                  obscureNew
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.textTertiary,
                  size: 20,
                ),
              ),
            ),
          ).animate()
              .fadeIn(duration: 400.ms, delay: 200.ms)
              .slideY(begin: 0.1, curve: Curves.easeOutCubic),

          const SizedBox(height: 12),

          _InputCard(
            child: AppTextField(
              controller: confirmCtrl,
              hintText: 'Confirm new password',
              obscureText: obscureConfirm,
              textInputAction: TextInputAction.done,
              prefixIcon: const Icon(Icons.lock_outline_rounded,
                  color: AppColors.primary, size: 20),
              suffixIcon: GestureDetector(
                onTap: onToggleConfirm,
                child: Icon(
                  obscureConfirm
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.textTertiary,
                  size: 20,
                ),
              ),
              onSubmitted: (_) => onSubmit(),
            ),
          ).animate()
              .fadeIn(duration: 400.ms, delay: 260.ms)
              .slideY(begin: 0.1, curve: Curves.easeOutCubic),

          const SizedBox(height: 24),

          AppButton(
            label: 'Reset Password',
            onPressed: onSubmit,
            isLoading: loading,
          ).animate()
              .fadeIn(duration: 400.ms, delay: 320.ms)
              .slideY(begin: 0.12, curve: Curves.easeOutCubic),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 3 — Success
// ─────────────────────────────────────────────────────────────────────────────

class _ResetSuccessView extends StatelessWidget {
  final VoidCallback onBack;

  const _ResetSuccessView({super.key, required this.onBack});

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
                  'Password Reset!',
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
          'All Done!',
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
          'Your password has been updated.\nYou can now sign in with your new password.',
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
