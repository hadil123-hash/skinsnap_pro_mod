import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/firestore_content.dart';
import '../providers/app_provider.dart';
import '../providers/beauty_plan_provider.dart';
import '../services/favorite_service.dart';
import '../services/firestore_content_service.dart';
import '../services/sound_service.dart';
import '../utils/constants.dart';
import '../widgets/beauty_ui.dart';
import '../widgets/product_image.dart';
import 'beauty_assistant_screen.dart';
import 'camera_screen.dart';
import 'category_list_screen.dart';
import 'favorites_screen.dart';
import 'ingredient_safety_screen.dart';
import 'settings_screen.dart';
import 'product_match_screen.dart';
import 'product_detail_screen.dart';
import 'routine_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final content = FirestoreContentService();
    final app = context.watch<AppProvider>();
    final plan = context.watch<BeautyPlanProvider>().currentPlan;
    final firstName = app.userName.trim().isEmpty
        ? 'Beauty'
        : app.userName.trim().split(RegExp(r'\s+')).first;

    return Scaffold(
      body: BeautyGradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HomeHeader(name: firstName),
                const SizedBox(height: 22),
                GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 1.07,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _FeatureCard(
                      title: app.tr('scan_face'),
                      subtitle: app.tr('scan_face_sub'),
                      icon: Icons.face_retouching_natural_rounded,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CameraScreen()),
                      ),
                    ),
                    _FeatureCard(
                      title: app.tr('assistant'),
                      subtitle: app.tr('assistant_sub'),
                      icon: Icons.chat_bubble_rounded,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const BeautyAssistantScreen()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _WideFeatureCard(
                  title: app.tr('scan_product'),
                  subtitle: app.tr('scan_product_sub'),
                  icon: Icons.qr_code_scanner_rounded,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const IngredientSafetyScreen()),
                  ),
                ),
                const SizedBox(height: 12),
                _WideFeatureCard(
                  title: app.tr('my_routine'),
                  subtitle: app.tr('my_routine_sub'),
                  icon: Icons.spa_rounded,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RoutineScreen()),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    app.tr('shop_new'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppColors.hotPink,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 14),
                _SearchBox(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProductMatchScreen()),
                  ),
                  onScanTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const IngredientSafetyScreen()),
                  ),
                ),
                const SizedBox(height: 24),
                SectionTitle(
                  title: app.tr('categories'),
                  action: app.tr('see_all'),
                  onAction: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CategoryListScreen()),
                  ),
                ),
                const SizedBox(height: 12),
                StreamBuilder<List<AppCategoryItem>>(
                  stream: content.categories(),
                  builder: (context, snapshot) {
                    final categories = snapshot.data ?? const <AppCategoryItem>[];
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(
                        height: 126,
                        child: Center(child: CircularProgressIndicator(color: AppColors.hotPink)),
                      );
                    }
                    if (categories.isEmpty) {
                      return _EmptyRealtimeCard(message: app.tr('empty_categories_firestore'));
                    }
                    return SizedBox(
                      height: 126,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        itemBuilder: (context, index) => _CategoryCard(categories[index]),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                SectionTitle(
                  title: app.tr('best_match'),
                  action: app.tr('see_all'),
                  onAction: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProductMatchScreen()),
                  ),
                ),
                Text(
                  app.tr('for_me'),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .62),
                  ),
                ),
                const SizedBox(height: 12),
                StreamBuilder<List<ProductItem>>(
                  stream: content.products(limit: 12),
                  builder: (context, snapshot) {
                    final products = snapshot.data ?? const <ProductItem>[];
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(
                        height: 270,
                        child: Center(child: CircularProgressIndicator(color: AppColors.hotPink)),
                      );
                    }
                    if (products.isEmpty) {
                      return _EmptyRealtimeCard(message: app.tr('empty_products_firestore'));
                    }
                    return SizedBox(
                      height: 270,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: products.length,
                        itemBuilder: (context, index) => _ProductMatchCard(product: products[index]),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                BeautyCard(
                  child: Row(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: const BoxDecoration(
                          gradient: AppColors.beautyGradient,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.auto_awesome_rounded, color: Colors.white),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              plan == null ? app.tr('active_routine_none') : '${app.tr('routine')} : ${plan.skinType}',
                              style: const TextStyle(fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              plan == null ? app.tr('scan_to_create_routine') : plan.summary,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .62),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${app.tr('hello')}, $name',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppColors.hotPink,
                    ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.phone_android_rounded, size: 16, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                    app.tr('from_phone'),
                    style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ],
          ),
        ),
        BeautyCircleIcon(
          icon: Icons.favorite_border_rounded,
          size: 44,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesScreen())),
        ),
        const SizedBox(width: 10),
        BeautyCircleIcon(
          icon: Icons.notifications_none_rounded,
          size: 44,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
        ),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: AppColors.beautyGradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.hotPink.withValues(alpha: .20),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -8,
              top: -8,
              child: Icon(icon, color: Colors.white.withValues(alpha: .42), size: 58),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.white, fontSize: 12, height: 1.25, fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WideFeatureCard extends StatelessWidget {
  const _WideFeatureCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: AppColors.beautyGradient,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: AppColors.hotPink.withValues(alpha: .16),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Icon(icon, color: Colors.white, size: 42),
          ],
        ),
      ),
    );
  }
}

