import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import 'app_shell_screen.dart';
import 'auth_welcome_screen.dart';
import 'onboarding_screen.dart';
import 'splash_screen.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1450), () {
      if (mounted) {
        setState(() => _showSplash = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();

    Widget child;
    if (_showSplash || !app.authReady) {
      child = const SplashScreen();
    } else if (!app.hasCompletedOnboarding) {
      child = const OnboardingScreen();
    } else if (!app.isAuthenticated) {
      child = const AuthWelcomeScreen();
    } else {
      child = const AppShellScreen();
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: KeyedSubtree(
        key: ValueKey(child.runtimeType),
        child: child,
      ),
    );
  }
}
