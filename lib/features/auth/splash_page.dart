import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/bootstrap.dart';
import '../../core/theme.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _slide;
  late final Animation<double> _textFade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _slide = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
    );

    _textFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
    );

    _controller.forward();
    Timer(const Duration(milliseconds: 3200), _navigate);
  }

  Future<void> _navigate() async {
    if (!mounted) return;
    if (!AppBootstrap.firebaseEnabled) {
      context.go('/p/home');
      return;
    }
    final user = FirebaseAuth.instance.currentUser;
    if (!mounted) return;
    context.go(user == null ? '/login' : '/home');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final illustrationWidth = size.width * 0.9;
    final illustrationHeight = illustrationWidth * (196 / 337);

    // Illustration rises from below the screen into view
    final startTop = size.height * 0.78;
    final endTop = size.height * 0.34;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final illustrationTop = startTop + (endTop - startTop) * _slide.value;
          final textOpacity = _textFade.value.clamp(0.0, 1.0);

          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: (size.width - illustrationWidth) / 2,
                top: illustrationTop,
                width: illustrationWidth,
                height: illustrationHeight,
                child: Image.asset(
                  'assets/images/splash.png',
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.medium,
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: illustrationTop - 58,
                child: Opacity(
                  opacity: textOpacity,
                  child: Text(
                    'abilify',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 44,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 24,
                right: 24,
                top: illustrationTop + illustrationHeight + 4,
                child: Opacity(
                  opacity: textOpacity,
                  child: Text(
                    'support that grows with your child',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.caveat(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                      height: 1.35,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
