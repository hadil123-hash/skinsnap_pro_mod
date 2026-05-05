import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/beauty_plan.dart';
import '../utils/constants.dart';

int _asInt(dynamic value, [int fallback = 0]) {
  if (value is int) return value;
  if (value is num) return value.round();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

double _asDouble(dynamic value, [double fallback = 0]) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? fallback;
  return fallback;
}

String _asString(dynamic value, [String fallback = '']) {
  if (value == null) return fallback;
  return value.toString();
}

bool _asBool(dynamic value, [bool fallback = true]) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.toLowerCase().trim();
    if (normalized == 'true' || normalized == '1' || normalized == 'yes') return true;
    if (normalized == 'false' || normalized == '0' || normalized == 'no') return false;
  }
  return fallback;
}

List<String> _asStringList(dynamic value) {
  if (value is Iterable) {
    return value.map((item) => item.toString()).toList();
  }
  return const [];
}

Color colorFromHex(String? value, [Color fallback = AppColors.hotPink]) {
  if (value == null || value.trim().isEmpty) return fallback;
  final normalized = value.replaceAll('#', '').trim();
  final hex = normalized.length == 6 ? 'FF$normalized' : normalized;
  final parsed = int.tryParse(hex, radix: 16);
  return parsed == null ? fallback : Color(parsed);
}

IconData iconFromName(String value) {
  switch (value) {
    case 'spa':
      return Icons.spa_rounded;
    case 'makeup':
      return Icons.auto_awesome_rounded;
    case 'hair':
      return Icons.brush_rounded;
    case 'health':
      return Icons.health_and_safety_rounded;
    case 'sun':
      return Icons.wb_sunny_rounded;
    case 'cleanser':
      return Icons.local_drink_rounded;
    case 'serum':
      return Icons.opacity_rounded;
    case 'chat':
      return Icons.chat_bubble_outline_rounded;
    case 'scan':
      return Icons.qr_code_scanner_rounded;
    case 'product':
      return Icons.shopping_bag_rounded;
    default:
      return Icons.spa_rounded;
  }
}

class AppCategoryItem {
  final String id;
  final String title;
  final String iconName;
  final String colorHex;
  final String imageUrl;
  final int rank;
  final bool isActive;

  const AppCategoryItem({
    required this.id,
    required this.title,
    required this.iconName,
    required this.colorHex,
    required this.imageUrl,
    required this.rank,
    this.isActive = true,
  });

  Color get color => colorFromHex(colorHex);
  IconData get icon => iconFromName(iconName);

  factory AppCategoryItem.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    return AppCategoryItem.fromMap(doc.id, doc.data() ?? const <String, dynamic>{});
  }

  factory AppCategoryItem.fromMap(String id, Map<String, dynamic> data) {
    return AppCategoryItem(
      id: id,
      title: _asString(data['title'], 'Categorie'),
      iconName: _asString(data['icon'], _asString(data['iconName'], 'spa')),
      colorHex: _asString(data['colorHex'], '#E5007E'),
      imageUrl: _asString(data['imageUrl']),
      rank: _asInt(data['rank']),
      isActive: _asBool(data['isActive'], true),
    );
  }
}

class ProductItem {
  final String id;
  final String name;
  final String brand;
  final String category;
  final String subtitle;
  final String description;
  final String type;
  final String usage;
  final String routineStep;
  final int matchScore;
  final double rating;
  final int reviewCount;
  final String imageUrl;
  final String storagePath;
  final String colorHex;
  final String iconName;
  final List<String> skinTypes;
  final List<String> concerns;
  final String texture;
  final int rank;
  final bool isActive;

  const ProductItem({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.subtitle,
    required this.description,
    required this.type,
    required this.usage,
    required this.routineStep,
    required this.matchScore,
    required this.rating,
    required this.reviewCount,
    required this.imageUrl,
    required this.storagePath,
    required this.colorHex,
    required this.iconName,
    required this.skinTypes,
    required this.concerns,
    required this.texture,
    required this.rank,
    this.isActive = true,
  });

  Color get color => colorFromHex(colorHex, AppColors.success);
  IconData get icon => iconFromName(iconName);
  String get skinTypesText => skinTypes.isEmpty ? '-' : skinTypes.join(', ');
  String get concernsText => concerns.isEmpty ? '-' : concerns.join(', ');
  String get displaySubtitle => subtitle.isNotEmpty ? subtitle : brand;
  String get safeImageUrl => imageUrl.trim();

