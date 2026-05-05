import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/firestore_content.dart';
import 'firestore_content_service.dart';

class ProductService {
  ProductService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirestoreContentService? contentService,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _content = contentService ?? FirestoreContentService(firestore: firestore);

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final FirestoreContentService _content;

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Utilisateur non connecté.');
    }
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _userRoot {
    return _db.collection('users');
  }

  DocumentReference<Map<String, dynamic>> get _skinProfileRef {
    return _userRoot.doc(_uid).collection('skin_profile').doc('profile');
  }

  String normalizeSkinType(String? value) {
    final text = (value ?? '').toLowerCase().trim();
    if (text.isEmpty) return 'mixte';
    if (text.contains('oily') || text.contains('grasse') || text.contains('دهنية')) {
      return 'grasse';
    }
    if (text.contains('dry') || text.contains('seche') || text.contains('sèche') || text.contains('جافة')) {
      return 'seche';
    }
    if (text.contains('sensitive') || text.contains('sensible') || text.contains('حساسة')) {
      return 'sensible';
    }
    if (text.contains('normal') || text.contains('normale') || text.contains('عادية')) {
      return 'normale';
    }
    if (text.contains('combination') || text.contains('mixte') || text.contains('مختلطة')) {
      return 'mixte';
    }
    return text;
  }

  Future<void> saveCurrentUserSkinProfile({
    required String skinType,
    List<String> concerns = const <String>[],
    String source = 'skin_scan',
  }) async {
    await _skinProfileRef.set({
      'skinType': normalizeSkinType(skinType),
      'rawSkinType': skinType,
      'concerns': concerns,
      'source': source,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> getCurrentUserSkinProfile() async {
    if (_auth.currentUser == null) return null;
    final doc = await _skinProfileRef.get();
    return doc.data();
  }

  Future<String> getCurrentUserSkinType({String fallback = 'mixte'}) async {
    final data = await getCurrentUserSkinProfile();
    final skinType = data?['skinType']?.toString();
    if (skinType == null || skinType.trim().isEmpty) return fallback;
    return normalizeSkinType(skinType);
  }

  Stream<Map<String, dynamic>?> watchCurrentUserSkinProfile() {
    if (_auth.currentUser == null) return Stream.value(null);
    return _skinProfileRef.snapshots().map((doc) => doc.data());
  }

  Stream<String> watchCurrentUserSkinType({String fallback = 'mixte'}) {
    if (_auth.currentUser == null) return Stream.value(fallback);
    return watchCurrentUserSkinProfile().map((data) {
      final skinType = data?['skinType']?.toString();
      if (skinType == null || skinType.trim().isEmpty) return fallback;
      return normalizeSkinType(skinType);
    });
  }

  Future<List<ProductItem>> getRecommendedProducts({
    required String skinType,
    required String type,
    int limit = 20,
  }) {
    return _content.productsOnce(
      skinType: normalizeSkinType(skinType),
      type: type,
      limit: limit,
    );
  }

  Stream<List<ProductItem>> watchRecommendedProducts({
    required String skinType,
    required String type,
    int limit = 20,
  }) {
    return _content.products(
      skinType: normalizeSkinType(skinType),
      type: type,
      limit: limit,
    );
  }

  Future<List<ProductItem>> getRecommendedProductsForCurrentUser({
    required String type,
    int limit = 20,
    String fallbackSkinType = 'mixte',
  }) async {
    final skinType = await getCurrentUserSkinType(fallback: fallbackSkinType);
    return getRecommendedProducts(
      skinType: skinType,
      type: type,
      limit: limit,
    );
  }

  Stream<List<ProductItem>> watchRecommendedProductsForCurrentUser({
    required String type,
    int limit = 20,
    String fallbackSkinType = 'mixte',
  }) async* {
    await for (final skinType in watchCurrentUserSkinType(fallback: fallbackSkinType)) {
      yield* watchRecommendedProducts(
        skinType: skinType,
        type: type,
        limit: limit,
      );
    }
  }

  Future<List<ProductItem>> getSkincareProducts({
    required String skinType,
    int limit = 20,
  }) {
    return getRecommendedProducts(
      skinType: skinType,
      type: 'skincare',
      limit: limit,
    );
  }

  Future<List<ProductItem>> getMakeupProducts({
    required String skinType,
    int limit = 20,
  }) {
    return getRecommendedProducts(
      skinType: skinType,
      type: 'makeup',
      limit: limit,
    );
  }

  Future<List<ProductItem>> getSkincareProductsForCurrentUser({
    int limit = 20,
    String fallbackSkinType = 'mixte',
  }) {
    return getRecommendedProductsForCurrentUser(
      type: 'skincare',
      limit: limit,
      fallbackSkinType: fallbackSkinType,
    );
  }

  Future<List<ProductItem>> getMakeupProductsForCurrentUser({
    int limit = 20,
    String fallbackSkinType = 'mixte',
  }) {
    return getRecommendedProductsForCurrentUser(
      type: 'makeup',
      limit: limit,
      fallbackSkinType: fallbackSkinType,
    );
  }

  Stream<List<ProductItem>> watchSkincareProductsForCurrentUser({
    int limit = 20,
    String fallbackSkinType = 'mixte',
  }) {
    return watchRecommendedProductsForCurrentUser(
      type: 'skincare',
      limit: limit,
      fallbackSkinType: fallbackSkinType,
    );
  }

  Stream<List<ProductItem>> watchMakeupProductsForCurrentUser({
    int limit = 20,
    String fallbackSkinType = 'mixte',
  }) {
    return watchRecommendedProductsForCurrentUser(
      type: 'makeup',
      limit: limit,
      fallbackSkinType: fallbackSkinType,
    );
  }

  Stream<List<ProductItem>> userRoutineProducts() {
    if (_auth.currentUser == null) return Stream.value(const <ProductItem>[]);

    return _db
        .collection('users')
        .doc(_uid)
        .collection('routine_products')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ProductItem.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  Future<void> addProductToUserRoutine(ProductItem product) async {
    await _db
        .collection('users')
        .doc(_uid)
        .collection('routine_products')
        .doc(product.id)
        .set({
      ...product.toRoutineMap(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> removeProductFromUserRoutine(String productId) async {
    await _db
        .collection('users')
        .doc(_uid)
        .collection('routine_products')
        .doc(productId)
        .delete();
  }

  Future<void> saveScanHistory(ProductItem product) async {
    await _db.collection('users').doc(_uid).collection('history').add({
      'type': 'product_scan',
      'productId': product.id,
      'name': product.name,
      'brand': product.brand,
      'category': product.category,
      'imageUrl': product.imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
