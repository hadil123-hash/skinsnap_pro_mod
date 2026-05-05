import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/firestore_content.dart';
import '../providers/app_provider.dart';
import '../services/favorite_service.dart';
import '../services/product_service.dart';
import '../services/sound_service.dart';
import '../utils/constants.dart';
import '../widgets/beauty_ui.dart';
import '../widgets/product_image.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.product});

  final ProductItem product;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final FavoriteService _favoriteService = FavoriteService();
  final ProductService _productService = ProductService();
  bool _favorite = false;
  bool _loadingFavorite = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadFavorite();
  }

  Future<void> _loadFavorite() async {
    final value = await _favoriteService.isFavorite(widget.product.id);
    if (!mounted) return;
    setState(() {
      _favorite = value;
      _loadingFavorite = false;
    });
  }

  Future<void> _toggleFavorite() async {
    if (_loadingFavorite) return;
    try {
      final value = await _favoriteService.toggle(widget.product);
      await SoundService().feedbackSave();
      if (!mounted) return;
      setState(() => _favorite = value);
      final tr = context.read<AppProvider>().tr;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(value ? tr('favorite_added') : tr('favorite_removed')),
          backgroundColor: value ? AppColors.success : AppColors.hotPink,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString()), backgroundColor: AppColors.error),
      );
    }
  }

  Future<void> _addToRoutine() async {
    if (_saving) return;
    final app = context.read<AppProvider>();
    setState(() => _saving = true);
    try {
      await _productService.addProductToUserRoutine(widget.product);
      await SoundService().feedbackSave();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(app.tr('added_routine')), backgroundColor: AppColors.success),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString()), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final product = widget.product;

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
                  const Spacer(),
                  BeautyCircleIcon(
                    icon: _favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    size: 44,
                    onTap: _toggleFavorite,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              BeautyCard(
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                      child: Column(
                        children: [
                          Container(
                            width: 210,
                            height: 210,
                            decoration: BoxDecoration(
                              color: product.color.withValues(alpha: .10),
                              borderRadius: BorderRadius.circular(34),
                            ),
                            child: ProductImageView(
                              product: product,
                              size: 210,
                              fit: BoxFit.contain,
                              borderRadius: 34,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: product.color,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '${product.matchScore}% match',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            product.brand.isEmpty ? product.displaySubtitle : product.brand,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .62),
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _InfoRow(label: app.tr('description'), value: product.description),
                          _InfoRow(label: app.tr('ideal_skin_type'), value: product.skinTypesText),
                          _InfoRow(label: app.tr('skin_conditions'), value: product.concernsText),
                          _InfoRow(label: app.tr('texture'), value: product.texture),
                          _InfoRow(label: app.tr('routine'), value: product.routineStep),
                          _InfoRow(label: app.tr('source'), value: product.safeImageUrl.startsWith('http') ? 'Open Beauty Facts / Web' : 'Application'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GradientButton(
                label: _saving ? app.tr('loading') : app.tr('add_routine'),
                icon: Icons.add_circle_outline_rounded,
                onTap: _saving ? null : _addToRoutine,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black.withValues(alpha: .07))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.hotPink, fontWeight: FontWeight.w900)),
          const SizedBox(height: 5),
          Text(
            value.trim().isEmpty ? '-' : value,
            style: const TextStyle(fontWeight: FontWeight.w700, height: 1.35),
          ),
        ],
      ),
    );
  }
}