class _SearchBox extends StatelessWidget {
  const _SearchBox({required this.onTap, required this.onScanTap});
  final VoidCallback onTap;
  final VoidCallback onScanTap;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    return BeautyCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      radius: 18,
      child: Row(
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            child: const Padding(
              padding: EdgeInsets.all(2),
              child: Icon(Icons.search_rounded, color: AppColors.hotPink, size: 30),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              onTap: onTap,
              child: Text(
                app.tr('search_match'),
                style: TextStyle(fontSize: 16, color: Colors.grey.shade700, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          InkWell(
            onTap: onScanTap,
            borderRadius: BorderRadius.circular(18),
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(Icons.qr_code_scanner_rounded, color: AppColors.hotPink),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard(this.item);
  final AppCategoryItem item;

  void _open(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => CategoryListScreen(initialCategoryId: item.id)));
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final key = 'category_${item.id}';
    final title = app.tr(key) == key ? item.title : app.tr(key);
    return Container(
      width: 126,
      margin: const EdgeInsets.only(right: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _open(context),
        child: BeautyCard(
          padding: const EdgeInsets.all(14),
          radius: 18,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.hotPink, fontWeight: FontWeight.w900)),
              const Spacer(),
              Center(child: _CategoryVisual(item: item, size: 54)),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryVisual extends StatelessWidget {
  const _CategoryVisual({required this.item, required this.size});
  final AppCategoryItem item;
  final double size;

  @override
  Widget build(BuildContext context) {
    final source = item.imageUrl.trim();
    if (source.startsWith('assets/')) {
      return Image.asset(source, width: size, height: size, fit: BoxFit.contain, errorBuilder: (_, __, ___) => Icon(item.icon, color: item.color, size: size));
    }
    if (source.startsWith('http')) {
      return Image.network(source, width: size, height: size, fit: BoxFit.contain, errorBuilder: (_, __, ___) => Icon(item.icon, color: item.color, size: size));
    }
    return Icon(item.icon, color: item.color, size: size);
  }
}

class _ProductMatchCard extends StatefulWidget {
  const _ProductMatchCard({required this.product});
  final ProductItem product;

  @override
  State<_ProductMatchCard> createState() => _ProductMatchCardState();
}

class _ProductMatchCardState extends State<_ProductMatchCard> {
  final FavoriteService _favoriteService = FavoriteService();
  bool _favorite = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final value = await _favoriteService.isFavorite(widget.product.id);
    if (mounted) setState(() => _favorite = value);
  }

  Future<void> _toggleFavorite() async {
    final value = await _favoriteService.toggle(widget.product);
    await SoundService().feedbackSave();
    if (mounted) setState(() => _favorite = value);
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    return Container(
      width: 184,
      margin: const EdgeInsets.only(right: 14),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product))),
        borderRadius: BorderRadius.circular(18),
        child: BeautyCard(
          padding: const EdgeInsets.all(12),
          radius: 18,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(color: product.color, borderRadius: BorderRadius.circular(10)),
                child: Text('${product.matchScore}% match', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
              ),
              const SizedBox(height: 14),
              Expanded(child: Center(child: ProductImageView(product: product, size: 112, fit: BoxFit.contain, borderRadius: 14))),
              Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: AppColors.warning, size: 18),
                  const SizedBox(width: 4),
                  Text(product.rating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.w800)),
                  const Spacer(),
                  InkWell(
                    onTap: _toggleFavorite,
                    borderRadius: BorderRadius.circular(18),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(_favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: AppColors.hotPink),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyRealtimeCard extends StatelessWidget {
  const _EmptyRealtimeCard({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return BeautyCard(
      child: Row(
        children: [
          const Icon(Icons.cloud_off_rounded, color: AppColors.hotPink),
          const SizedBox(width: 12),
          Expanded(child: Text(message, style: const TextStyle(fontWeight: FontWeight.w800, height: 1.35))),
        ],
      ),
    );
  }
}
