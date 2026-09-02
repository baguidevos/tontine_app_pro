import 'dart:io';
import 'package:flutter/foundation.dart';

class DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        return kDebugMode &&
            (host == 'imageserver.test' ||
                host == 'api.carics.org' ||
                host == '10.0.2.2' ||
                host == 'localhost' ||
                host == '127.0.0.1');
      };
  }
}

void setupDevHttpOverrides() {
  if (kDebugMode) {
    HttpOverrides.global = DevHttpOverrides();
  }
}
