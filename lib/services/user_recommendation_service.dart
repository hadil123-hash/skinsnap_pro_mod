import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserRecommendationService {
  UserRecommendationService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  String get _uid {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Utilisateur non connecté');
    }

    return user.uid;
  }

  Future<void> saveSkinProfile({
    required String skinType,
    required List<String> concerns,
  }) async {
    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('skin_profile')
        .doc('profile')
        .set({
      'skinType': skinType,
      'concerns': concerns,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> getSkinProfile() async {
    final doc = await _firestore
        .collection('users')
        .doc(_uid)
        .collection('skin_profile')
        .doc('profile')
        .get();

    return doc.data();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getRecommendedSkincareProducts() {
    return _recommendedProductsByType('skincare');
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getRecommendedMakeupProducts() {
    return _recommendedProductsByType('makeup');
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _recommendedProductsByType(
      String type,
      ) async* {
    final profile = await getSkinProfile();

    final skinType = profile?['skinType']?.toString();

    if (skinType == null || skinType.isEmpty) {
      yield* _firestore
          .collection('products')
          .where('type', isEqualTo: type)
          .snapshots();

      return;
    }

    yield* _firestore
        .collection('products')
        .where('type', isEqualTo: type)
        .where('skinTypes', arrayContains: skinType)
        .snapshots();
  }

  Future<void> addToFavorites({
    required String productId,
    required Map<String, dynamic> productData,
  }) async {
    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('favorites')
        .doc(productId)
        .set({
      ...productData,
      'productId': productId,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> removeFromFavorites(String productId) async {
    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('favorites')
        .doc(productId)
        .delete();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> favorites() {
    return _firestore
        .collection('users')
        .doc(_uid)
        .collection('favorites')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> addToRoutine({
    required String productId,
    required Map<String, dynamic> productData,
  }) async {
    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('routine_products')
        .doc(productId)
        .set({
      ...productData,
      'productId': productId,
      'createdAt': FieldValue.serverTimestamp(),
      'isDone': false,
    }, SetOptions(merge: true));
  }

  Future<void> removeFromRoutine(String productId) async {
    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('routine_products')
        .doc(productId)
        .delete();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> routineProducts() {
    return _firestore
        .collection('users')
        .doc(_uid)
        .collection('routine_products')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> addToHistory({
    required String title,
    required String type,
    required Map<String, dynamic> data,
  }) async {
    await _firestore
        .collection('users')
        .doc(_uid)
        .collection('history')
        .add({
      'title': title,
      'type': type,
      'data': data,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> history() {
    return _firestore
        .collection('users')
        .doc(_uid)
        .collection('history')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}