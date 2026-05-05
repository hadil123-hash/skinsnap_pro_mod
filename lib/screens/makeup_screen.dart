import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/firestore_content.dart';
import '../providers/app_provider.dart';
import '../providers/beauty_plan_provider.dart';
import '../services/product_service.dart';
import '../services/sound_service.dart';
import '../utils/constants.dart';
import '../widgets/beauty_ui.dart';
import '../widgets/product_card.dart';
import 'camera_screen.dart';

class MakeupScreen extends StatefulWidget {
  const MakeupScreen({super.key, this.initialSkinType});

  final String? initialSkinType;

  @override
  State<MakeupScreen> createState() => _MakeupScreenState();
}

class _MakeupScreenState extends State<MakeupScreen> {
  final ProductService _service = ProductService();
  late String _skinType;
  bool _manualFilter = false;

  @override
  void initState() {
    super.initState();
    _skinType = _service.normalizeSkinType(widget.initialSkinType ?? 'mixte');
  }

  String _skinFromProvider(BuildContext context) {
    final plan = context.watch<BeautyPlanProvider>().currentPlan;
    if (plan == null || plan.skinType.trim().isEmpty) return _skinType;
    return _service.normalizeSkinType(plan.skinType);
  }

  Future<void> _add(ProductItem product) async {
    final app = context.read<AppProvider>();

    try {
      await _service.addProductToUserRoutine(product);
      await SoundService().feedbackSave();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(app.tr('added_routine')),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final fallbackSkin = _skinFromProvider(context);

    return Scaffold(
      body: BeautyGradientBackground(
        child: SafeArea(
          child: StreamBuilder<String>(
            stream: _service.watchCurrentUserSkinType(fallback: fallbackSkin),
            builder: (context, skinSnapshot) {
              final userSkin = skinSnapshot.data ?? fallbackSkin;
              final effectiveSkin = _manualFilter ? _skinType : userSkin;

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            app.tr('makeup_title'),
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: AppColors.hotPink,
                            ),
                          ),
                        ),
                        BeautyCircleIcon(
                          icon: Icons.face_retouching_natural_rounded,
                          size: 44,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CameraScreen()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${app.tr('makeup_analysis_hint')} ${_label(effectiveSkin)}.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .65),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ['mixte', 'grasse', 'seche', 'sensible', 'normale'].map((skin) {
                        final selected = effectiveSkin == skin;
                        return ChoiceChip(
                          label: Text(_label(skin)),
                          selected: selected,
                          selectedColor: AppColors.hotPink,
                          backgroundColor: AppColors.blush,
                          side: BorderSide.none,
                          labelStyle: TextStyle(
                            color: selected ? Colors.white : AppColors.hotPink,
                            fontWeight: FontWeight.w800,
                          ),
                          onSelected: (_) {
                            setState(() {
                              _skinType = skin;
                              _manualFilter = true;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _manualFilter = false;
                          _skinType = userSkin;
                        });
                      },
                      icon: const Icon(Icons.person_rounded),
                      label: const Text('Utiliser le profil du compte connecté'),
                    ),
                    const SizedBox(height: 18),
                    BeautyCard(
                      padding: EdgeInsets.zero,
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
                            child: Text(
                              app.tr('makeup_title'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _LookStep('1', 'Préparation peau', 'Hydratant léger avant maquillage'),
                                _LookStep('2', 'Teint', 'Fond de teint adapté au type de peau'),
                                _LookStep('3', 'Joues', 'Blush pour effet bonne mine'),
                                _LookStep('4', 'Lèvres', 'Gloss naturel'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      app.tr('makeup_products'),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 12),
                    StreamBuilder<List<ProductItem>>(
                      stream: _service.watchRecommendedProducts(
                        skinType: effectiveSkin,
                        type: 'makeup',
                        limit: 20,
                      ),
                      builder: (context, snapshot) {
                        final products = snapshot.data ?? const <ProductItem>[];

                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const BeautyCard(
                            child: Center(
                              child: CircularProgressIndicator(color: AppColors.hotPink),
                            ),
                          );
                        }

                        if (products.isEmpty) {
                          return BeautyCard(
                            child: Text(
                              app.tr('empty_products_firestore'),
                              style: const TextStyle(fontWeight: FontWeight.w800),
                            ),
                          );
                        }

                        return Column(
                          children: products
                              .map(
                                (product) => ProductCard(
                              product: product,
                              onAddToRoutine: () => _add(product),
                            ),
                          )
                              .toList(),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String _label(String value) {
    switch (_service.normalizeSkinType(value)) {
      case 'grasse':
        return 'Grasse';
      case 'seche':
        return 'Sèche';
      case 'sensible':
        return 'Sensible';
      case 'normale':
        return 'Normale';
      default:
        return 'Mixte';
    }
  }
}

class _LookStep extends StatelessWidget {
  const _LookStep(this.number, this.title, this.subtitle);

  final String number;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.blush,
            child: Text(
              number,
              style: const TextStyle(
                color: AppColors.hotPink,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                Text(subtitle, style: TextStyle(color: Colors.grey.shade700)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
