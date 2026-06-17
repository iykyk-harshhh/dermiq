import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/preferences_service.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {

  late VideoPlayerController _controller;
  bool _nativeSplashRemoved = false;

  /// Drops the held OS launch screen — called once the video is ready (so the
  /// motion graphic is already playing when revealed), and idempotently guarded
  /// so the error path and safety timeout can't double-remove.
  void _revealApp() {
    if (_nativeSplashRemoved) return;
    _nativeSplashRemoved = true;
    FlutterNativeSplash.remove();
  }

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.asset('assets/videos/splash.mp4');
    _controller.initialize().then((_) {
      if (!mounted) return _revealApp();
      setState(() {});
      _controller.play();
      _controller.setLooping(true);
      _revealApp();
    }).catchError((_) {
      // Asset/codec failure — fall back to the static branded backdrop so the
      // very first screen never crashes or shows a blank void.
      if (mounted) setState(() {});
      _revealApp();
    });

    // Hold the OS launch screen (the logo) until the video is ready, so the app
    // reveals straight into the playing motion graphic — no bare-backdrop gap.
    // Safety net: never hold longer than 5s even if the video stalls, so we
    // never appear frozen (we'd fall back to the static branded backdrop).
    Future.delayed(const Duration(milliseconds: 5000), _revealApp);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Route straight to the correct destination so the router guard never has to
  /// redirect mid-navigation: signed-in → Home, onboarded-but-logged-out →
  /// Login, first launch → Onboarding.
  void _onGetStarted() {
    final loggedIn = ref.read(authStateProvider) != null;
    if (loggedIn) {
      context.go('/home');
    } else if (!PreferencesService.onboardingSeen) {
      context.go('/onboarding');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [

          // Branded backdrop — always painted, sits under the video. If the
          // video fails to load it becomes the (intentional) background.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF2F216F),
                  Color(0xFF6C4BFF),
                  Color(0xFF8A6DFF),
                ],
              ),
            ),
          ),

          // The motion-graphics video crossfades in over the matching gradient
          // backdrop, so there's never a hard "pop" when it becomes ready.
          AnimatedOpacity(
            opacity: _controller.value.isInitialized ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            child: _controller.value.isInitialized
                ? FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller.value.size.width,
                      height: _controller.value.size.height,
                      child: VideoPlayer(_controller),
                    ),
                  )
                : const SizedBox.expand(),
          ),

          // Soft scrim so the text stays legible over the motion graphics —
          // transparent at the face, deepening toward the bottom CTA.
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  const Color(0xFFF5F1FF).withValues(alpha: 0.0),
                  const Color(0xFFF5F1FF).withValues(alpha: 0.55),
                  const Color(0xFFF5F1FF).withValues(alpha: 0.85),
                ],
                stops: const [0.0, 0.45, 0.78, 1.0],
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  const Spacer(flex: 7),

                  // App name
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFEFE8FF), // soft white-lilac highlight
                        Color(0xFFB084FF), // light purple
                        Color(0xFF8A6DFF), // brand purple
                      ],
                      stops: [0.0, 0.5, 1.0],
                    ).createShader(bounds),
                    child: Text(
                    "dermiq",
                    style: GoogleFonts.poppins(
                      fontSize: 60,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -1.5,
                      height: 1.0,
                      shadows: [
                        // Soft purple glow so the wordmark lifts off the
                        // motion-graphics background and reads instantly.
                        Shadow(
                          color: const Color(0xFF2F216F).withValues(alpha: 0.55),
                          blurRadius: 24,
                          offset: const Offset(0, 4),
                        ),
                        Shadow(
                          color: const Color(0xFF8A6DFF).withValues(alpha: 0.6),
                          blurRadius: 40,
                        ),
                      ],
                    ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Tagline
                  Text(
                    "Smart skincare, just for you.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFE9DEFF),
                      letterSpacing: 0.2,
                      shadows: [
                        Shadow(
                          color: const Color(0xFF2F216F).withValues(alpha: 0.6),
                          blurRadius: 16,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Supporting line
                  Text(
                    "AI-powered skin insights for\nhealthier, happier skin.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                      // Deep readable purple — the previous light lilac washed
                      // out against the bright bottom of the splash.
                      color: const Color(0xFF3F2E86),
                      shadows: [
                        Shadow(
                          color: Colors.white.withValues(alpha: 0.6),
                          blurRadius: 8,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Get Started pill CTA
                  GestureDetector(
                    onTap: _onGetStarted,
                    child: Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 320),
                      height: 64,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                        gradient: const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Color(0xFF8A6DFF),
                            Color(0xFFB084FF),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8A6DFF).withValues(alpha: 0.45),
                            blurRadius: 28,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Get Started",
                            style: GoogleFonts.inter(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(flex: 1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}