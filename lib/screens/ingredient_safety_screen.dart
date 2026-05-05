import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/firestore_content.dart';
import '../providers/app_provider.dart';
import '../services/firestore_content_service.dart';
import '../services/open_beauty_facts_service.dart';
import '../services/product_service.dart';
import '../services/sound_service.dart';
import '../utils/constants.dart';
import '../widgets/beauty_ui.dart';
import '../widgets/product_card.dart';
import '../widgets/product_image.dart';
import 'product_detail_screen.dart';

class IngredientSafetyScreen extends StatefulWidget {
  const IngredientSafetyScreen({super.key});

  @override
  State<IngredientSafetyScreen> createState() => _IngredientSafetyScreenState();
}

class _IngredientSafetyScreenState extends State<IngredientSafetyScreen> {
  final ProductService _productService = ProductService();
  final OpenBeautyFactsService _scanService = OpenBeautyFactsService();
  final FirestoreContentService _content = FirestoreContentService();
  final ImagePicker _picker = ImagePicker();

  File? _image;
  ProductScanResult? _result;

  bool _loading = false;
  bool _picking = false;
  bool _saving = false;

  void _safeSetState(VoidCallback callback) {
    if (!mounted) return;
    setState(callback);
  }

  void _showMessage(String text, {Color? color}) {
    if (!mounted || text.trim().isEmpty) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final messenger = ScaffoldMessenger.maybeOf(context);
      if (messenger == null) return;

      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text(text),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
        ),
      );
    });
  }

  Future<void> _scanProduct(ImageSource source) async {
    if (_picking || _loading) return;

    _picking = true;
    await SoundService().playClick();

    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (!mounted) return;

      if (picked == null) {
        _picking = false;
        return;
      }

      final pickedImage = File(picked.path);

      _safeSetState(() {
        _loading = true;
        _image = pickedImage;
        _result = null;
      });

      final result = await _scanService.scanImage(picked.path);

      if (!mounted) return;

      _safeSetState(() {
        _result = result;
        _loading = false;
      });

      if (result.fromApi) {
        await SoundService().feedbackSuccess();
      } else {
        await SoundService().feedbackError();
        _showMessage(result.message, color: AppColors.orange);
      }
    } catch (_) {
      if (!mounted) return;

      _safeSetState(() {
        _loading = false;
      });

      await SoundService().feedbackError();
      _showMessage(
        'Scan impossible. Essaie une photo plus nette ou entre le code-barres manuellement.',
        color: AppColors.error,
      );
    } finally {
      _picking = false;
    }
  }

  Future<void> _searchManualBarcode() async {
    if (_picking || _loading) return;

    final app = context.read<AppProvider>();

    final code = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        String typedCode = '';

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: Text(
            app.tr('enter_barcode'),
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          content: TextField(
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.search,
            autofocus: true,
            decoration: InputDecoration(
              hintText: app.tr('barcode_hint'),
              border: const OutlineInputBorder(),
            ),
            onChanged: (value) {
              typedCode = value.trim();
            },
            onSubmitted: (value) {
              Navigator.of(dialogContext).pop(value.trim());
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(null);
              },
              child: Text(app.tr('cancel')),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(typedCode.trim());
              },
              child: Text(app.tr('search')),
            ),
          ],
        );
      },
    );

    if (!mounted) return;

    final cleanCode = code?.trim() ?? '';

    if (cleanCode.isEmpty) {
      return;
    }

    _safeSetState(() {
      _loading = true;
      _image = null;
      _result = null;
    });

    try {
      final result = await _scanService.fetchByBarcode(cleanCode);

      if (!mounted) return;

      _safeSetState(() {
        _result = result;
        _loading = false;
      });

      if (result.fromApi) {
        await SoundService().feedbackSuccess();
      } else {
        await SoundService().feedbackError();
        _showMessage(result.message, color: AppColors.orange);
      }
    } catch (_) {
      if (!mounted) return;

      _safeSetState(() {
        _loading = false;
      });

      await SoundService().feedbackError();
      _showMessage(
        'Recherche impossible. Vérifie Internet puis réessaie.',
        color: AppColors.error,
      );
    }
  }

  Future<void> _addProduct(ProductItem product) async {
    if (_saving) return;

    final app = context.read<AppProvider>();

    _safeSetState(() {
      _saving = true;
    });

    try {
      await _productService.addProductToUserRoutine(product);
      await SoundService().feedbackSave();

      if (!mounted) return;

      _showMessage(
        app.tr('added_routine'),
        color: AppColors.success,
      );
    } catch (error) {
      if (!mounted) return;

      await SoundService().feedbackError();
      _showMessage(error.toString(), color: AppColors.error);
    } finally {
      if (mounted) {
        _safeSetState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final result = _result;
    final ingredients = result?.ingredients ?? const <IngredientItem>[];
    final product = result?.product;

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
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        app.tr('scan_product'),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                GradientText(
                  app.tr('onb_safety_title'),
                  style: const TextStyle(
                    fontSize: 30,
                    height: 1.15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  app.tr('scan_real_product_help'),
                  style: TextStyle(
                    height: 1.45,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: .68),
                  ),
                ),
                const SizedBox(height: 20),
                _ProductScannerCard(
                  image: _image,
                  loading: _loading,
                  scanProductText: app.tr('scan_product'),
                  scanProductSubText: app.tr('scan_product_sub'),
                  cameraText: app.tr('camera'),
                  galleryText: app.tr('gallery'),
                  manualBarcodeText: app.tr('manual_barcode'),
                  onCamera: () => _scanProduct(ImageSource.camera),
                  onGallery: () => _scanProduct(ImageSource.gallery),
                  onManual: _searchManualBarcode,
                ),
                if (result != null) ...[
                  const SizedBox(height: 18),
                  _ScanMessage(result: result),
                ],
                if (product != null && result != null) ...[
                  const SizedBox(height: 22),
                  _DetectedProductCard(
                    product: product,
                    result: result,
                    sourceLabel: app.tr('source'),
                    skinTypesLabel: app.tr('skin_types'),
                    concernsLabel: app.tr('concerns'),
                    productDetectedLabel: app.tr('product_detected'),
                    addRoutineLabel: app.tr('add_routine'),
                    productNotFoundLabel: app.tr('product_not_found'),
                    onAdd: () => _addProduct(product),
                  ),
                ],
                const SizedBox(height: 22),
                _SafetyScoreCard(
                  ingredients: ingredients,
                  title: app.tr('safety_score'),
                  highLabel: app.tr('penalty_high'),
                  mediumLabel: app.tr('penalty_medium'),
                  lowLabel: app.tr('penalty_low'),
                  noneLabel: app.tr('penalty_none'),
                ),
                const SizedBox(height: 22),
                BeautyCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app.tr('ingredients_detected'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 14),
                      if (ingredients.isEmpty)
                        const Text(
                          'Aucun ingrédient détecté pour le moment.',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        )
                      else
                        ...ingredients.map(
                              (item) => _IngredientTile(item: item),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  app.tr('compatible_products'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                StreamBuilder<List<ProductItem>>(
                  stream: _content.products(type: 'skincare', limit: 3),
                  builder: (context, snapshot) {
                    final compatible = snapshot.data ?? const <ProductItem>[];

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const BeautyCard(
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.hotPink,
                          ),
                        ),
                      );
                    }

                    if (compatible.isEmpty) {
                      return BeautyCard(
                        child: Text(
                          app.tr('empty_products_firestore'),
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      );
                    }

                    return Column(
                      children: compatible
                          .map(
                            (item) => ProductCard(
                          product: item,
                          onAddToRoutine: () => _addProduct(item),
                        ),
                      )
                          .toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductScannerCard extends StatelessWidget {
  const _ProductScannerCard({
    required this.image,
    required this.loading,
    required this.scanProductText,
    required this.scanProductSubText,
    required this.cameraText,
    required this.galleryText,
    required this.manualBarcodeText,
    required this.onCamera,
    required this.onGallery,
    required this.onManual,
  });

  final File? image;
  final bool loading;
  final String scanProductText;
  final String scanProductSubText;
  final String cameraText;
  final String galleryText;
  final String manualBarcodeText;
  final VoidCallback onCamera;
  final VoidCallback onGallery;
  final VoidCallback onManual;

  @override
  Widget build(BuildContext context) {
    return BeautyCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: const BoxDecoration(
              gradient: AppColors.beautyGradient,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: Text(
              scanProductText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 190,
                  decoration: BoxDecoration(
                    color: AppColors.blush,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: AppColors.hotPink.withValues(alpha: .14),
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: loading
                      ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.hotPink,
                    ),
                  )
                      : image == null
                      ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.qr_code_scanner_rounded,
                        color: AppColors.hotPink,
                        size: 52,
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                        ),
                        child: Text(
                          scanProductSubText,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppColors.hotPink,
                          ),
                        ),
                      ),
                    ],
                  )
                      : Image.file(image!, fit: BoxFit.cover),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: GradientButton(
                        label: cameraText,
                        icon: Icons.photo_camera_rounded,
                        height: 46,
                        onTap: loading ? null : onCamera,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: loading ? null : onGallery,
                        icon: const Icon(Icons.photo_library_rounded),
                        label: Text(galleryText),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: loading ? null : onManual,
                    icon: const Icon(Icons.pin_rounded),
                    label: Text(manualBarcodeText),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanMessage extends StatelessWidget {
  const _ScanMessage({required this.result});

  final ProductScanResult result;

  @override
  Widget build(BuildContext context) {
    return BeautyCard(
      padding: const EdgeInsets.all(14),
      color: result.fromApi ? AppColors.mint : AppColors.cream,
      child: Row(
        children: [
          Icon(
            result.fromApi
                ? Icons.cloud_done_rounded
                : Icons.info_rounded,
            color: result.fromApi ? AppColors.success : AppColors.orange,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              result.barcode.isEmpty
                  ? result.message
                  : '${result.message} Code: ${result.barcode}',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetectedProductCard extends StatelessWidget {
  const _DetectedProductCard({
    required this.product,
    required this.result,
    required this.sourceLabel,
    required this.skinTypesLabel,
    required this.concernsLabel,
    required this.productDetectedLabel,
    required this.addRoutineLabel,
    required this.productNotFoundLabel,
    required this.onAdd,
  });

  final ProductItem product;
  final ProductScanResult result;
  final String sourceLabel;
  final String skinTypesLabel;
  final String concernsLabel;
  final String productDetectedLabel;
  final String addRoutineLabel;
  final String productNotFoundLabel;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: BeautyCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              productDetectedLabel,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppColors.hotPink,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                ProductImageView(
                  product: product,
                  size: 92,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        product.brand,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        product.description,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _InfoLine(
              label: sourceLabel,
              value: result.fromApi
                  ? 'Open Beauty Facts API'
                  : productNotFoundLabel,
            ),
            _InfoLine(
              label: skinTypesLabel,
              value: product.skinTypesText,
            ),
            _InfoLine(
              label: concernsLabel,
              value: product.concernsText,
            ),
            const SizedBox(height: 16),
            GradientButton(
              label: addRoutineLabel,
              icon: Icons.add_circle_rounded,
              height: 48,
              onTap: onAdd,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          Flexible(
            child: Text(
              value.isEmpty ? '-' : value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _SafetyScoreCard extends StatelessWidget {
  const _SafetyScoreCard({
    required this.ingredients,
    required this.title,
    required this.highLabel,
    required this.mediumLabel,
    required this.lowLabel,
    required this.noneLabel,
  });

  final List<IngredientItem> ingredients;
  final String title;
  final String highLabel;
  final String mediumLabel;
  final String lowLabel;
  final String noneLabel;

  @override
  Widget build(BuildContext context) {
    final strong = ingredients.where((item) => item.penaltyLevel == 3).length;
    final medium = ingredients.where((item) => item.penaltyLevel == 2).length;
    final low = ingredients.where((item) => item.penaltyLevel == 1).length;
    final none = ingredients.where((item) => item.penaltyLevel == 0).length;
    final score = (20 - strong * 4 - medium * 2 - low).clamp(0, 20);

    return BeautyCard(
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.hotPink,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$score/20',
            style: const TextStyle(
              color: AppColors.hotPink,
              fontSize: 54,
              fontWeight: FontWeight.w900,
            ),
          ),
          _PenaltyRow(
            label: highLabel,
            value: strong,
            color: AppColors.error,
          ),
          _PenaltyRow(
            label: mediumLabel,
            value: medium,
            color: AppColors.coral,
          ),
          _PenaltyRow(
            label: lowLabel,
            value: low,
            color: AppColors.warning,
          ),
          _PenaltyRow(
            label: noneLabel,
            value: none,
            color: AppColors.success,
          ),
        ],
      ),
    );
  }
}

class _PenaltyRow extends StatelessWidget {
  const _PenaltyRow({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          CircleAvatar(
            radius: 18,
            backgroundColor: color,
            child: Text(
              '$value',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IngredientTile extends StatelessWidget {
  const _IngredientTile({required this.item});

  final IngredientItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.blush.withValues(alpha: .45),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  item.note,
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
          SafetyDot(color: item.color),
        ],
      ),
    );
  }
}
