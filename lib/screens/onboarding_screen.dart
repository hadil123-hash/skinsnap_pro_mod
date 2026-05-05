import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../utils/constants.dart';
import '../widgets/beauty_ui.dart';
import '../widgets/app_logo_badge.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  List<_OnboardingData> _pages(BuildContext context) {
    final app = context.watch<AppProvider>();
    return [
      _OnboardingData(app.tr('onb_selfie_title'), app.tr('onb_selfie_subtitle'), Icons.face_retouching_natural_rounded, _MockupType.selfie),
      _OnboardingData(app.tr('onb_match_title'), app.tr('onb_match_subtitle'), Icons.favorite_rounded, _MockupType.match),
      _OnboardingData(app.tr('onb_safety_title'), app.tr('onb_safety_subtitle'), Icons.health_and_safety_rounded, _MockupType.safety),
      _OnboardingData(app.tr('onb_plan_title'), app.tr('onb_plan_subtitle'), Icons.spa_rounded, _MockupType.plan),
      _OnboardingData(app.tr('onb_routine_title'), app.tr('onb_routine_subtitle'), Icons.check_circle_rounded, _MockupType.routine),
    ];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await context.read<AppProvider>().completeOnboarding();
  }

  void _next(List<_OnboardingData> pages) {
    if (_index == pages.length - 1) {
      _finish();
      return;
    }
    _controller.nextPage(duration: const Duration(milliseconds: 320), curve: Curves.easeOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final pages = _pages(context);
    return Scaffold(
      body: BeautyGradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 10, 22, 0),
                child: Row(
                  children: [
                    Text(app.tr('app_name'), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                    const Spacer(),
                    TextButton(onPressed: _finish, child: Text(app.tr('skip'))),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: pages.length,
                  onPageChanged: (value) => setState(() => _index = value),
                  itemBuilder: (context, index) => _OnboardingPage(data: pages[index]),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        pages.length,
                        (dot) => AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          width: _index == dot ? 30 : 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            gradient: _index == dot ? AppColors.beautyGradient : null,
                            color: _index == dot ? null : AppColors.accent,
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    GradientButton(
                      label: _index == pages.length - 1 ? app.tr('start') : app.tr('next'),
                      icon: _index == pages.length - 1 ? Icons.check_rounded : Icons.arrow_forward_rounded,
                      onTap: () => _next(pages),
                    ),
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

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.data});

  final _OnboardingData data;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final phoneHeight = constraints.maxHeight < 610 ? 270.0 : 310.0;
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(26, 20, 26, 12),
          child: Column(
            children: [
              GradientText(
                data.title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, height: 1.12),
              ),
              const SizedBox(height: 8),
              Text(
                data.subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, height: 1.45, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .68), fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 24),
              PhoneMockup(height: phoneHeight, child: _Mockup(type: data.type, icon: data.icon)),
            ],
          ),
        );
      },
    );
  }
}

enum _MockupType { selfie, plan, safety, match, routine }

class _OnboardingData {
  const _OnboardingData(this.title, this.subtitle, this.icon, this.type);
  final String title;
  final String subtitle;
  final IconData icon;
  final _MockupType type;
}

class _Mockup extends StatelessWidget {
  const _Mockup({required this.type, required this.icon});

  final _MockupType type;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case _MockupType.selfie:
        return _Selfie(icon: icon);
      case _MockupType.plan:
        return const _Plan();
      case _MockupType.safety:
        return const _Safety();
      case _MockupType.match:
        return const _Match();
      case _MockupType.routine:
        return const _Routine();
    }
  }
}

class _Selfie extends StatelessWidget {
  const _Selfie({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.hotPink,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Vous êtes superbe 🔥', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          Container(
            width: 116,
            height: 116,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .16),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                'assets/images/app/app_icon.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text('Votre analyse de peau prendra quelques instants', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}

class _Plan extends StatelessWidget {
  const _Plan();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: const [
          _HeaderPill('Votre Routine Skincare Personnalisée'),
          SizedBox(height: 16),
          _MockupTitle('Matin ☀️'),
          _SmallStep('1. Nettoyant', 'CeraVe Gel Moussant'),
          _SmallStep('2. Hydratant', 'Avène Hydrance Light'),
          _SmallStep('3. SPF', 'Écran solaire'),
        ],
      ),
    );
  }
}

class _Safety extends StatelessWidget {
  const _Safety();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text('Ingredients Safety Score', style: TextStyle(color: AppColors.hotPink, fontWeight: FontWeight.w900)),
          SizedBox(height: 8),
          Text('16/20', style: TextStyle(color: AppColors.hotPink, fontSize: 36, fontWeight: FontWeight.w900)),
          SizedBox(height: 18),
          _ScoreRow('Pénalité forte', '0', AppColors.error),
          _ScoreRow('Pénalité moyenne', '1', AppColors.coral),
          _ScoreRow('Pénalité faible', '2', AppColors.warning),
          _ScoreRow('Pas de pénalité', '8', AppColors.success),
        ],
      ),
    );
  }
}

class _Match extends StatelessWidget {
  const _Match();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 8),
          const Icon(Icons.local_drink_rounded, size: 64, color: AppColors.success),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(color: const Color(0xFF007D3F), borderRadius: BorderRadius.circular(16)),
            child: const Text('😍 90% Match', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
          ),
          const SizedBox(height: 10),
          const Text('CeraVe Gel Moussant', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          const Text('Mixte, Grasse', style: TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _Routine extends StatelessWidget {
  const _Routine();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: const [
          Text('My Routine', style: TextStyle(color: AppColors.hotPink, fontSize: 18, fontWeight: FontWeight.w900)),
          SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [_DayBox('Lun', '10'), _DayBox('Mar', '11'), _DayBox('Jeu', '13', active: true)]),
          SizedBox(height: 12),
          _HeaderPill('J’ai Fait ✓'),
          SizedBox(height: 10),
          _SmallStep('Étape 1', 'Nettoyant'),
          _SmallStep('Étape 2', 'Hydratant'),
        ],
      ),
    );
  }
}

class _HeaderPill extends StatelessWidget {
  const _HeaderPill(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(gradient: AppColors.beautyGradient, borderRadius: BorderRadius.circular(18)),
      child: Text(text, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
    );
  }
}

class _MockupTitle extends StatelessWidget {
  const _MockupTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(alignment: Alignment.centerLeft, child: Text(text, style: const TextStyle(color: AppColors.hotPink, fontSize: 20, fontWeight: FontWeight.w900)));
  }
}

class _SmallStep extends StatelessWidget {
  const _SmallStep(this.title, this.subtitle);
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.hotPink.withValues(alpha: .14))),
      child: Row(children: [const Icon(Icons.spa_rounded, color: AppColors.hotPink), const SizedBox(width: 10), Expanded(child: Text('$title\n$subtitle', style: const TextStyle(fontWeight: FontWeight.w800)))]),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  const _ScoreRow(this.label, this.value, this.color);
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(children: [Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800))), CircleAvatar(radius: 15, backgroundColor: color, child: Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)))]),
    );
  }
}

class _DayBox extends StatelessWidget {
  const _DayBox(this.day, this.number, {this.active = false});
  final String day;
  final String number;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(color: active ? AppColors.hotPink : Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Text('$day\n$number', textAlign: TextAlign.center, style: TextStyle(color: active ? Colors.white : Colors.black, fontWeight: FontWeight.w900)),
    );
  }
}
