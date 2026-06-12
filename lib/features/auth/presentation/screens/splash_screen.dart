import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.asset(
      'assets/videos/splash.mp4',
    )
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
        _controller.setLooping(true);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [

          if (_controller.value.isInitialized)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: VideoPlayer(_controller),
              ),
            ),

          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.white.withOpacity(.15),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [

                const Spacer(),

                Text(
                  "dermiq",
                  style: TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.w300,
                    color: Color(0xFF432A8A),
                    letterSpacing: -2,
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  "Smart skincare, just for you.",
                  style: TextStyle(
                    fontSize: 22,
                    color: Color(0xFF432A8A),
                  ),
                ),

                const SizedBox(height: 8),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    "AI-powered skin insights for healthier, happier skin.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF5A4A8A),
                    ),
                  ),
                ),

                const SizedBox(height: 80),

                GestureDetector(
                  onTap: () {

                    Navigator.pushReplacementNamed(
                      context,
                      '/onboarding',
                    );

                  },
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF8A6DFF),
                          Color(0xFFA88BFF),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF8A6DFF)
                              .withOpacity(.4),
                          blurRadius: 30,
                        )
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                ),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }
}