import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

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
      final uri = Uri.parse(link);
      if (uri.scheme != 'paya') return;

      final segments = uri.pathSegments;
      // paya://orders/<orderId>
      if (segments.isNotEmpty && segments[0] == 'orders' && segments.length >= 2) {
        final orderId = segments[1];
        // Naviguer vers la page de détail commande avec l'ID
        Get.toNamed('/orders/details', parameters: {'orderId': orderId});
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
}
