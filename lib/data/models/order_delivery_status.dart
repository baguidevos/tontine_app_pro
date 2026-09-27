import 'package:flutter/material.dart';
import 'package:paya_app/core/theme/app_theme.dart';

enum OrderDeliveryStatus {
  received,
  confirmed,
  paid,
  processing,
  delivered,
  undelivered;

  String get code {
    switch (this) {
      case OrderDeliveryStatus.received:
        return 'received';
      case OrderDeliveryStatus.confirmed:
        return 'confirmed';
      case OrderDeliveryStatus.paid:
        return 'paid';
      case OrderDeliveryStatus.processing:
        return 'processing';
      case OrderDeliveryStatus.delivered:
        return 'delivered';
      case OrderDeliveryStatus.undelivered:
        return 'undelivered';
    }
  }

  String get label {
    switch (this) {
      case OrderDeliveryStatus.received:
        return 'Reçue';
      case OrderDeliveryStatus.confirmed:
        return 'Confirmée';
      case OrderDeliveryStatus.paid:
        return 'Payée';
      case OrderDeliveryStatus.processing:
        return 'Produit disponible';
      case OrderDeliveryStatus.delivered:
        return 'Livrée';
      case OrderDeliveryStatus.undelivered:
        return 'Non livrée';
    }
  }

  String get shortLabel {
    switch (this) {
      case OrderDeliveryStatus.received:
        return 'Reçue';
      case OrderDeliveryStatus.confirmed:
        return 'Confirmée';
      case OrderDeliveryStatus.paid:
        return 'Payée';
      case OrderDeliveryStatus.processing:
        return 'Disponible';
      case OrderDeliveryStatus.delivered:
        return 'Livrée';
      case OrderDeliveryStatus.undelivered:
        return 'Non livrée';
    }
  }

  String get actionLabel {
    switch (this) {
      case OrderDeliveryStatus.received:
        return 'Marquer reçue';
      case OrderDeliveryStatus.confirmed:
        return 'Confirmer la commande';
      case OrderDeliveryStatus.paid:
        return 'Marquer payée';
      case OrderDeliveryStatus.processing:
        return 'Marquer disponible (en traitement)';
      case OrderDeliveryStatus.delivered:
        return 'Marquer comme livrée';
      case OrderDeliveryStatus.undelivered:
        return 'Marquer non livrée';
    }
  }

  IconData get icon {
    switch (this) {
      case OrderDeliveryStatus.received:
        return Icons.inbox_rounded;
      case OrderDeliveryStatus.confirmed:
        return Icons.verified_outlined;
      case OrderDeliveryStatus.paid:
        return Icons.payments_outlined;
      case OrderDeliveryStatus.processing:
        return Icons.inventory_2_outlined;
      case OrderDeliveryStatus.delivered:
        return Icons.check_circle_rounded;
      case OrderDeliveryStatus.undelivered:
        return Icons.cancel_outlined;
    }
  }

  Color get color {
    switch (this) {
      case OrderDeliveryStatus.received:
        return AppTheme.payaBlue;
      case OrderDeliveryStatus.confirmed:
        return const Color(0xFF0288D1);
      case OrderDeliveryStatus.paid:
        return AppTheme.payaGreen;
      case OrderDeliveryStatus.processing:
        return AppTheme.payaOrange;
      case OrderDeliveryStatus.delivered:
        return const Color(0xFF1B5E20);
      case OrderDeliveryStatus.undelivered:
        return AppTheme.softRed;
    }
  }

  int get stepIndex {
    switch (this) {
      case OrderDeliveryStatus.received:
        return 0;
      case OrderDeliveryStatus.confirmed:
        return 1;
      case OrderDeliveryStatus.paid:
        return 2;
      case OrderDeliveryStatus.processing:
        return 3;
      case OrderDeliveryStatus.delivered:
        return 4;
      case OrderDeliveryStatus.undelivered:
        return -1;
    }
  }

  static OrderDeliveryStatus fromString(String? value) {
    if (value == null) return OrderDeliveryStatus.received;
    switch (value.toLowerCase().trim()) {
      case 'confirmed':
        return OrderDeliveryStatus.confirmed;
      case 'paid':
        return OrderDeliveryStatus.paid;
      case 'processing':
      case 'ready':
        return OrderDeliveryStatus.processing;
      case 'delivered':
      case 'completed':
        return OrderDeliveryStatus.delivered;
      case 'undelivered':
      case 'cancelled':
        return OrderDeliveryStatus.undelivered;
      case 'received':
      case 'pending':
      default:
        return OrderDeliveryStatus.received;
    }
  }
}
