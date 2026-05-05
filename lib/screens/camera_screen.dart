import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/skin_analysis_result.dart';
import '../providers/app_provider.dart';
import '../services/ml_face_detection_service.dart';
import '../services/ml_image_labeling_service.dart';
import '../services/ml_language_detection_service.dart';
import '../services/ml_selfie_segmentation_service.dart';
import '../services/sound_service.dart';
import '../utils/constants.dart';
import '../widgets/beauty_ui.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/path_image.dart';
import 'result_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final _faceService = MLFaceDetectionService();
  final _labelService = MLImageLabelingService();
  final _segService = MLSelfieSegmentationService();
  final _langService = MLLanguageDetectionService();
  final _sound = SoundService();
  final _noteController = TextEditingController();

  XFile? _imageFile;
  bool _analyzing = false;
  String _loadingMsg = 'Analyse en cours...';

  @override
  void dispose() {
    _noteController.dispose();
    _faceService.dispose();
    _labelService.dispose();
    _segService.dispose();
    _langService.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: source, imageQuality: 90);
    if (file == null) return;
    setState(() => _imageFile = file);
    await _sound.playClick();
  }

  ({String langCode, double confidence})? _detectLanguageForWeb(String text) {
    if (text.trim().isEmpty) return null;
    final value = text.trim().toLowerCase();
    if (RegExp(r'[\u0600-\u06FF]').hasMatch(value)) {
      return (langCode: 'ar', confidence: 0.82);
    }
    if (RegExp(r'[éèàùâêîôûç]|bonjour|peau|rougeur|hydrat').hasMatch(value)) {
      return (langCode: 'fr', confidence: 0.76);
    }
    return (langCode: 'en', confidence: 0.72);
  }

  List<LabelItem> _buildWebLabels(String note) {
    final labels = <LabelItem>[
      const LabelItem(label: 'Selfie', confidence: 0.93),
      const LabelItem(label: 'Portrait', confidence: 0.86),
      const LabelItem(label: 'Skin care', confidence: 0.74),
    ];
    final lower = note.toLowerCase();
    if (lower.contains('dry') || lower.contains('sèche') || lower.contains('sec')) {
      labels.add(const LabelItem(label: 'Dryness', confidence: 0.65));
    }
    if (lower.contains('red') || lower.contains('rouge')) {
      labels.add(const LabelItem(label: 'Redness', confidence: 0.62));
    }
    return labels;
  }

  int _computeScore({
    required bool faceDetected,
    required double smileProb,
    required int labelsCount,
    required bool segDone,
  }) {
    var score = 0;
    if (faceDetected) score += 40;
    if (smileProb > 0.5) score += 20;
    score += labelsCount.clamp(0, 5) * 6;
    if (segDone) score += 10;
    return score.clamp(0, 100);
  }

  Future<SkinAnalysisResult> _runWebDemoAnalysis(String path, String note) async {
    final labels = _buildWebLabels(note);
    final langResult = _detectLanguageForWeb(note);
    final score = _computeScore(
      faceDetected: true,
      smileProb: 0.55,
      labelsCount: labels.length,
      segDone: true,
    );

    return SkinAnalysisResult(
      id: const Uuid().v4(),
      analyzedAt: DateTime.now(),
      imagePath: path,
      analysisNote: note.isEmpty ? null : note,
      demoMode: true,
      faceDetected: true,
      smileProbability: 0.55,
      leftEyeOpenProb: 0.78,
      rightEyeOpenProb: 0.81,
      headEulerAngleY: 0,
      imageLabels: labels,
      segmentationDone: true,
      detectedLanguage: langResult?.langCode,
      langConfidence: langResult?.confidence,
      skinScore: score,
    );
  }

  Future<void> _analyze() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choisissez ou prenez une photo avant l’analyse.')),
      );
      return;
    }

    final app = context.read<AppProvider>();
    _sound.configure(sound: app.soundOn, vibration: app.vibrationOn);

    setState(() {
      _analyzing = true;
      _loadingMsg = 'Analyse de la peau...';
    });

    try {
      final path = _imageFile!.path;
      final note = _noteController.text.trim();
      SkinAnalysisResult result;

      if (kIsWeb) {
        result = await _runWebDemoAnalysis(path, note);
      } else {
        setState(() => _loadingMsg = 'Détection du visage...');
        final face = await _faceService.detectPrimaryFace(path);

        setState(() => _loadingMsg = 'Lecture de l’image...');
        final labels = await _labelService.labelImage(path);

        setState(() => _loadingMsg = 'Segmentation selfie...');
        final segDone = await _segService.canSegment(path);

        setState(() => _loadingMsg = 'Analyse de la note...');
        final langResult = note.isEmpty ? null : await _langService.identify(note);

        final score = _computeScore(
          faceDetected: face != null,
          smileProb: face?.smilingProbability ?? 0,
          labelsCount: labels.length,
          segDone: segDone,
        );

        result = SkinAnalysisResult(
          id: const Uuid().v4(),
          analyzedAt: DateTime.now(),
          imagePath: path,
          analysisNote: note.isEmpty ? null : note,
          faceDetected: face != null,
          smileProbability: face?.smilingProbability,
          leftEyeOpenProb: face?.leftEyeOpenProbability,
          rightEyeOpenProb: face?.rightEyeOpenProbability,
          headEulerAngleY: face?.headEulerAngleY,
          imageLabels: labels,
          segmentationDone: segDone,
          detectedLanguage: langResult?.langCode,
          langConfidence: langResult?.confidence,
          skinScore: score,
        );
      }

      await _sound.feedbackSuccess();
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ResultScreen(result: result)),
      );
    } catch (_) {
      await _sound.feedbackError();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur pendant l’analyse. Réessayez avec une photo claire.'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _analyzing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BeautyGradientBackground(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BeautyCircleIcon(
                      icon: Icons.arrow_back_ios_new_rounded,
                      size: 44,
                      onTap: () => Navigator.pop(context),
                    ),
                    const SizedBox(height: 18),
                    const GradientText(
                      'Depuis un selfie',
                      style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 18),
                    Center(
                      child: BeautyCard(
                        color: AppColors.hotPink,
                        radius: 34,
                        padding: const EdgeInsets.all(22),
                        child: Column(
                          children: [
                            const Text(
                              'Vous êtes superbe 🔥',
                              style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 18),
                            _PhotoPreview(file: _imageFile),
                            const SizedBox(height: 22),
                            const Text(
                              'Votre analyse de peau prendra quelques instants',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white, fontSize: 21, height: 1.18, fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Nos conseils ne remplacent pas un dermatologue qualifié.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white70, height: 1.45, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 18),
                            TextField(
                              controller: _noteController,
                              minLines: 2,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                hintText: 'Note optionnelle : peau sèche, rougeurs...',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(borderSide: BorderSide.none),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: _SourceButton(
                            label: 'Caméra',
                            icon: Icons.photo_camera_rounded,
                            onTap: () => _pick(ImageSource.camera),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SourceButton(
                            label: 'Galerie',
                            icon: Icons.photo_library_rounded,
                            onTap: () => _pick(ImageSource.gallery),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    GradientButton(
                      label: 'Analyser ma peau maintenant',
                      icon: Icons.auto_awesome_rounded,
                      onTap: _analyze,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_analyzing) LoadingOverlay(message: _loadingMsg),
        ],
      ),
    );
  }
}

class _PhotoPreview extends StatelessWidget {
  const _PhotoPreview({required this.file});
  final XFile? file;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: file == null ? -.10 : 0,
      child: Container(
        width: 176,
        height: 210,
        decoration: BoxDecoration(
          color: AppColors.blush,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white, width: 3),
        ),
        clipBehavior: Clip.antiAlias,
        child: file == null
            ? const Icon(Icons.face_retouching_natural_rounded,
                size: 98, color: AppColors.hotPink)
            : PathImage(path: file!.path, fit: BoxFit.cover, width: 176, height: 210),
      ),
    );
  }
}

class _SourceButton extends StatelessWidget {
  const _SourceButton({required this.label, required this.icon, required this.onTap});
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: BeautyCard(
        padding: const EdgeInsets.symmetric(vertical: 16),
        radius: 18,
        child: Column(
          children: [
            Icon(icon, color: AppColors.hotPink, size: 28),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }
}
