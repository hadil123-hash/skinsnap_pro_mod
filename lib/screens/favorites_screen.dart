import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/firestore_content.dart';
import '../providers/app_provider.dart';
import '../services/favorite_service.dart';
import '../services/product_service.dart';
import '../services/sound_service.dart';
import '../utils/constants.dart';
import '../widgets/beauty_ui.dart';
import '../widgets/product_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FavoriteService _favoriteService = FavoriteService();
  final ProductService _productService = ProductService();

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
          child: StreamBuilder<List<ProductItem>>(
            stream: _favoriteService.watchFavorites(),
            builder: (context, snapshot) {
              final items = snapshot.data ?? const <ProductItem>[];
              return ListView(
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
                          app.tr('favorites'),
                          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const BeautyCard(child: Center(child: CircularProgressIndicator(color: AppColors.hotPink)))
                  else if (items.isEmpty)
                    BeautyCard(
                      child: Column(
                        children: [
                          const Icon(Icons.favorite_border_rounded, color: AppColors.hotPink, size: 58),
                          const SizedBox(height: 12),
                          Text(app.tr('empty_favorites'), textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w900)),
                          const SizedBox(height: 6),
                          Text(app.tr('empty_favorites_hint'), textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade700)),
                        ],
                      ),
                    )
                  else
                    ...items.map(
                      (product) => ProductCard(
                        product: product,
                        onAddToRoutine: () => _add(product),
                        
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
