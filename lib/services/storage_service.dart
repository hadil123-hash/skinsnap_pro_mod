import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/history_item.dart';
import '../models/skin_analysis_result.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  static const _kHistoryIds = 'history_ids';
  static const _kHistoryPrefix = 'history_item_';
  static const _kResultPrefix = 'result_full_';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>>? get _userHistoryCollection {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    return _db.collection('users').doc(uid).collection('history');
  }

  Future<List<HistoryItem>> loadHistory() async {
    final remote = _userHistoryCollection;
    if (remote != null) {
      try {
        final snapshot = await remote.orderBy('savedAt', descending: true).get();
        return snapshot.docs.map((doc) => _historyItemFromMap(doc.id, doc.data())).toList();
      } catch (_) {
      }
    }

    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_kHistoryIds) ?? [];
    final items = <HistoryItem>[];
    for (final id in ids) {
      final raw = prefs.getString('$_kHistoryPrefix$id');
      if (raw != null) {
        try {
          items.add(HistoryItem.fromJsonString(raw));
        } catch (_) {}
      }
    }
    items.sort((a, b) => b.savedAt.compareTo(a.savedAt));
    return items;
  }

  Future<void> saveResult(SkinAnalysisResult result) async {
    await _saveLocal(result);

    final remote = _userHistoryCollection;
    if (remote == null) return;

    try {
      final item = HistoryItem.fromResult(result);
      await remote.doc(result.id).set({
        ..._historyItemToMap(item),
        'fullResult': result.toJson(),
        'savedAt': Timestamp.fromDate(item.savedAt),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {
    }
  }

  Future<SkinAnalysisResult?> loadFullResult(String id) async {
    final remote = _userHistoryCollection;
    if (remote != null) {
      try {
        final doc = await remote.doc(id).get();
        final data = doc.data();
        final full = data?['fullResult'];
        if (full is Map<String, dynamic>) {
          return SkinAnalysisResult.fromJson(full);
        }
      } catch (_) {}
    }

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_kResultPrefix$id');
    if (raw == null) return null;
    try {
      return SkinAnalysisResult.fromJsonString(raw);
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteResult(String id) async {
    final remote = _userHistoryCollection;
    if (remote != null) {
      try {
        await remote.doc(id).delete();
      } catch (_) {}
    }

    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_kHistoryIds) ?? [];
    ids.remove(id);
    await prefs.setStringList(_kHistoryIds, ids);
    await prefs.remove('$_kHistoryPrefix$id');
    await prefs.remove('$_kResultPrefix$id');
  }

  Future<void> clearAll() async {
    final remote = _userHistoryCollection;
    if (remote != null) {
      try {
        final snapshot = await remote.get();
        final batch = _db.batch();
        for (final doc in snapshot.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      } catch (_) {}
    }

    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_kHistoryIds) ?? [];
    for (final id in ids) {
      await prefs.remove('$_kHistoryPrefix$id');
      await prefs.remove('$_kResultPrefix$id');
    }
    await prefs.remove(_kHistoryIds);
  }

  Future<void> _saveLocal(SkinAnalysisResult result) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_kHistoryIds) ?? [];

    if (!ids.contains(result.id)) ids.insert(0, result.id);
    await prefs.setStringList(_kHistoryIds, ids);

    final item = HistoryItem.fromResult(result);
    await prefs.setString('$_kHistoryPrefix${result.id}', item.toJsonString());
    await prefs.setString('$_kResultPrefix${result.id}', result.toJsonString());
  }

  Map<String, dynamic> _historyItemToMap(HistoryItem item) => {
        'id': item.id,
        'savedAt': Timestamp.fromDate(item.savedAt),
        'imagePath': item.imagePath,
        'skinScore': item.skinScore,
        'scoreLabel': item.scoreLabel,
        'faceDetected': item.faceDetected,
        'topLabels': item.topLabels,
      };

  HistoryItem _historyItemFromMap(String id, Map<String, dynamic> data) {
    final rawDate = data['savedAt'];
    DateTime savedAt;
    if (rawDate is Timestamp) {
      savedAt = rawDate.toDate();
    } else if (rawDate is String) {
      savedAt = DateTime.tryParse(rawDate) ?? DateTime.now();
    } else {
      savedAt = DateTime.now();
    }

    return HistoryItem(
      id: (data['id'] ?? id).toString(),
      savedAt: savedAt,
      imagePath: (data['imagePath'] ?? '').toString(),
      skinScore: data['skinScore'] is num ? (data['skinScore'] as num).round() : 0,
      scoreLabel: (data['scoreLabel'] ?? '').toString(),
      faceDetected: data['faceDetected'] == true,
      topLabels: data['topLabels'] is Iterable
          ? List<String>.from((data['topLabels'] as Iterable).map((e) => e.toString()))
          : const <String>[],
    );
  }
}
