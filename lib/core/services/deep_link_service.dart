import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:paya_app/core/config/api_config.dart';

/// Service gérant les deep links paya:// entrants.
///
/// Schémas supportés :
///   paya://orders/[orderId]          → ouvre OrderDetailsPage
///   paya://orders/[orderId]/tracking → ouvre OrderDetailsPage sur le suivi
///
/// Usage :
///   1. Appeler DeepLinkService.init() dans main() après les autres services.
///   2. Le service écoute le MethodChannel "com.baguidevos.paya/deeplink"
///      que Flutter envoie depuis MainActivity via onNewIntent().
///
/// Note : Le channel est déclenché côté Flutter/Dart via la méthode statique
/// [handleIncomingLink()] lorsque l'app reçoit un Intent (Android) ou un
/// Universal Link (iOS). Côté Android, on expose l'URI via le MethodChannel
/// dans MainActivity.kt — mais pour simplifier, on utilise directement
/// la valeur initiale passée via GetInitialLink pattern (app_links free).
class DeepLinkService extends GetxService {
  static const _channel = MethodChannel('com.baguidevos.paya/deeplink');

  static String? _pendingLink;

  /// Appeler au démarrage pour intercepter le lien initial (cold start).
  @override
  void onInit() {
    super.onInit();
    _listenForLinks();
  }

  void _listenForLinks() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onDeepLink') {
        final link = call.arguments as String?;
        if (link != null) {
          debugPrint('[DeepLinkService] Received: $link');
          _routeDeepLink(link);
        }
      }
    });
  }

  /// Traiter un lien deep link paya:// et naviguer vers la bonne page.
  static void handleIncomingLink(String? link) {
    if (link == null || link.isEmpty) return;
    debugPrint('[DeepLinkService] handleIncomingLink: $link');
    _routeDeepLink(link);
  }

  static void _routeDeepLink(String link) {
    try {
      debugPrint('[DeepLinkService] Routing deep link: $link');
      final uri = Uri.parse(link);
      String? orderId;

      // 1. Schéma personnalisé paya://
      if (uri.scheme == 'paya') {
        // Format A: paya://orders/<id> -> host='orders', pathSegments=['<id>']
        if (uri.host == 'orders' || uri.host == 'order') {
          if (uri.pathSegments.isNotEmpty) {
            orderId = uri.pathSegments.first;
          }
        }
        // Format B: paya:///orders/<id> ou paya://app/orders/<id>
        if (orderId == null && uri.pathSegments.isNotEmpty) {
          final idx = uri.pathSegments.indexOf('orders');
          if (idx != -1 && uri.pathSegments.length > idx + 1) {
            orderId = uri.pathSegments[idx + 1];
          }
        }
        orderId ??= uri.queryParameters['id'] ?? uri.queryParameters['orderId'];
      }

      // 2. Lien HTTPS (ex: https://tontine-pro-97133.web.app/#/orders/details?id=...)
      if (uri.scheme == 'https' || uri.scheme == 'http') {
        // Query param direct (?id=... ou ?orderId=...)
        orderId = uri.queryParameters['id'] ?? uri.queryParameters['orderId'];

        // Fragment Hash Routing (Flutter Web: #/orders/details?id=...)
        if (orderId == null && uri.fragment.isNotEmpty) {
          final frag = uri.fragment.startsWith('/') ? uri.fragment : '/${uri.fragment}';
          final fragUri = Uri.tryParse(frag);
          if (fragUri != null) {
            orderId = fragUri.queryParameters['id'] ?? fragUri.queryParameters['orderId'];
            if (orderId == null && fragUri.pathSegments.isNotEmpty) {
              final idx = fragUri.pathSegments.indexOf('orders');
              if (idx != -1 && fragUri.pathSegments.length > idx + 1) {
                final next = fragUri.pathSegments[idx + 1];
                if (next != 'details' && next != 'create') {
                  orderId = next;
                } else if (next == 'details' && fragUri.pathSegments.length > idx + 2) {
                  orderId = fragUri.pathSegments[idx + 2];
                }
              }
            }
          }
        }

        // Path segment direct: /orders/<id>
        if (orderId == null && uri.pathSegments.isNotEmpty) {
          final idx = uri.pathSegments.indexOf('orders');
          if (idx != -1 && uri.pathSegments.length > idx + 1) {
            final next = uri.pathSegments[idx + 1];
            if (next != 'details' && next != 'create') {
              orderId = next;
            }
          }
        }
      }

      // 3. Fallback regex
      if (orderId == null || orderId.isEmpty) {
        final match = RegExp(r'(?:orders/|orderId=|id=)([0-9a-zA-Z_-]+)').firstMatch(link);
        if (match != null) {
          final candidate = match.group(1);
          if (candidate != null && candidate != 'details' && candidate != 'create') {
            orderId = candidate;
          }
        }
      }

      if (orderId != null && orderId.isNotEmpty) {
        debugPrint('[DeepLinkService] Order ID successfully resolved: $orderId');
        Get.toNamed(
          '/orders/details',
          parameters: {'id': orderId, 'orderId': orderId},
        );
        return;
      }

      debugPrint('[DeepLinkService] Lien non reconnu: $link');
    } catch (e) {
      debugPrint('[DeepLinkService] Erreur parsing deep link: $e');
    }
  }

  /// Stocker un lien reçu avant que le router soit prêt (cold start).
  static void setPendingLink(String link) {
    _pendingLink = link;
  }

  /// Consommer le lien en attente (à appeler depuis SplashPage après init).
  static void consumePendingLink() {
    if (_pendingLink != null) {
      handleIncomingLink(_pendingLink);
      _pendingLink = null;
    }
  }

  /// Générer un deep link paya:// pour une commande donnée.
  static String orderLink(String orderId) => 'paya://orders/$orderId';

  /// Générer un lien universel web HTTPS pour partage WhatsApp.
  static String orderUniversalLink(String orderId) => ApiConfig.buildOrderDeepLink(orderId);
}
