import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/beauty_plan.dart';
import '../models/firestore_content.dart';

class FirestoreContentService {
  FirestoreContentService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  Stream<List<AppCategoryItem>> categories() {
    return _db
        .collection('categories')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      final items = snapshot.docs.map(AppCategoryItem.fromDoc).toList();
      items.sort((a, b) => a.rank.compareTo(b.rank));
      return items;
    });
  }

  Stream<List<ProductItem>> products({
    int? limit,
    String? type,
    String? skinType,
  }) {
    Query<Map<String, dynamic>> query = _db
        .collection('products')
        .where('isActive', isEqualTo: true);

    final normalizedType = type?.toLowerCase().trim();
    if (normalizedType != null && normalizedType.isNotEmpty) {
      query = query.where('type', isEqualTo: normalizedType);
    }

    return query.snapshots().map((snapshot) {
      final items = snapshot.docs.map(ProductItem.fromDoc).toList();
      final filtered = _filterProducts(
        items,
        type: normalizedType,
        skinType: skinType,
        limit: limit,
      );
      return filtered;
    });
  }

  Future<List<ProductItem>> productsOnce({
    int? limit,
    String? type,
    String? skinType,
  }) async {
    Query<Map<String, dynamic>> query = _db
        .collection('products')
        .where('isActive', isEqualTo: true);

    final normalizedType = type?.toLowerCase().trim();
    if (normalizedType != null && normalizedType.isNotEmpty) {
      query = query.where('type', isEqualTo: normalizedType);
    }

    final snapshot = await query.get();
    final items = snapshot.docs.map(ProductItem.fromDoc).toList();
    return _filterProducts(
      items,
      type: normalizedType,
      skinType: skinType,
      limit: limit,
    );
  }

  List<ProductItem> _filterProducts(
    List<ProductItem> source, {
    int? limit,
    String? type,
    String? skinType,
  }) {
    final normalizedType = type?.toLowerCase().trim();
    final normalizedSkin = _normalizeSkinType(skinType);

    final products = source.where((product) {
      if (!product.isActive) return false;

      if (normalizedType != null && normalizedType.isNotEmpty) {
        if (product.type.toLowerCase().trim() != normalizedType) return false;
      }

      if (normalizedSkin != null && normalizedSkin.isNotEmpty) {
        if (product.skinTypes.isEmpty) return true;
        return product.skinTypes.any((value) {
          final item = _normalizeSkinType(value) ?? '';
          return item == normalizedSkin ||
              item.contains(normalizedSkin) ||
              normalizedSkin.contains(item);
        });
      }

      return true;
    }).toList();

    products.sort((a, b) {
      final byScore = b.matchScore.compareTo(a.matchScore);
      if (byScore != 0) return byScore;
      return a.rank.compareTo(b.rank);
    });

    return limit == null ? products : products.take(limit).toList();
  }

  Stream<List<IngredientItem>> ingredients() {
    return _db
        .collection('ingredients')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      final items = snapshot.docs.map(IngredientItem.fromDoc).toList();
      items.sort((a, b) => a.rank.compareTo(b.rank));
      return items;
    });
  }

  Stream<List<AssistantQuestionItem>> assistantQuestions() {
    return _db
        .collection('assistant_questions')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      final items = snapshot.docs.map(AssistantQuestionItem.fromDoc).toList();
      items.sort((a, b) => a.rank.compareTo(b.rank));
      return items;
    });
  }

  Stream<List<RoutineStep>> routineSteps({required RoutineMoment moment}) {
    final momentName = moment.name;
    return _db
        .collection('routine_steps')
        .where('isActive', isEqualTo: true)
        .where('moment', isEqualTo: momentName)
        .snapshots()
        .map((snapshot) {
      final docs = snapshot.docs.toList();
      docs.sort((a, b) {
        final ar = _asInt(a.data()['rank']);
        final br = _asInt(b.data()['rank']);
        return ar.compareTo(br);
      });
      return docs.map((doc) {
        final data = doc.data();
        return RoutineStep(
          id: doc.id,
          title: (data['title'] ?? '').toString(),
          description: (data['description'] ?? '').toString(),
          productName: (data['productName'] ?? '').toString(),
          moment: moment,
        );
      }).toList();
    });
  }

  int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.round();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  Future<void> saveAssistantQuestion(String question) async {
    final text = question.trim();
    if (text.isEmpty) return;
    await _db.collection('assistant_user_questions').add({
      'question': text,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  String? _normalizeSkinType(String? value) {
    final text = (value ?? '').toLowerCase().trim();
    if (text.isEmpty) return null;
    if (text.contains('oily') || text.contains('grasse')) return 'grasse';
    if (text.contains('dry') || text.contains('seche') || text.contains('sèche')) return 'seche';
    if (text.contains('sensitive') || text.contains('sensible')) return 'sensible';
    if (text.contains('normal') || text.contains('normale')) return 'normale';
    if (text.contains('combination') || text.contains('mixte')) return 'mixte';
    return text;
  }
}
