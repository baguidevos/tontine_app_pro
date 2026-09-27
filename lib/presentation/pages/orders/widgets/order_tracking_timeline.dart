import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paya_app/core/services/whatsapp_service.dart';
import 'package:paya_app/core/services/auth_service.dart';
import 'package:paya_app/core/theme/app_theme.dart';
import 'package:paya_app/data/models/order_model.dart';
import 'package:paya_app/data/models/order_delivery_status.dart';
import 'package:paya_app/data/models/customer_model.dart';
import 'package:paya_app/presentation/controllers/order_controller.dart';
import 'package:paya_app/presentation/controllers/wave_controller.dart';

class OrderTrackingTimeline extends StatelessWidget {
  final OrderModel order;
  final CustomerModel? customer;
  final VoidCallback onOrderUpdated;

  const OrderTrackingTimeline({
    super.key,
    required this.order,
    this.customer,
    required this.onOrderUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final currentStatus = order.trackingStatus;
    final isUndelivered = currentStatus == OrderDeliveryStatus.undelivered;
    final isDelivered = currentStatus == OrderDeliveryStatus.delivered;

    final steps = [
      {'status': OrderDeliveryStatus.received, 'title': 'Reçue'},
      {'status': OrderDeliveryStatus.confirmed, 'title': 'Confirmée'},
      {'status': OrderDeliveryStatus.paid, 'title': 'Payée'},
      {'status': OrderDeliveryStatus.processing, 'title': 'Disponible'},
      {'status': OrderDeliveryStatus.delivered, 'title': 'Livrée'},
    ];

    final currentStepIdx = currentStatus.stepIndex;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.slate200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: currentStatus.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      currentStatus.icon,
                      color: currentStatus.color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Suivi de la commande',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.slate900,
                        ),
                      ),
                      Text(
                        'Statut actuel : ${currentStatus.label}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: currentStatus.color,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: AppTheme.slate500, size: 20),
                tooltip: 'Gérer les modèles WhatsApp',
                onPressed: () => Get.toNamed('/whatsapp/templates'),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Stepper bar
          if (!isUndelivered) ...[
            Row(
              children: List.generate(steps.length * 2 - 1, (index) {
                if (index.isOdd) {
                  final stepBeforeIdx = index ~/ 2;
                  final isPassed = currentStepIdx > stepBeforeIdx;
                  return Expanded(
                    child: Container(
                      height: 3,
                      color: isPassed ? AppTheme.payaGreen : AppTheme.slate200,
                    ),
                  );
                } else {
                  final stepIdx = index ~/ 2;
                  final isCompleted = currentStepIdx > stepIdx;
                  final isCurrent = currentStepIdx == stepIdx;

                  Color dotColor;
                  Widget iconWidget;

                  if (isCompleted) {
                    dotColor = AppTheme.payaGreen;
                    iconWidget = const Icon(Icons.check, size: 12, color: Colors.white);
                  } else if (isCurrent) {
                    dotColor = currentStatus.color;
                    iconWidget = Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    );
                  } else {
                    dotColor = AppTheme.slate200;
                    iconWidget = Text(
                      '${stepIdx + 1}',
                      style: const TextStyle(fontSize: 10, color: AppTheme.slate500, fontWeight: FontWeight.bold),
                    );
                  }

                  return Column(
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: dotColor,
                          shape: BoxShape.circle,
                          boxShadow: isCurrent
                              ? [
                                  BoxShadow(
                                    color: dotColor.withValues(alpha: 0.35),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: iconWidget,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        steps[stepIdx]['title'] as String,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w500,
                          color: isCurrent ? AppTheme.slate900 : AppTheme.slate500,
                        ),
                      ),
                    ],
                  );
                }
              }),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.softRed.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.softRed.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.warning_amber_rounded, color: AppTheme.softRed, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Cette commande est marquée comme non livrée ou reportée.',
                      style: TextStyle(fontSize: 12, color: AppTheme.softRed, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Primary WhatsApp Notification Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () => _openWhatsAppNotification(context, currentStatus),
              icon: const Icon(Icons.chat_bubble_rounded, size: 18),
              label: Text(
                'Envoyer notification WhatsApp (${currentStatus.shortLabel})',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366), // WhatsApp brand green
                foregroundColor: Colors.white,
                elevation: 2,
                shadowColor: const Color(0xFF25D366).withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Quick Stage Change Actions
          Row(
            children: [
              // Next Stage CTA
              if (!isDelivered) ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showChangeStatusDialog(context),
                    icon: const Icon(Icons.update_rounded, size: 16),
                    label: const Text('Changer d\'étape'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.deepBlue,
                      side: const BorderSide(color: AppTheme.deepBlue, width: 1.2),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ] else ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showChangeStatusDialog(context),
                    icon: const Icon(Icons.edit_note_rounded, size: 16),
                    label: const Text('Modifier statut'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.slate700,
                      side: const BorderSide(color: AppTheme.slate300),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],

              // Mark Undelivered or Mark Delivered
              if (currentStatus != OrderDeliveryStatus.undelivered && !isDelivered)
                IconButton(
                  onPressed: () => _updateStatus(context, OrderDeliveryStatus.undelivered),
                  tooltip: 'Marquer non livrée',
                  icon: const Icon(Icons.cancel_outlined, color: AppTheme.softRed, size: 22),
                  splashRadius: 22,
                )
              else if (isUndelivered)
                IconButton(
                  onPressed: () => _updateStatus(context, OrderDeliveryStatus.received),
                  tooltip: 'Relancer le suivi',
                  icon: const Icon(Icons.replay_rounded, color: AppTheme.payaGreen, size: 22),
                  splashRadius: 22,
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showChangeStatusDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.65,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (_, scrollController) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.slate300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const Text(
                  'Sélectionner la nouvelle étape',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.slate900,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Mettez à jour le suivi pour notifier le client sur WhatsApp',
                  style: TextStyle(fontSize: 12, color: AppTheme.slate500),
                ),
                const SizedBox(height: 16),
                ...OrderDeliveryStatus.values.map((s) {
                  final isSelected = order.trackingStatus == s;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? s.color.withValues(alpha: 0.08) : AppTheme.slate50,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? s.color : AppTheme.slate200,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: s.color.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(s.icon, color: s.color, size: 20),
                      ),
                      title: Text(
                        s.label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected ? s.color : AppTheme.slate900,
                        ),
                      ),
                      subtitle: Text(
                        s.actionLabel,
                        style: const TextStyle(fontSize: 11, color: AppTheme.slate500),
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check_circle_rounded, color: s.color)
                          : const Icon(Icons.chevron_right_rounded, color: AppTheme.slate400),
                      onTap: () {
                        Navigator.pop(ctx);
                        _updateStatus(context, s);
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
          ),
        );
      },
    );
  }

  Future<void> _updateStatus(
    BuildContext context,
    OrderDeliveryStatus newStatus,
  ) async {
    final orderController = Get.find<OrderController>();

    final updatedOrder = order.copyWith(
      deliveryStatus: newStatus.code,
      deliveryStatusUpdatedAt: DateTime.now(),
      status: newStatus == OrderDeliveryStatus.delivered
          ? 'completed'
          : (newStatus == OrderDeliveryStatus.undelivered ? 'cancelled' : order.status),
    );

    await orderController.updateOrder(updatedOrder);
    onOrderUpdated();

    // Proposer l'envoi immédiat de la notification WhatsApp correspondante
    if (context.mounted) {
      _openWhatsAppNotification(context, newStatus);
    }
  }

  void _openWhatsAppNotification(
    BuildContext context,
    OrderDeliveryStatus status,
  ) {
    if (customer == null || customer!.phone.trim().isEmpty) {
      Get.snackbar(
        'Numéro manquant',
        'Aucun numéro de téléphone associé à ce client',
        backgroundColor: AppTheme.softRed,
        colorText: Colors.white,
      );
      return;
    }

    final whatsAppService = Get.find<WhatsAppService>();
    final authService = Get.find<AuthService>();
    final waveController = Get.find<WaveController>();

    String templateKey;
    switch (status) {
      case OrderDeliveryStatus.confirmed:
        templateKey = WhatsAppService.keyConfirmation;
        break;
      case OrderDeliveryStatus.paid:
        templateKey = WhatsAppService.keyPaid;
        break;
      case OrderDeliveryStatus.processing:
        templateKey = WhatsAppService.keyProcessing;
        break;
      case OrderDeliveryStatus.delivered:
        templateKey = WhatsAppService.keyDelivered;
        break;
      case OrderDeliveryStatus.undelivered:
        templateKey = WhatsAppService.keyUndelivered;
        break;
      case OrderDeliveryStatus.received:
        templateKey = WhatsAppService.keyConfirmation;
        break;
    }

    final vendorName = authService.currentVendor.value?.businessName;
    String? waveName;
    if (order.waveId != null) {
      final wave = waveController.waves.firstWhereOrNull((w) => w.id == order.waveId);
      waveName = wave?.name;
    }

    final renderedMessage = whatsAppService.renderMessage(
      templateKey: templateKey,
      order: order,
      customer: customer!,
      vendorName: vendorName,
      waveName: waveName,
    );

    WhatsAppService.showPreviewAndSend(
      context: context,
      title: 'Message : ${status.shortLabel}',
      recipientName: customer!.name,
      recipientPhone: customer!.phone,
      initialMessage: renderedMessage,
    );
  }
}
