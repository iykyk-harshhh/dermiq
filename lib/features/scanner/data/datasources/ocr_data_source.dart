import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// Extracts raw text from an image. Abstracted so the repository never touches
/// ML Kit directly (swappable for a cloud OCR backend in tests/prod).
abstract interface class OcrDataSource {
  Future<String> recognizeText(String imagePath);
}

/// On-device OCR using Google ML Kit (free, offline, no API key).
class MlKitOcrDataSource implements OcrDataSource {
  MlKitOcrDataSource({TextRecognizer? recognizer})
      : _recognizer =
            recognizer ?? TextRecognizer(script: TextRecognitionScript.latin);

  final TextRecognizer _recognizer;

  @override
  Future<String> recognizeText(String imagePath) async {
    final input = InputImage.fromFilePath(imagePath);
    final result = await _recognizer.processImage(input);
    return result.text;
  }

  /// Release the native recognizer. Call from the owning provider's onDispose.
  Future<void> dispose() => _recognizer.close();
}
