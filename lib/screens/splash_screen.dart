import 'package:flutter/material.dart';

import '../utils/constants.dart';
import '../widgets/beauty_ui.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: BeautyGradientBackground(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SplashLogo(),
              SizedBox(height: 20),
              GradientText('SkinSnap', style: TextStyle(fontSize: 38, fontWeight: FontWeight.w900)),
              SizedBox(height: 8),
              Text(
                'Votre peau, votre routine, vos meilleurs matchs.',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SplashLogo extends StatelessWidget {
  const _SplashLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 112,
      height: 112,
      padding: const EdgeInsets.all(6),
      decoration: const BoxDecoration(
        gradient: AppColors.beautyGradient,
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/app/app_icon.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
