import 'package:flutter/material.dart';
import 'dart:async';
import 'home_page.dart';
import '../styles/app_styles.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack);
    _controller.forward();

    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
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
      backgroundColor: AppColors.background,
      body: Center(
        child: ScaleTransition(
          scale: _animation,
          child: FadeTransition(
            opacity: _animation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo tanpa background putih (menggunakan Image.asset langsung)
                Image.asset('assets/images/smp5logo.png', width: 180),
                const SizedBox(height: 20),
                const Text(
                  "ABSEN DULU",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    letterSpacing: 4,
                  ),
                ),
                const Text(
                  "SMP NEGERI 5 LUMAJANG",
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary, letterSpacing: 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
