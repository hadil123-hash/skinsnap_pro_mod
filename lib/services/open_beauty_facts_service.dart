import 'dart:convert';
import 'dart:io';

import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:http/http.dart' as http;

import '../models/firestore_content.dart';

class ProductScanResult {
  const ProductScanResult({
    required this.product,
    required this.ingredients,
    required this.barcode,
    required this.fromApi,
    required this.message,
  });

  final ProductItem product;
  final List<IngredientItem> ingredients;
  final String barcode;
  final bool fromApi;
  final String message;
}

class OpenBeautyFactsService {
  Future<String?> readBarcodeFromImage(String imagePath) async {
    final scanner = BarcodeScanner();

    try {
      final input = InputImage.fromFilePath(imagePath);
      final codes = await scanner.processImage(input);

      for (final code in codes) {
        final value = code.rawValue?.trim();

        if (value != null && value.isNotEmpty) {
          return value;
        }
      }

      return null;
    } catch (_) {
      return null;
    } finally {
      await scanner.close();
    }
  }

  Future<ProductScanResult> scanImage(String imagePath) async {
    final barcode = await readBarcodeFromImage(imagePath);

    if (barcode == null || barcode.isEmpty) {
      return _fallback(
        'Aucun code-barres lisible dans cette image.',
        '',
      );
    }

    return fetchByBarcode(barcode);
  }

  Future<ProductScanResult> fetchByBarcode(String barcode) async {
    final trimmed = barcode.trim();

    if (trimmed.isEmpty) {
      return _fallback('Code-barres vide.', '');
    }

    try {
      final beautyResult = await _fetchFromOpenBeautyFacts(trimmed);

      if (beautyResult != null) {
        return beautyResult;
      }

      final universalResult = await _fetchUniversal(trimmed);

      if (universalResult != null) {
        return universalResult;
      }

      return _fallback(
        'Produit non trouvé dans les bases ouvertes.',
        trimmed,
      );
    } catch (_) {
      return _fallback(
        'Connexion ou API indisponible.',
        trimmed,
      );
    }
  }

  Future<ProductScanResult?> _fetchFromOpenBeautyFacts(String barcode) async {
    final uri = Uri.https(
      'world.openbeautyfacts.org',
      '/api/v2/product/$barcode.json',
      {
        'fields':
        'code,product_name,product_name_fr,brands,image_url,image_front_url,ingredients_text,ingredients_text_fr,ingredients_text_en,ingredients,categories_tags',
      },
    );

    final response = await http
        .get(
      uri,
      headers: {
        HttpHeaders.userAgentHeader:
        'SkinSnap/1.0 Flutter student project',
        HttpHeaders.acceptHeader: 'application/json',
      },
    )
        .timeout(const Duration(seconds: 12));

    if (response.statusCode != 200) {
      return null;
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      return null;
    }

    final status = decoded['status'];
    final productData = decoded['product'];

    if (status == 1 && productData is Map<String, dynamic>) {
      final ingredients = _ingredientsFromApi(productData);
      final product = _productFromApi(barcode, productData, ingredients);

      return ProductScanResult(
        product: product,
        ingredients: ingredients,
        barcode: barcode,
        fromApi: true,
        message: 'Produit trouvé avec Open Beauty Facts.',
      );
    }

    return null;
  }

  Future<ProductScanResult?> _fetchUniversal(String barcode) async {
    final uri = Uri.https(
      'world.openfoodfacts.org',
      '/api/v3/product/$barcode.json',
      {
        'product_type': 'all',
        'fields':
        'code,product_name,product_name_fr,brands,image_url,image_front_url,ingredients_text,ingredients_text_fr,ingredients_text_en,ingredients,categories_tags',
      },
    );

    final response = await http
        .get(
      uri,
      headers: {
        HttpHeaders.userAgentHeader: 'SkinSnap/1.0 Flutter project',
        HttpHeaders.acceptHeader: 'application/json',
      },
    )
        .timeout(const Duration(seconds: 12));

    if (response.statusCode != 200) {
      return null;
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      return null;
    }

    final productData = decoded['product'];

    if (productData is! Map<String, dynamic>) {
      return null;
    }

    final ingredients = _ingredientsFromApi(productData);
    final product = _productFromApi(barcode, productData, ingredients);

    return ProductScanResult(
      product: product,
      ingredients: ingredients,
      barcode: barcode,
      fromApi: true,
      message: 'Produit trouvé avec Open Products API.',
    );
  }

  ProductScanResult _fallback(String message, String barcode) {
    final product = ProductItem(
      id: barcode.isEmpty ? 'unknown_product' : 'unknown_$barcode',
      name: barcode.isEmpty ? 'Produit non détecté' : 'Produit non trouvé',
      brand: 'Base produit indisponible',
      category: 'Skincare',
      subtitle: 'Scan produit',
      description: barcode.isEmpty
          ? 'Aucun code-barres lisible. Essayez une photo plus nette ou entrez le code manuellement.'
          : 'Ce code-barres n existe pas encore dans les bases ouvertes utilisées par SkinSnap.',
      type: 'skincare',
      usage: 'analyse',
      routineStep: 'Produit scanné',
      matchScore: 0,
      rating: 0,
      reviewCount: 0,
      imageUrl: '',
      storagePath: '',
      colorHex: '#FF8A00',
      iconName: 'scan',
      skinTypes: const [],
      concerns: const [],
      texture: '-',
      rank: 0,
    );

    return ProductScanResult(
      product: product,
      ingredients: const [],
      barcode: barcode,
      fromApi: false,
      message: message,
    );
  }

