import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../utils/constants.dart';
import '../widgets/beauty_ui.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class AuthWelcomeScreen extends StatelessWidget {
  const AuthWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tr = context.watch<AppProvider>().tr;
    final size = MediaQuery.of(context).size;
    final phoneHeight = size.height < 760 ? 320.0 : 390.0;

    return Scaffold(
      body: BeautyGradientBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 18),
                        Center(
                          child: PhoneMockup(
                            height: phoneHeight,
                            background: AppColors.hotPink,
                            child: Padding(
                              padding: const EdgeInsets.all(22),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(height: 28),
                                  Text(
                                    tr('app_name'),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 34,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Container(
                                    width: 132,
                                    height: 132,
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(34),
                                    ),
                                    child: Image.asset(
                                      'assets/images/app/app_icon.png',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(height: 34),
                                  Text(
                                    tr('tagline'),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        GradientText(
                          tr('welcome_title'),
                          style: const TextStyle(
                            fontSize: 30,
                            height: 1.15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          tr('welcome_subtitle'),
                          style: TextStyle(
                            height: 1.5,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .62),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 32),
                        GradientButton(
                          label: tr('create_account'),
                          icon: Icons.person_add_alt_1_rounded,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const RegisterScreen()),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _OutlineAuthButton(
                          label: tr('sign_in'),
                          icon: Icons.login_rounded,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _OutlineAuthButton extends StatelessWidget {
  const _OutlineAuthButton({required this.label, required this.icon, required this.onTap});

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.hotPink.withValues(alpha: .28)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.hotPink),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.hotPink,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
