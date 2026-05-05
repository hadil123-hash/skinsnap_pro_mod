import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/beauty_plan.dart';
import '../models/firestore_content.dart';
import '../models/makeup_recommendation.dart';
import '../models/skin_analysis_result.dart';
import '../providers/app_provider.dart';
import '../providers/beauty_plan_provider.dart';
import '../services/beauty_advisor_service.dart';
import '../services/product_service.dart';
import '../services/sound_service.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';
import '../widgets/beauty_ui.dart';
import '../widgets/path_image.dart';
import '../widgets/product_card.dart';
import 'camera_screen.dart';
import 'makeup_screen.dart';
import 'product_match_screen.dart';
import 'routine_screen.dart';


String _skinKeyFromPlan(BeautyPlan plan) {
  final value = plan.skinType.toLowerCase();
  if (value.contains('grasse') || value.contains('oily') || value.contains('دهنية')) return 'grasse';
  if (value.contains('seche') || value.contains('sèche') || value.contains('dry') || value.contains('جافة')) return 'seche';
  if (value.contains('sensible') || value.contains('sensitive') || value.contains('حساسة')) return 'sensible';
  if (value.contains('normale') || value.contains('normal') || value.contains('عادية')) return 'normale';
  return 'mixte';
}

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key, required this.result});

  final SkinAnalysisResult result;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _saved = false;
  bool _routineApplied = false;

  Future<void> _save() async {
    final app = context.read<AppProvider>();
    await StorageService().saveResult(widget.result);
    SoundService().configure(sound: app.soundOn, vibration: app.vibrationOn);
    await SoundService().feedbackSave();
    if (!mounted) return;
    setState(() => _saved = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Résultat sauvegardé'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  Future<void> _applyRoutine() async {
    final app = context.read<AppProvider>();
    final beauty = context.read<BeautyPlanProvider>();
    final productService = ProductService();

    SoundService().configure(sound: app.soundOn, vibration: app.vibrationOn);

    final plan = await beauty.adoptFromResult(
      result: widget.result,
      locale: app.locale,
    );

    await productService.saveCurrentUserSkinProfile(
      skinType: _skinKeyFromPlan(plan),
      concerns: plan.concerns,
      source: 'skin_scan',
    );

    await SoundService().feedbackSuccess();

    if (!mounted) return;
    setState(() => _routineApplied = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Routine appliquée et profil peau sauvegardé'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _startNewAnalysis() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const CameraScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final plan = context.watch<BeautyPlanProvider>().previewPlan(
      result: widget.result,
      locale: app.locale,
    );
    final makeup = BeautyAdvisorService().buildMakeupRecommendation(
      locale: app.locale,
      eventType: 'daily',
      style: 'natural',
      plan: plan,
    );
    final skinKey = _skinKeyFromPlan(plan);

    return Scaffold(
      body: BeautyGradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    BeautyCircleIcon(
                      icon: Icons.arrow_back_ios_new_rounded,
                      size: 44,
                      onTap: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    BeautyCircleIcon(
                      icon: _saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                      size: 44,
                      onTap: _saved ? null : _save,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const GradientText(
                  'Votre analyse de peau est prête',
                  style: TextStyle(fontSize: 32, height: 1.15, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 20),
                _ScoreHero(result: widget.result),
                const SizedBox(height: 22),
                _PersonalPlanCard(plan: plan),
                const SizedBox(height: 18),
                _ProductsCard(plan: plan),
                const SizedBox(height: 18),
                _MakeupAdviceCard(plan: plan, recommendation: makeup, skinKey: skinKey),
                const SizedBox(height: 18),
                _TechnicalCard(result: widget.result),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: GradientButton(
                        label: _routineApplied ? 'Routine ajoutée' : '+ Ajouter à mes routines',
                        icon: Icons.spa_rounded,
                        onTap: _routineApplied ? null : _applyRoutine,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _OutlineAction(
                        label: 'Voir routine',
                        icon: Icons.checklist_rounded,
                        onTap: () async {
                          if (!_routineApplied) {
                            await _applyRoutine();
                          }
                          if (!mounted) return;
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const RoutineScreen()),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _OutlineAction(
                        label: 'Nouveau scan',
                        icon: Icons.refresh_rounded,
                        onTap: _startNewAnalysis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScoreHero extends StatelessWidget {
  const _ScoreHero({required this.result});
  final SkinAnalysisResult result;

  @override
  Widget build(BuildContext context) {
    final score = result.skinScore.clamp(0, 100);
    return BeautyCard(
      padding: const EdgeInsets.all(0),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                child: SizedBox(
                  width: double.infinity,
                  height: 290,
                  child: PathImage(
                    path: result.imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.blush,
                      child: const Icon(Icons.face_retouching_natural_rounded,
                          size: 96, color: AppColors.hotPink),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 18,
                right: 18,
                bottom: -34,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    color: score >= 75 ? const Color(0xFF007D3F) : AppColors.hotPink,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .18),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Text(
                    '😍 $score% Match avec votre peau !',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 46),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Row(
              children: [
                _Metric('Visage', result.faceDetected ? 'Oui' : 'Non', AppColors.info),
                _Metric('Selfie', result.segmentationDone ? 'OK' : '-', AppColors.success),
                _Metric('Langue', result.detectedLanguage?.toUpperCase() ?? '-', AppColors.orange),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric(this.label, this.value, this.color);
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .10),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 3),
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}

class _PersonalPlanCard extends StatelessWidget {
  const _PersonalPlanCard({required this.plan});
  final BeautyPlan plan;

  @override
  Widget build(BuildContext context) {
    return BeautyCard(
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: const BoxDecoration(
              gradient: AppColors.beautyGradient,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: const Text(
              'Votre Routine Skincare Personnalisée',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(plan.skinType,
                    style: const TextStyle(color: AppColors.hotPink, fontSize: 24, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                Text(plan.summary, style: const TextStyle(height: 1.45, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                const Text('Matin ☀️', style: TextStyle(color: AppColors.hotPink, fontSize: 20, fontWeight: FontWeight.w900)),
                ...plan.morningSteps.take(3).map((step) => _PlanStep(step: step)),
                const SizedBox(height: 12),
                const Text('Soir 🌙', style: TextStyle(color: AppColors.hotPink, fontSize: 20, fontWeight: FontWeight.w900)),
                ...plan.eveningSteps.take(3).map((step) => _PlanStep(step: step)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanStep extends StatelessWidget {
  const _PlanStep({required this.step});
  final RoutineStep step;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: '${step.title}: ', style: const TextStyle(fontWeight: FontWeight.w900)),
                  TextSpan(text: step.productName),
                ],
              ),
              style: const TextStyle(height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductsCard extends StatelessWidget {
  const _ProductsCard({required this.plan});
  final BeautyPlan plan;

  String get _skinKey {
    final value = plan.skinType.toLowerCase();
    if (value.contains('grasse') || value.contains('oily')) return 'grasse';
    if (value.contains('seche') || value.contains('dry')) return 'seche';
    if (value.contains('sensible') || value.contains('sensitive')) return 'sensible';
    if (value.contains('normale') || value.contains('normal')) return 'normale';
    return 'mixte';
  }

  Future<void> _addToRoutine(BuildContext context, ProductItem product) async {
    try {
      await ProductService().addProductToUserRoutine(product);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} ajoute a My Routine'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BeautyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Meilleurs matchs produits',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ProductMatchScreen(initialSkinType: _skinKey)),
                ),
                child: const Text('Voir >'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FutureBuilder<List<ProductItem>>(
            future: ProductService().getSkincareProducts(skinType: _skinKey, limit: 4),
            builder: (context, snapshot) {
              final loading = snapshot.connectionState == ConnectionState.waiting;
              final products = snapshot.data ?? const <ProductItem>[];
              if (loading) {
                return const Padding(
                  padding: EdgeInsets.all(18),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (products.isEmpty) {
                return Text(
                  'Aucun produit trouve pour ${plan.skinType}. Verifiez les donnees integrees de l application.',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .65)),
                );
              }
              return Column(
                children: products
                    .map((product) => ProductCard(
                  product: product,
                  onAddToRoutine: () => _addToRoutine(context, product),
                ))
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 6),
          Text(
            'Les images viennent gratuitement du dossier assets/images de l application.',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .55), fontSize: 12),
          ),
        ],
      ),
    );
  }
}


class _MakeupAdviceCard extends StatelessWidget {
  const _MakeupAdviceCard({required this.plan, required this.recommendation, required this.skinKey});

  final BeautyPlan plan;
  final MakeupRecommendation recommendation;
  final String skinKey;

  Future<void> _addToRoutine(BuildContext context, ProductItem product) async {
    try {
      await ProductService().addProductToUserRoutine(product);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} ajoute a My Routine'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BeautyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Makeup recommandé après votre photo',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => MakeupScreen(initialSkinType: skinKey)),
                ),
                child: const Text('Voir >'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: AppColors.beautyGradient,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recommendation.lookName,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Text(
                  recommendation.overview,
                  style: const TextStyle(color: Colors.white, height: 1.35, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _MakeupLine(title: 'Préparation', value: recommendation.skinPrep),
          _MakeupLine(title: 'Teint', value: recommendation.complexion),
          _MakeupLine(title: 'Yeux', value: recommendation.eyes),
          _MakeupLine(title: 'Lèvres', value: recommendation.lips),
          const SizedBox(height: 14),
          FutureBuilder<List<ProductItem>>(
            future: ProductService().getMakeupProducts(skinType: skinKey, limit: 3),
            builder: (context, snapshot) {
              final products = snapshot.data ?? const <ProductItem>[];
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (products.isEmpty) {
                return Text(
                  'Aucun produit makeup disponible pour ${plan.skinType}.',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .65)),
                );
              }
              return Column(
                children: products
                    .map((product) => ProductCard(
                  product: product,
                  onAddToRoutine: () => _addToRoutine(context, product),
                ))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MakeupLine extends StatelessWidget {
  const _MakeupLine({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome_rounded, color: AppColors.hotPink, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: '$title: ', style: const TextStyle(fontWeight: FontWeight.w900)),
                  TextSpan(text: value),
                ],
              ),
              style: const TextStyle(height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

class _TechnicalCard extends StatelessWidget {
  const _TechnicalCard({required this.result});
  final SkinAnalysisResult result;

  @override
  Widget build(BuildContext context) {
    return BeautyCard(
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          title: const Text('Détails techniques ML Kit',
              style: TextStyle(fontWeight: FontWeight.w900)),
          children: [
            const SizedBox(height: 8),
            _TechLine('Face Detection', result.faceDetected ? 'Visage détecté' : 'Aucun visage'),
            _TechLine('Image Labeling', result.imageLabels.take(3).map((e) => e.label).join(', ')),
            _TechLine('Selfie Segmentation', result.segmentationDone ? 'Réussie' : 'Non réalisée'),
            _TechLine('Language ID', result.detectedLanguage ?? '-'),
          ],
        ),
      ),
    );
  }
}

class _TechLine extends StatelessWidget {
  const _TechLine(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w900))),
          const SizedBox(width: 12),
          Expanded(child: Text(value.isEmpty ? '-' : value, textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}

class _OutlineAction extends StatelessWidget {
  const _OutlineAction({required this.label, required this.icon, required this.onTap});
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.hotPink.withValues(alpha: .24)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.hotPink, size: 20),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: AppColors.hotPink, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }
}
