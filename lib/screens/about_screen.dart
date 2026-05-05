import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../utils/constants.dart';
import '../widgets/beauty_ui.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final features = [
      _AboutFeature(Icons.face_retouching_natural_rounded, app.tr('about_face_title'), app.tr('about_face_body')),
      _AboutFeature(Icons.qr_code_scanner_rounded, app.tr('about_product_title'), app.tr('about_product_body')),
      _AboutFeature(Icons.spa_rounded, app.tr('about_routine_title'), app.tr('about_routine_body')),
      _AboutFeature(Icons.auto_awesome_rounded, app.tr('about_language_title'), app.tr('about_language_body')),
    ];

    return Scaffold(
      body: BeautyGradientBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
            children: [
              Row(
                children: [
                  BeautyCircleIcon(
                    icon: Icons.arrow_back_ios_new_rounded,
                    size: 44,
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: GradientText(
                      app.tr('about'),
                      style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              BeautyCard(
                color: AppColors.hotPink,
                child: Column(
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: .18), shape: BoxShape.circle),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/app/app_icon.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text('SkinSnap', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 8),
                    Text(app.tr('about_intro'), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, height: 1.45, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: .16), borderRadius: BorderRadius.circular(999)),
                      child: const Text('Version 1.1.0', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              ...features.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: BeautyCard(
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: const BoxDecoration(gradient: AppColors.beautyGradient, shape: BoxShape.circle),
                            child: Icon(item.icon, color: Colors.white),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                                const SizedBox(height: 4),
                                Text(item.body, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .66), height: 1.35)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
              const SizedBox(height: 10),
              BeautyCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Technologies', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 10),
                    _TechLine(icon: Icons.flutter_dash_rounded, label: 'Flutter / Dart'),
                    _TechLine(icon: Icons.local_fire_department_rounded, label: 'Firebase Authentication et Cloud Firestore'),
                    _TechLine(icon: Icons.qr_code_scanner_rounded, label: 'Google ML Kit Barcode Scanning'),
                    _TechLine(icon: Icons.public_rounded, label: 'Open Beauty Facts API'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AboutFeature {
  const _AboutFeature(this.icon, this.title, this.body);
  final IconData icon;
  final String title;
  final String body;
}

class _TechLine extends StatelessWidget {
  const _TechLine({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: AppColors.hotPink, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800))),
        ],
      ),
    );
  }
}
