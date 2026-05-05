import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../services/sound_service.dart';
import '../utils/constants.dart';
import 'camera_screen.dart';
import 'dashboard_screen.dart';
import 'makeup_screen.dart';
import 'profile_screen.dart';
import 'routine_screen.dart';

class AppShellScreen extends StatefulWidget {
  const AppShellScreen({super.key});

  @override
  State<AppShellScreen> createState() => _AppShellScreenState();
}

class _AppShellScreenState extends State<AppShellScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final tr = context.watch<AppProvider>().tr;
    const pages = [
      DashboardScreen(),
      RoutineScreen(),
      MakeupScreen(),
      ProfileScreen(),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.surfaceDark
                : Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: AppColors.hotPink.withValues(alpha: .08)),
            boxShadow: [
              BoxShadow(
                color: AppColors.hotPink.withValues(alpha: .18),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            children: [
              _NavItem(
                label: tr('home'),
                icon: Icons.home_outlined,
                selectedIcon: Icons.home_rounded,
                selected: _index == 0,
                onTap: () { SoundService().playClick(); setState(() => _index = 0); },
              ),
              _NavItem(
                label: tr('routine'),
                icon: Icons.checklist_rounded,
                selectedIcon: Icons.checklist_rounded,
                selected: _index == 1,
                onTap: () { SoundService().playClick(); setState(() => _index = 1); },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: GestureDetector(
                  onTap: () { SoundService().feedbackSave(); Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const CameraScreen())); },
                  child: Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.beautyGradient,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.hotPink.withValues(alpha: .35),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.photo_camera_rounded, color: Colors.white),
                  ),
                ),
              ),
              _NavItem(
                label: tr('makeup'),
                icon: Icons.auto_awesome_outlined,
                selectedIcon: Icons.auto_awesome_rounded,
                selected: _index == 2,
                onTap: () { SoundService().playClick(); setState(() => _index = 2); },
              ),
              _NavItem(
                label: tr('profile'),
                icon: Icons.person_outline_rounded,
                selectedIcon: Icons.person_rounded,
                selected: _index == 3,
                onTap: () { SoundService().playClick(); setState(() => _index = 3); },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.hotPink : Colors.grey.shade500;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.blush : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(selected ? selectedIcon : icon, color: color, size: 22),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
