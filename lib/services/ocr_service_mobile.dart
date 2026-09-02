import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

Future<String> extractTextFromImage(XFile file) async {
  final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
  try {
    final image = InputImage.fromFilePath(file.path);
    final result = await recognizer.processImage(image);
    return result.text.trim();
  } finally {
    await recognizer.close();
  }
}