  ProductItem _productFromApi(
      String barcode,
      Map<String, dynamic> data,
      List<IngredientItem> ingredients,
      ) {
    final name = _firstNonEmpty(
      [
        data['product_name_fr'],
        data['product_name'],
      ],
      'Produit cosmétique',
    );

    final brand = _readString(data['brands'], 'Open Beauty Facts');

    final image = _firstNonEmpty(
      [
        data['image_front_url'],
        data['image_url'],
      ],
      '',
    );

    final ingredientsText = _firstNonEmpty(
      [
        data['ingredients_text_fr'],
        data['ingredients_text_en'],
        data['ingredients_text'],
      ],
      '',
    );

    final concerns = _concernsFromIngredients(ingredients);
    final score = _scoreFromIngredients(ingredients);

    return ProductItem(
      id: 'obf_$barcode',
      name: name,
      brand: brand,
      category: 'Skincare',
      subtitle: 'Produit scanné',
      description: ingredientsText.isEmpty
          ? 'Produit récupéré depuis une base ouverte.'
          : 'Ingrédients détectés : ${_shorten(ingredientsText, 120)}',
      type: 'skincare',
      usage: 'analyse',
      routineStep: 'Produit scanné',
      matchScore: score,
      rating: 4.2,
      reviewCount: 0,
      imageUrl: image,
      storagePath: '',
      colorHex: score >= 75
          ? '#00B870'
          : score >= 55
          ? '#FF8A00'
          : '#E53935',
      iconName: 'product',
      skinTypes: const ['grasse', 'mixte', 'normale', 'seche', 'sensible'],
      concerns: concerns,
      texture: 'Produit cosmétique',
      rank: 0,
    );
  }

  List<IngredientItem> _ingredientsFromApi(Map<String, dynamic> data) {
    final rawList = data['ingredients'];
    final text = _firstNonEmpty(
      [
        data['ingredients_text_fr'],
        data['ingredients_text_en'],
        data['ingredients_text'],
      ],
      '',
    );

    final names = <String>[];

    if (rawList is List) {
      for (final raw in rawList) {
        if (raw is Map<String, dynamic>) {
          final value = _firstNonEmpty(
            [
              raw['text'],
              raw['id'],
            ],
            '',
          );

          if (value.isNotEmpty) {
            names.add(value);
          }
        }
      }
    }

    if (names.isEmpty && text.isNotEmpty) {
      names.addAll(
        text
            .split(RegExp(r'[,;•]'))
            .map((item) => item.trim())
            .where((item) => item.isNotEmpty)
            .take(20),
      );
    }

    final items = <IngredientItem>[];

    for (var i = 0; i < names.length && i < 20; i++) {
      final name = names[i]
          .replaceAll('en:', '')
          .replaceAll('fr:', '')
          .trim();

      if (name.isEmpty) continue;

      final penalty = _penaltyFor(name);

      items.add(
        IngredientItem(
          id: name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_'),
          name: name.toUpperCase(),
          note: _noteFor(name, penalty),
          penaltyLevel: penalty,
          rank: i + 1,
        ),
      );
    }

    return items;
  }

  int _penaltyFor(String value) {
    final text = value.toLowerCase();

    const strong = [
      'methylisothiazolinone',
      'formaldehyde',
      'oxybenzone',
      'hydroquinone',
      'triclosan',
    ];

    const medium = [
      'alcohol denat',
      'parfum',
      'fragrance',
      'limonene',
      'linalool',
      'benzyl alcohol',
      'phenoxyethanol',
    ];

    const low = [
      'citric acid',
      'lactic acid',
      'salicylic acid',
      'sodium benzoate',
    ];

    if (strong.any(text.contains)) return 3;
    if (medium.any(text.contains)) return 2;
    if (low.any(text.contains)) return 1;

    return 0;
  }

  String _noteFor(String name, int penalty) {
    switch (penalty) {
      case 3:
        return 'Ingrédient à risque élevé : à éviter pour les peaux sensibles.';
      case 2:
        return 'Risque moyen : peut irriter certaines peaux.';
      case 1:
        return 'Risque faible : à surveiller selon la tolérance.';
      default:
        return 'Aucun risque notable détecté.';
    }
  }

  List<String> _concernsFromIngredients(List<IngredientItem> ingredients) {
    final concerns = <String>{'analyse_produit'};

    for (final ingredient in ingredients) {
      final name = ingredient.name.toLowerCase();

      if (ingredient.penaltyLevel >= 2) {
        concerns.add('sensibilite');
      }

      if (name.contains('acid')) {
        concerns.add('exfoliation');
      }

      if (name.contains('parfum') || name.contains('fragrance')) {
        concerns.add('parfum');
      }
    }

    return concerns.toList();
  }

  int _scoreFromIngredients(List<IngredientItem> ingredients) {
    if (ingredients.isEmpty) return 70;

    var score = 95;

    for (final ingredient in ingredients) {
      switch (ingredient.penaltyLevel) {
        case 3:
          score -= 18;
          break;
        case 2:
          score -= 9;
          break;
        case 1:
          score -= 4;
          break;
        default:
          break;
      }
    }

    return score.clamp(25, 98).toInt();
  }

  String _firstNonEmpty(List<dynamic> values, String fallback) {
    for (final value in values) {
      final text = _readString(value, '');

      if (text.isNotEmpty) {
        return text;
      }
    }

    return fallback;
  }

  String _readString(dynamic value, String fallback) {
    if (value == null) return fallback;

    final text = value.toString().trim();

    return text.isEmpty ? fallback : text;
  }

  String _shorten(String value, int max) {
    if (value.length <= max) return value;

    return '${value.substring(0, max).trim()}...';
  }
}
