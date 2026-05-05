import 'dart:convert';

class SkinAnalysisResult {
  final String id;
  final DateTime analyzedAt;
  final String imagePath;
  final String? analysisNote;
  final bool demoMode;

  final bool faceDetected;
  final double? smileProbability;
  final double? leftEyeOpenProb;
  final double? rightEyeOpenProb;
  final double? headEulerAngleY;

  final List<LabelItem> imageLabels;
  final bool segmentationDone;
  final String? detectedLanguage;
  final double? langConfidence;
  final int skinScore;

  const SkinAnalysisResult({
    required this.id,
    required this.analyzedAt,
    required this.imagePath,
    this.analysisNote,
    this.demoMode = false,
    required this.faceDetected,
    this.smileProbability,
    this.leftEyeOpenProb,
    this.rightEyeOpenProb,
    this.headEulerAngleY,
    required this.imageLabels,
    required this.segmentationDone,
    this.detectedLanguage,
    this.langConfidence,
    required this.skinScore,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'analyzedAt': analyzedAt.toIso8601String(),
        'imagePath': imagePath,
        'analysisNote': analysisNote,
        'demoMode': demoMode,
        'faceDetected': faceDetected,
        'smileProbability': smileProbability,
        'leftEyeOpenProb': leftEyeOpenProb,
        'rightEyeOpenProb': rightEyeOpenProb,
        'headEulerAngleY': headEulerAngleY,
        'imageLabels': imageLabels.map((label) => label.toJson()).toList(),
        'segmentationDone': segmentationDone,
        'detectedLanguage': detectedLanguage,
        'langConfidence': langConfidence,
        'skinScore': skinScore,
      };

  factory SkinAnalysisResult.fromJson(Map<String, dynamic> json) =>
      SkinAnalysisResult(
        id: json['id'] as String,
        analyzedAt: DateTime.parse(json['analyzedAt'] as String),
        imagePath: json['imagePath'] as String,
        analysisNote: json['analysisNote'] as String?,
        demoMode: json['demoMode'] as bool? ?? false,
        faceDetected: json['faceDetected'] as bool,
        smileProbability: (json['smileProbability'] as num?)?.toDouble(),
        leftEyeOpenProb: (json['leftEyeOpenProb'] as num?)?.toDouble(),
        rightEyeOpenProb: (json['rightEyeOpenProb'] as num?)?.toDouble(),
        headEulerAngleY: (json['headEulerAngleY'] as num?)?.toDouble(),
        imageLabels: (json['imageLabels'] as List<dynamic>)
            .map((e) => LabelItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        segmentationDone: json['segmentationDone'] as bool,
        detectedLanguage: json['detectedLanguage'] as String?,
        langConfidence: (json['langConfidence'] as num?)?.toDouble(),
        skinScore: json['skinScore'] as int,
      );

  String toJsonString() => jsonEncode(toJson());

  factory SkinAnalysisResult.fromJsonString(String value) =>
      SkinAnalysisResult.fromJson(jsonDecode(value) as Map<String, dynamic>);

  String get scoreLabel {
    if (skinScore >= 80) return 'Excellent';
    if (skinScore >= 60) return 'Bon';
    if (skinScore >= 40) return 'Passable';
    return 'A ameliorer';
  }

  String get formattedDate {
    final d = analyzedAt;
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/'
        '${d.year}  ${d.hour.toString().padLeft(2, '0')}:'
        '${d.minute.toString().padLeft(2, '0')}';
  }
}

class LabelItem {
  final String label;
  final double confidence;

  const LabelItem({required this.label, required this.confidence});

  Map<String, dynamic> toJson() => {
        'label': label,
        'confidence': confidence,
      };

  factory LabelItem.fromJson(Map<String, dynamic> json) => LabelItem(
        label: json['label'] as String,
        confidence: (json['confidence'] as num).toDouble(),
      );

  String get percentText => '${(confidence * 100).toStringAsFixed(0)}%';
}
