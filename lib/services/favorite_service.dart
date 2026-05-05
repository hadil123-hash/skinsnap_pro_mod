import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/firestore_content.dart';

class FavoriteService {
  FavoriteService({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _db = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  String? get _uid => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>>? get _favoritesRef {
    final uid = _uid;
    if (uid == null) return null;
    return _db.collection('users').doc(uid).collection('favorites');
  }

  Stream<List<ProductItem>> watchFavorites() {
    final ref = _favoritesRef;
    if (ref == null) return Stream.value(const <ProductItem>[]);

    return ref.orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => ProductItem.fromMap(doc.id, doc.data())).toList();
    });
  }

  Future<List<ProductItem>> loadFavorites() async {
    final ref = _favoritesRef;
    if (ref == null) return const <ProductItem>[];

    final snapshot = await ref.orderBy('createdAt', descending: true).get();
    return snapshot.docs.map((doc) => ProductItem.fromMap(doc.id, doc.data())).toList();
  }

  Future<bool> isFavorite(String productId) async {
    final ref = _favoritesRef;
    if (ref == null) return false;
    final doc = await ref.doc(productId).get();
    return doc.exists;
  }

  Future<bool> toggle(ProductItem product) async {
    final ref = _favoritesRef;
    if (ref == null) throw StateError('Utilisateur non connecté.');

    final doc = ref.doc(product.id);
    final existing = await doc.get();

    if (existing.exists) {
      await doc.delete();
      return false;
    }

    await doc.set({
      ...product.toRoutineMap(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    return true;
  }
}
