import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

/// Downscales and re-encodes a picked photo to a temp JPEG, longest side
/// [maxSide]. Returns null on any failure so the caller can fall back to
/// uploading the original — a bigger upload beats no upload.
///
/// One implementation for every user photo that leaves the device (cat
/// profile photos, carnet attachments): the size ceiling is the only thing
/// that differs, and EXIF — which carries location — is always stripped.
Future<File?> compressToJpeg(
  File source, {
  required int maxSide,
  int quality = 85,
  String prefix = 'upload',
}) async {
  try {
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final target = '${Directory.systemTemp.path}/${prefix}_$stamp.jpg';
    final result = await FlutterImageCompress.compressAndGetFile(
      source.path,
      target,
      minWidth: maxSide,
      minHeight: maxSide,
      quality: quality,
      format: CompressFormat.jpeg,
      autoCorrectionAngle: true,
      keepExif: false,
    );
    return result == null ? null : File(result.path);
  } catch (e) {
    debugPrint('Error compressing image: $e');
    return null;
  }
}
