import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/firestore_content.dart';
import '../providers/app_provider.dart';
import '../services/firestore_content_service.dart';
import '../services/product_service.dart';
import '../services/sound_service.dart';
import '../utils/constants.dart';
import '../widgets/beauty_ui.dart';
import '../widgets/product_card.dart';
import 'beauty_assistant_screen.dart';
import 'ingredient_safety_screen.dart';
import 'product_match_screen.dart';

class CategoryListScreen extends StatefulWidget {
  const CategoryListScreen({super.key, this.initialCategoryId});

  final String? initialCategoryId;

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  final ProductService _productService = ProductService();
  final FirestoreContentService _content = FirestoreContentService();
  late String? _selectedId = widget.initialCategoryId;

  Future<void> _add(ProductItem product) async {
    final app = context.read<AppProvider>();
    await _productService.addProductToUserRoutine(product);
    await SoundService().feedbackSave();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(app.tr('added_routine')), backgroundColor: AppColors.success),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();

    return Scaffold(
      body: BeautyGradientBackground(
        child: SafeArea(
          child: StreamBuilder<List<AppCategoryItem>>(
            stream: _content.categories(),
            builder: (context, categorySnapshot) {
              final categories = categorySnapshot.data ?? const <AppCategoryItem>[];
              final selectedId = _selectedId ?? (categories.isNotEmpty ? categories.first.id : 'skincare');
              final productType = _productTypeFor(selectedId);

              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                children: [
                  Row(
                    children: [
                      BeautyCircleIcon(icon: Icons.arrow_back_ios_new_rounded, size: 44, onTap: () => Navigator.pop(context)),
                      const SizedBox(width: 12),
                      Expanded(child: Text(app.tr('categories'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900))),
                    ],
                  ),
                  const SizedBox(height: 22),
                  if (categorySnapshot.connectionState == ConnectionState.waiting)
                    const BeautyCard(child: Center(child: CircularProgressIndicator(color: AppColors.hotPink)))
                  else if (categories.isEmpty)
                    BeautyCard(child: Text(app.tr('empty_categories_firestore'), style: const TextStyle(fontWeight: FontWeight.w800)))
                  else
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: categories.map((item) {
                        final selected = selectedId == item.id;
                        return ChoiceChip(
                          selected: selected,
                          label: Text(_categoryTitle(app, item.id, item.title)),
                          avatar: Icon(item.icon, size: 18, color: selected ? Colors.white : item.color),
                          onSelected: (_) async {
                            await SoundService().playClick();
                            setState(() => _selectedId = item.id);
                          },
                          selectedColor: AppColors.hotPink,
                          backgroundColor: AppColors.blush,
                          side: BorderSide.none,
                          labelStyle: TextStyle(color: selected ? Colors.white : AppColors.hotPink, fontWeight: FontWeight.w900),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 22),
                  _CategoryHero(
                    item: _selectedCategory(categories, selectedId),
                    fallbackId: selectedId,
                    title: _categoryTitle(app, selectedId, ''),
                  ),
                  const SizedBox(height: 18),
                  if (selectedId == 'bien_etre')
                    _AdviceCard(
                      title: _categoryTitle(app, 'bien_etre', 'Bien être'),
                      message: app.tr('wellness_advice'),
                      actionLabel: app.tr('assistant'),
                      icon: Icons.health_and_safety_rounded,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BeautyAssistantScreen())),
                    )
                  else if (selectedId == 'coiffure')
                    _AdviceCard(
                      title: _categoryTitle(app, 'coiffure', 'Coiffure'),
                      message: app.tr('hair_advice'),
                      actionLabel: app.tr('assistant'),
                      icon: Icons.brush_rounded,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BeautyAssistantScreen())),
                    )
                  else
                    StreamBuilder<List<ProductItem>>(
                      stream: _content.products(type: productType),
                      builder: (context, productSnapshot) {
                        final products = productSnapshot.data ?? const <ProductItem>[];
                        if (productSnapshot.connectionState == ConnectionState.waiting) {
                          return const BeautyCard(child: Center(child: CircularProgressIndicator(color: AppColors.hotPink)));
                        }
                        if (products.isEmpty) {
                          return BeautyCard(child: Text(app.tr('empty_products_firestore'), style: const TextStyle(fontWeight: FontWeight.w800)));
                        }
                        return Column(
                          children: products.map(
                            (product) => ProductCard(
                              product: product,
                              onAddToRoutine: () => _add(product),
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductMatchScreen(productType: product.type))),
                            ),
                          ).toList(),
                        );
                      },
                    ),
                  if (selectedId == 'skincare') ...[
                    const SizedBox(height: 10),
                    GradientButton(
                      label: app.tr('scan_product'),
                      icon: Icons.qr_code_scanner_rounded,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const IngredientSafetyScreen())),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  String _categoryTitle(AppProvider app, String id, String fallback) {
    final key = 'category_$id';
    final translated = app.tr(key);
    return translated == key ? fallback : translated;
  }

  String _productTypeFor(String? id) {
    if (id == 'makeup') return 'makeup';
    return 'skincare';
  }

  AppCategoryItem? _selectedCategory(List<AppCategoryItem> categories, String id) {
    for (final category in categories) {
      if (category.id == id) return category;
    }
    return null;
  }
}

class _CategoryHero extends StatelessWidget {
  const _CategoryHero({required this.item, required this.fallbackId, required this.title});
  final AppCategoryItem? item;
  final String fallbackId;
  final String title;

  @override
  Widget build(BuildContext context) {
    final color = item?.color ?? AppColors.hotPink;
    final icon = item?.icon ?? Icons.spa_rounded;
    return BeautyCard(
      color: color.withValues(alpha: .10),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(gradient: AppColors.beautyGradient, borderRadius: BorderRadius.circular(22)),
            child: Icon(icon, color: Colors.white, size: 34),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(title.isEmpty ? fallbackId : title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.hotPink))),
        ],
      ),
    );
  }
}

class _AdviceCard extends StatelessWidget {
  const _AdviceCard({required this.title, required this.message, required this.actionLabel, required this.icon, required this.onTap});

  final String title;
  final String message;
  final String actionLabel;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return BeautyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, color: AppColors.hotPink), const SizedBox(width: 8), Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.hotPink))]),
          const SizedBox(height: 10),
          Text(message, style: const TextStyle(height: 1.45, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          GradientButton(label: actionLabel, icon: Icons.chat_bubble_rounded, onTap: onTap),
        ],
      ),
    );
  }
}

