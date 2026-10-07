import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:paya_app/core/config/api_config.dart';

class SubscriptionPlanModel {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final String price;
  final String currency;
  final int durationInDays;
  final List<String> features;

  SubscriptionPlanModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    required this.price,
    required this.currency,
    required this.durationInDays,
    required this.features,
  });

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String?,
      price: json['price']?.toString() ?? '0.00',
      currency: json['currency'] as String? ?? 'XOF',
      durationInDays: json['duration_in_days'] as int? ?? 30,
      features: (json['features'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}

class SasPayPaymentService extends GetxService {
  final http.Client _client = http.Client();

  /// Récupère la liste des offres d'abonnement actives depuis le backend Laravel.
  Future<List<SubscriptionPlanModel>> fetchPlans() async {
    final url = Uri.parse('${ApiConfig.backendApiUrl}/plans');
    try {
      final response = await _client.get(url, headers: {
        'Accept': 'application/json',
      }).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final list = (decoded['data'] as List<dynamic>?) ?? [];
        return list.map((item) => SubscriptionPlanModel.fromJson(item as Map<String, dynamic>)).toList();
      } else {
        debugPrint('Erreur fetchPlans: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      debugPrint('Exception fetchPlans: $e');
      return [];
    }
  }

  /// Initialise un paiement d'abonnement SasPay (Checkout hébergé ou Softpay push direct).
  Future<Map<String, dynamic>?> initiateSubscriptionCheckout({
    required int planId,
    String flow = 'checkout',
    String? phone,
    String? network,
    String? otp,
    String? returnUrl,
  }) async {
    final url = Uri.parse('${ApiConfig.backendApiUrl}/subscriptions/checkout');
    final payload = {
      'plan_id': planId,
      'flow': flow,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
      if (network != null && network.isNotEmpty) 'network': network,
      if (otp != null && otp.isNotEmpty) 'otp': otp,
      if (returnUrl != null && returnUrl.isNotEmpty) 'return_url': returnUrl,
    };

    try {
      final response = await _client.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 25));

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200 && decoded['success'] == true) {
        return decoded['data'] as Map<String, dynamic>;
      } else {
        final errorMsg = decoded['message'] ?? 'Erreur lors de l\'initiation du paiement';
        Get.snackbar('Erreur de paiement', errorMsg.toString(), snackPosition: SnackPosition.BOTTOM);
        return null;
      }
    } catch (e) {
      debugPrint('Exception initiateSubscriptionCheckout: $e');
      Get.snackbar('Erreur réseau', 'Impossible de contacter le serveur de paiement.', snackPosition: SnackPosition.BOTTOM);
      return null;
    }
  }

  /// Ouvre la page sécurisée de paiement SasPay dans le navigateur ou webview.
  Future<bool> openCheckoutPage(String checkoutUrl) async {
    final uri = Uri.parse(checkoutUrl);
    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar('Erreur', 'Impossible d\'ouvrir la page de paiement.');
        return false;
      }
    } catch (e) {
      debugPrint('Erreur launchUrl: $e');
      return false;
    }
  }

  /// Vérifie le statut d'un paiement en cours.
  Future<Map<String, dynamic>?> verifyPaymentStatus(int paymentId) async {
    final url = Uri.parse('${ApiConfig.backendApiUrl}/subscriptions/status/$paymentId');
    try {
      final response = await _client.get(url, headers: {
        'Accept': 'application/json',
      }).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded['data'] as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      debugPrint('Exception verifyPaymentStatus: $e');
      return null;
    }
  }

  /// Récupère l'abonnement actif pour l'utilisateur courant.
  Future<Map<String, dynamic>?> fetchCurrentSubscription() async {
    final url = Uri.parse('${ApiConfig.backendApiUrl}/subscriptions/current');
    try {
      final response = await _client.get(url, headers: {
        'Accept': 'application/json',
      }).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded['data'] as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      debugPrint('Exception fetchCurrentSubscription: $e');
      return null;
    }
  }
}
