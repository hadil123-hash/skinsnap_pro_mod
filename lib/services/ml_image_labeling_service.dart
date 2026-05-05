import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import '../models/skin_analysis_result.dart';

class MLImageLabelingService {
  late final ImageLabeler _labeler;

  MLImageLabelingService({double confidenceThreshold = 0.55}) {
    _labeler = ImageLabeler(
      options: ImageLabelerOptions(confidenceThreshold: confidenceThreshold),
    );
  }

  Future<List<LabelItem>> labelImage(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final rawLabels = await _labeler.processImage(inputImage);

    final items = rawLabels
        .map((l) => LabelItem(label: l.label, confidence: l.confidence))
        .toList()
      ..sort((a, b) => b.confidence.compareTo(a.confidence));

    return items;
  }

  void dispose() => _labeler.close();
}
