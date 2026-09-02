import 'dart:io';
import 'package:flutter/widgets.dart';

Widget buildPlatformFileImage({
  required String path,
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  Widget Function(BuildContext, Object, StackTrace?)? errorBuilder,
}) {
  return Image.file(
    File(path),
    width: width,
    height: height,
    fit: fit,
    errorBuilder: errorBuilder,
  );
}

bool hasValidPlatformFile(String? path) {
  if (path == null || path.isEmpty) return false;
  try {
    final file = File(path);
    return file.existsSync();
  } catch (_) {
    return false;
  }
}
