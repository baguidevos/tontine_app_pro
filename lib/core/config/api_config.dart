class ApiConfig {
  /// Base URL de l'API du serveur d'images en ligne.
  /// Modifiable via compilation: --dart-define=IMAGE_SERVER_BASE_URL=https://...
  static const String baseUrl = String.fromEnvironment(
    'IMAGE_SERVER_BASE_URL',
    defaultValue: 'https://imageserver.carics.org/api',
  );

  /// Clé applicative envoyée dans le header X-Application-Key.
  /// Modifiable via compilation: --dart-define=IMAGE_SERVER_APP_KEY=app_...
  static const String applicationKey = String.fromEnvironment(
    'IMAGE_SERVER_APP_KEY',
    defaultValue:
        'app_5581029ffd2adefcaf5578420c4ca69b647fed838b90cf3bf8fc014c19c02175',
  );

  // Endpoints V1
  static String get registerUrl => '$baseUrl/v1/auth/register';
  static String get loginUrl => '$baseUrl/v1/auth/login';
  static String get logoutUrl => '$baseUrl/v1/auth/logout';
  static String get imagesUrl => '$baseUrl/v1/images';
  static String imageUrl(String imageId) => '$baseUrl/v1/images/$imageId';

  /// URL de base de l'application Flutter Web (hébergée sur Firebase Hosting, Vercel, etc.)
  /// Modifiable via compilation: --dart-define=WEB_APP_BASE_URL=https://...
  static const String webAppBaseUrl = String.fromEnvironment(
    'WEB_APP_BASE_URL',
    defaultValue: 'https://tontine-pro-97133.web.app',
  );

  /// Génère l'URL de commande directe d'un produit pour partage WhatsApp
  static String buildOrderShareUrl({
    required String productId,
    required String vendorId,
    String? waveId,
  }) {
    final cleanBase = webAppBaseUrl.endsWith('/')
        ? webAppBaseUrl.substring(0, webAppBaseUrl.length - 1)
        : webAppBaseUrl;

    final queryParams = <String, String>{
      'p': productId,
      'v': vendorId,
      if (waveId != null && waveId.isNotEmpty) 'w': waveId,
    };

    final queryString = queryParams.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    return '$cleanBase/#/order?$queryString';
  }
}
