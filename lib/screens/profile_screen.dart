import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../utils/constants.dart';
import '../widgets/beauty_ui.dart';
import 'about_screen.dart';
import 'favorites_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    return Scaffold(
      body: BeautyGradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GradientText(app.tr('profile_title'), style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900)),
                const SizedBox(height: 22),
                BeautyCard(
                  child: Column(
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: const BoxDecoration(gradient: AppColors.beautyGradient, shape: BoxShape.circle),
                        child: Center(
                          child: Text(app.userInitials, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(app.userName.isEmpty ? 'SkinSnap User' : app.userName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 4),
                      Text(app.userEmail, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .58), fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _ProfileTile(
                  icon: Icons.favorite_rounded,
                  title: app.tr('favorites'),
                  subtitle: app.tr('empty_favorites_hint'),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesScreen())),
                ),
                _ProfileTile(
                  icon: Icons.history_rounded,
                  title: app.tr('history_title'),
                  subtitle: app.tr('history_subtitle'),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen())),
                ),
                _ProfileTile(
                  icon: Icons.settings_rounded,
                  title: app.tr('settings'),
                  subtitle: app.tr('settings_subtitle'),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                ),
                _ProfileTile(
                  icon: Icons.info_outline_rounded,
                  title: app.tr('about'),
                  subtitle: app.tr('about_subtitle'),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen())),
                ),
                const SizedBox(height: 18),
                GradientButton(
                  label: app.tr('sign_out'),
                  icon: Icons.logout_rounded,
                  onTap: () => context.read<AppProvider>().signOut(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({required this.icon, required this.title, required this.subtitle, required this.onTap});

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: BeautyCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(gradient: AppColors.beautyGradient, shape: BoxShape.circle),
                child: Icon(icon, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 3),
                    Text(subtitle, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .58))),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.hotPink),
            ],
          ),
        ),
      ),
    );
  }
}
