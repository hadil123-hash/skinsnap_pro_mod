import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class MLFaceDetectionService {
  late final FaceDetector _detector;

  MLFaceDetectionService() {
    _detector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: true,
        enableLandmarks: true,
        enableTracking: true,
        performanceMode: FaceDetectorMode.accurate,
      ),
    );
  }

  Future<List<Face>> detectFaces(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    return await _detector.processImage(inputImage);
  }

  Future<Face?> detectPrimaryFace(String imagePath) async {
    final faces = await detectFaces(imagePath);
    if (faces.isEmpty) return null;
    faces.sort((a, b) => (b.boundingBox.width * b.boundingBox.height)
        .compareTo(a.boundingBox.width * a.boundingBox.height));
    return faces.first;
  }

  Map<String, dynamic> summarize(Face face) => {
        'smileProbability': face.smilingProbability,
        'leftEyeOpenProb': face.leftEyeOpenProbability,
        'rightEyeOpenProb': face.rightEyeOpenProbability,
        'headEulerAngleY': face.headEulerAngleY,
        'headEulerAngleZ': face.headEulerAngleZ,
        'trackingId': face.trackingId,
      };

  void dispose() => _detector.close();
}
