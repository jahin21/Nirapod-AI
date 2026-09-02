import 'dart:convert';
import 'dart:js_interop';

import 'package:image_picker/image_picker.dart';

@JS('nirapodExtractText')
external JSPromise<JSString> _extractText(JSString imageDataUrl);

Future<String> extractTextFromImage(XFile file) async {
  final bytes = await file.readAsBytes();
  final extension = file.name.split('.').last.toLowerCase();
  final mime = extension == 'png'
      ? 'image/png'
      : extension == 'webp'
          ? 'image/webp'
          : 'image/jpeg';
  final dataUrl = 'data:$mime;base64,${base64Encode(bytes)}';
  final result = await _extractText(dataUrl.toJS).toDart;
  return result.toDart.trim();
}
