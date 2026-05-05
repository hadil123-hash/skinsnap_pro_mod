import 'package:google_mlkit_selfie_segmentation/google_mlkit_selfie_segmentation.dart';

class MLSelfieSegmentationService {
  late final SelfieSegmenter _segmenter;

  MLSelfieSegmentationService() {
    _segmenter = SelfieSegmenter(
      mode: SegmenterMode.single,
      enableRawSizeMask: false,
    );
  }

  Future<SegmentationMask?> segment(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      return await _segmenter.processImage(inputImage);
    } catch (_) {
      return null;
    }
  }

  Future<bool> canSegment(String imagePath) async {
    final mask = await segment(imagePath);
    return mask != null;
  }

  void dispose() => _segmenter.close();
}