  ProductItem copyWith({String? imageUrl, int? matchScore}) {
    return ProductItem(
      id: id,
      name: name,
      brand: brand,
      category: category,
      subtitle: subtitle,
      description: description,
      type: type,
      usage: usage,
      routineStep: routineStep,
      matchScore: matchScore ?? this.matchScore,
      rating: rating,
      reviewCount: reviewCount,
      imageUrl: imageUrl ?? this.imageUrl,
      storagePath: storagePath,
      colorHex: colorHex,
      iconName: iconName,
      skinTypes: skinTypes,
      concerns: concerns,
      texture: texture,
      rank: rank,
      isActive: isActive,
    );
  }

  Map<String, dynamic> toRoutineMap() => {
        'productId': id,
        'name': name,
        'brand': brand,
        'category': category,
        'subtitle': subtitle,
        'description': description,
        'type': type,
        'usage': usage,
        'routineStep': routineStep,
        'matchScore': matchScore,
        'rating': rating,
        'reviewCount': reviewCount,
        'imageUrl': imageUrl,
        'storagePath': storagePath,
        'colorHex': colorHex,
        'icon': iconName,
        'skinTypes': skinTypes,
        'concerns': concerns,
        'texture': texture,
        'rank': rank,
        'isActive': isActive,
      };

  factory ProductItem.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    return ProductItem.fromMap(doc.id, doc.data() ?? const <String, dynamic>{});
  }

  factory ProductItem.fromMap(String id, Map<String, dynamic> data) {
    final brand = _asString(data['brand']);
    final category = _asString(data['category']);
    return ProductItem(
      id: id,
      name: _asString(data['name'], 'Produit'),
      brand: brand,
      category: category,
      subtitle: _asString(data['subtitle'], _asString(data['subCategory'], brand.isNotEmpty ? brand : category)),
      description: _asString(data['description']),
      type: _asString(data['type'], 'skincare').toLowerCase().trim(),
      usage: _asString(data['usage']),
      routineStep: _asString(data['routineStep'], category),
      matchScore: _asInt(data['matchScore']),
      rating: _asDouble(data['rating'], 0),
      reviewCount: _asInt(data['reviewCount']),
      imageUrl: _asString(data['imageUrl']),
      storagePath: _asString(data['storagePath']),
      colorHex: _asString(data['colorHex'], '#00B870'),
      iconName: _asString(data['icon'], _asString(data['iconName'], 'product')),
      skinTypes: _asStringList(data['skinTypes']),
      concerns: _asStringList(data['concerns']),
      texture: _asString(data['texture'], '-'),
      rank: _asInt(data['rank']),
      isActive: _asBool(data['isActive'], true),
    );
  }
}

class IngredientItem {
  final String id;
  final String name;
  final String note;
  final int penaltyLevel;
  final int rank;

  const IngredientItem({
    required this.id,
    required this.name,
    required this.note,
    required this.penaltyLevel,
    required this.rank,
  });

  Color get color {
    switch (penaltyLevel) {
      case 3:
        return AppColors.error;
      case 2:
        return AppColors.coral;
      case 1:
        return AppColors.warning;
      default:
        return AppColors.success;
    }
  }

  String get severityLabel {
    switch (penaltyLevel) {
      case 3:
        return 'Penalite forte';
      case 2:
        return 'Penalite moyenne';
      case 1:
        return 'Penalite faible';
      default:
        return 'Pas de penalite';
    }
  }

  factory IngredientItem.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    return IngredientItem(
      id: doc.id,
      name: _asString(data['name'], 'Ingredient'),
      note: _asString(data['note']),
      penaltyLevel: _asInt(data['penaltyLevel']).clamp(0, 3).toInt(),
      rank: _asInt(data['rank']),
    );
  }
}

class AssistantQuestionItem {
  final String id;
  final String question;
  final String answer;
  final int rank;

  const AssistantQuestionItem({
    required this.id,
    required this.question,
    required this.answer,
    required this.rank,
  });

  factory AssistantQuestionItem.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    return AssistantQuestionItem(
      id: doc.id,
      question: _asString(data['question']),
      answer: _asString(data['answer']),
      rank: _asInt(data['rank']),
    );
  }
}

RoutineMoment routineMomentFromString(String value) {
  return value == RoutineMoment.evening.name ? RoutineMoment.evening : RoutineMoment.morning;
}

RoutineStep routineStepFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
  final data = doc.data() ?? const <String, dynamic>{};
  return RoutineStep(
    id: doc.id,
    title: _asString(data['title'], 'Etape'),
    description: _asString(data['description']),
    productName: _asString(data['productName']),
    moment: routineMomentFromString(_asString(data['moment'], 'morning')),
  );
}
