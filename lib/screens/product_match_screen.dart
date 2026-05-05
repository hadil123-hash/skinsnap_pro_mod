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

class ProductMatchScreen extends StatefulWidget {
  const ProductMatchScreen({
    super.key,
    this.initialSkinType,
    this.productType = 'skincare',
  });

  final String? initialSkinType;
  final String productType;

  @override
  State<ProductMatchScreen> createState() => _ProductMatchScreenState();
}

class _ProductMatchScreenState extends State<ProductMatchScreen> {
  final ProductService _service = ProductService();
  late String _skinType;
  late String _type;
  bool _manualFilter = false;

  @override
  void initState() {
    super.initState();
    _skinType = _service.normalizeSkinType(widget.initialSkinType ?? 'mixte');
    _type = widget.productType.toLowerCase().trim().isEmpty
        ? 'skincare'
        : widget.productType.toLowerCase().trim();
  }

  String _skinFromProvider(BuildContext context) {
    final plan = context.watch<BeautyPlanProvider>().currentPlan;
    if (plan == null || plan.skinType.trim().isEmpty) return _skinType;
    return _service.normalizeSkinType(plan.skinType);
  }

  Future<void> _addToRoutine(ProductItem product) async {
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

              return StreamBuilder<List<ProductItem>>(
                stream: _service.watchRecommendedProducts(
                  skinType: effectiveSkin,
                  type: _type,
                  limit: 30,
                ),
                builder: (context, productSnapshot) {
                  final loading = productSnapshot.connectionState == ConnectionState.waiting;
                  final products = productSnapshot.data ?? const <ProductItem>[];

                  return SingleChildScrollView(
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
                              icon: Icons.person_rounded,
                              size: 44,
                              onTap: () {},
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        GradientText(
                          _type == 'makeup'
                              ? app.tr('makeup_title')
                              : app.tr('onb_match_title'),
                          style: const TextStyle(
                            fontSize: 32,
                            height: 1.14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Profil utilisé pour ce compte : ${_labelSkin(effectiveSkin)}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .65),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _Filters(
                          skinType: effectiveSkin,
                          type: _type,
                          onSkinChanged: (value) {
                            setState(() {
                              _skinType = value;
                              _manualFilter = true;
                            });
                          },
                          onTypeChanged: (value) {
                            setState(() => _type = value);
                          },
                          onUseAccountProfile: () {
                            setState(() {
                              _manualFilter = false;
                              _skinType = userSkin;
                            });
                          },
                        ),
                        const SizedBox(height: 22),
                        if (loading)
                          const BeautyCard(
                            child: Center(
                              child: CircularProgressIndicator(color: AppColors.hotPink),
                            ),
                          )
                        else if (products.isEmpty)
                          BeautyCard(
                            child: Text(
                              app.tr('empty_products_firestore'),
                              style: const TextStyle(fontWeight: FontWeight.w800),
                            ),
                          )
                        else ...[
                            Text(
                              app.tr('compatible_products'),
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 12),
                            ...products.map(
                                  (product) => ProductCard(
                                product: product,
                                onAddToRoutine: () => _addToRoutine(product),
                              ),
                            ),
                          ],
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  String _labelSkin(String value) {
    switch (_service.normalizeSkinType(value)) {
      case 'grasse':
        return 'Peau grasse';
      case 'seche':
        return 'Peau sèche';
      case 'sensible':
        return 'Peau sensible';
      case 'normale':
        return 'Peau normale';
      default:
        return 'Peau mixte';
    }
  }
}

class _Filters extends StatelessWidget {
  const _Filters({
    required this.skinType,
    required this.type,
    required this.onSkinChanged,
    required this.onTypeChanged,
    required this.onUseAccountProfile,
  });

  final String skinType;
  final String type;
  final ValueChanged<String> onSkinChanged;
  final ValueChanged<String> onTypeChanged;
  final VoidCallback onUseAccountProfile;

  @override
  Widget build(BuildContext context) {
    return BeautyCard(
      padding: const EdgeInsets.all(12),
      radius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.watch<AppProvider>().tr('filter_recommendations'),
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              TextButton(
                onPressed: onUseAccountProfile,
                child: const Text('Profil compte'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['mixte', 'grasse', 'seche', 'sensible', 'normale']
                .map(
                  (item) => ChoiceChip(
                selected: skinType == item,
                label: Text(item),
                selectedColor: AppColors.hotPink,
                backgroundColor: AppColors.blush,
                side: BorderSide.none,
                labelStyle: TextStyle(
                  color: skinType == item ? Colors.white : AppColors.hotPink,
                  fontWeight: FontWeight.w900,
                ),
                onSelected: (_) => onSkinChanged(item),
              ),
            )
                .toList(),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                selected: type == 'skincare',
                label: const Text('Skincare'),
                selectedColor: AppColors.hotPink,
                backgroundColor: AppColors.blush,
                side: BorderSide.none,
                labelStyle: TextStyle(
                  color: type == 'skincare' ? Colors.white : AppColors.hotPink,
                  fontWeight: FontWeight.w900,
                ),
                onSelected: (_) => onTypeChanged('skincare'),
              ),
              ChoiceChip(
                selected: type == 'makeup',
                label: const Text('Makeup'),
                selectedColor: AppColors.hotPink,
                backgroundColor: AppColors.blush,
                side: BorderSide.none,
                labelStyle: TextStyle(
                  color: type == 'makeup' ? Colors.white : AppColors.hotPink,
                  fontWeight: FontWeight.w900,
                ),
                onSelected: (_) => onTypeChanged('makeup'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
