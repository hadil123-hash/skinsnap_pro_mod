import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/firestore_content.dart';
import '../providers/app_provider.dart';
import '../screens/product_detail_screen.dart';
import '../services/favorite_service.dart';
import '../services/sound_service.dart';
import '../utils/constants.dart';
import 'beauty_ui.dart';
import 'product_image.dart';

class ProductCard extends StatefulWidget {
  const ProductCard({
    super.key,
    required this.product,
    this.onAddToRoutine,
    this.onRemove,
    this.onTap,
    this.onFavoriteChanged,
    this.compact = false,
    this.showAddButton = true,
    this.showFavorite = true,
  });

  final ProductItem product;
  final VoidCallback? onAddToRoutine;
  final VoidCallback? onRemove;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteChanged;
  final bool compact;
  final bool showAddButton;
  final bool showFavorite;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  final FavoriteService _favoriteService = FavoriteService();
  bool _favorite = false;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _loadFavorite();
  }

  @override
  void didUpdateWidget(ProductCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.product.id != widget.product.id) _loadFavorite();
  }

  Future<void> _loadFavorite() async {
    final value = await _favoriteService.isFavorite(widget.product.id);
    if (!mounted) return;
    setState(() {
      _favorite = value;
      _ready = true;
    });
  }

  Future<void> _toggleFavorite() async {
    final value = await _favoriteService.toggle(widget.product);
    await SoundService().feedbackSave();
    if (!mounted) return;
    setState(() {
      _favorite = value;
      _ready = true;
    });
    widget.onFavoriteChanged?.call();

    final app = context.read<AppProvider>();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(value ? app.tr('favorite_added') : app.tr('favorite_removed')),
        backgroundColor: value ? AppColors.success : AppColors.hotPink,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final card = BeautyCard(
      margin: const EdgeInsets.only(bottom: 14),
      padding: EdgeInsets.all(widget.compact ? 12 : 14),
      radius: 24,
      child: Row(
        children: [
          ProductImageView(product: widget.product, size: widget.compact ? 70 : 88),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: widget.product.color.withValues(alpha: .12),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text(
                        '${widget.product.matchScore}% match',
                        style: TextStyle(color: widget.product.color, fontWeight: FontWeight.w900, fontSize: 12),
                      ),
                    ),
                    const Spacer(),
                    if (widget.showFavorite)
                      InkWell(
                        onTap: _ready ? _toggleFavorite : null,
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            _favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            color: AppColors.hotPink,
                          ),
                        ),
                      ),
                    if (widget.onRemove != null)
                      InkWell(
                        onTap: widget.onRemove,
                        borderRadius: BorderRadius.circular(16),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(Icons.close_rounded, color: AppColors.hotPink),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  widget.product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: widget.compact ? 15 : 16, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 3),
                Text(
                  widget.product.displaySubtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w700),
                ),
                if (!widget.compact) ...[
                  const SizedBox(height: 6),
                  Text(
                    widget.product.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey.shade700, height: 1.3),
                  ),
                ],
                if (widget.showAddButton && widget.onAddToRoutine != null) ...[
                  const SizedBox(height: 10),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: InkWell(
                      onTap: widget.onAddToRoutine,
                      borderRadius: BorderRadius.circular(50),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(gradient: AppColors.beautyGradient, borderRadius: BorderRadius.circular(50)),
                        child: Text(
                          '+ ${app.tr('add_routine')}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );

    final tap = widget.onTap ?? () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetailScreen(product: widget.product),
        ),
      );
    };

    return InkWell(onTap: tap, borderRadius: BorderRadius.circular(24), child: card);
  }
}
