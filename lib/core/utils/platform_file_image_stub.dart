import 'package:flutter/widgets.dart';

Widget buildPlatformFileImage({
  required String path,
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  Widget Function(BuildContext, Object, StackTrace?)? errorBuilder,
}) {
  // On Web, local file paths are not supported
  return errorBuilder?.call(
        // ignore: avoid_annotating_with_dynamic
        null as dynamic,
        'File image not supported on web',
        null,
      ) ??
      const SizedBox.shrink();
}

bool hasValidPlatformFile(String? path) {
  return false;
}
