import 'dart:convert';
import 'skin_analysis_result.dart';

class HistoryItem {
  final String id;
  final DateTime savedAt;
  final String imagePath;
  final int skinScore;
  final String scoreLabel;
  final bool faceDetected;
  final List<String> topLabels;

  const HistoryItem({
    required this.id,
    required this.savedAt,
    required this.imagePath,
    required this.skinScore,
    required this.scoreLabel,
    required this.faceDetected,
    required this.topLabels,
  });

  factory HistoryItem.fromResult(SkinAnalysisResult r) {
    final sorted = [...r.imageLabels]
      ..sort((a, b) => b.confidence.compareTo(a.confidence));
    return HistoryItem(
      id: r.id,
      savedAt: r.analyzedAt,
      imagePath: r.imagePath,
      skinScore: r.skinScore,
      scoreLabel: r.scoreLabel,
      faceDetected: r.faceDetected,
      topLabels: sorted.take(3).map((l) => l.label).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'savedAt': savedAt.toIso8601String(),
        'imagePath': imagePath,
        'skinScore': skinScore,
        'scoreLabel': scoreLabel,
        'faceDetected': faceDetected,
        'topLabels': topLabels,
      };

  factory HistoryItem.fromJson(Map<String, dynamic> json) => HistoryItem(
        id: json['id'] as String,
        savedAt: DateTime.parse(json['savedAt'] as String),
        imagePath: json['imagePath'] as String,
        skinScore: json['skinScore'] as int,
        scoreLabel: json['scoreLabel'] as String,
        faceDetected: json['faceDetected'] as bool,
        topLabels: List<String>.from(json['topLabels'] as List),
      );

  String toJsonString() => jsonEncode(toJson());
  factory HistoryItem.fromJsonString(String s) =>
      HistoryItem.fromJson(jsonDecode(s) as Map<String, dynamic>);

  String get formattedDate {
    final d = savedAt;
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/'
        '${d.year}';
  }
}
