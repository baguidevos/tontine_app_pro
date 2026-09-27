import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paya_app/core/theme/app_theme.dart';
import 'package:paya_app/data/models/wave_model.dart';
import 'package:paya_app/presentation/controllers/wave_controller.dart';

class WaveSelectionDialog extends StatelessWidget {
  final Function(String waveId) onWaveSelected;

  const WaveSelectionDialog({super.key, required this.onWaveSelected});

  @override
  Widget build(BuildContext context) {
    final WaveController waveController = Get.find<WaveController>();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      elevation: 12,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 16, 14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.deepBlue.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.copy_all_rounded,
                      color: AppTheme.deepBlue,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Sélectionner une vague',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.slate900,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Associer ou dupliquer vers une autre vague',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.slate500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close_rounded, color: AppTheme.slate400, size: 20),
                    splashRadius: 20,
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppTheme.slate200),

            // List of Waves
            Flexible(
              child: Obx(() {
                final waves = waveController.waves;
                if (waves.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppTheme.slate100,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.waves_rounded,
                              size: 32,
                              color: AppTheme.slate400,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Aucune vague disponible',
                            style: TextStyle(
                              color: AppTheme.slate600,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  shrinkWrap: true,
                  itemCount: waves.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final wave = waves[index];
                    return _buildWaveItem(wave);
                  },
                );
              }),
            ),

            const Divider(height: 1, color: AppTheme.slate200),

            // Cancel Button
            Padding(
              padding: const EdgeInsets.all(14),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.slate700,
                    side: const BorderSide(color: AppTheme.slate300),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Fermer', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaveItem(WaveModel wave) {
    Color statusBg;
    Color statusFg;
    String statusText;

    switch (wave.status) {
      case WaveStatus.active:
        statusBg = AppTheme.payaGreen.withValues(alpha: 0.1);
        statusFg = AppTheme.payaGreen;
        statusText = 'Active';
        break;
      case WaveStatus.closed:
        statusBg = AppTheme.slate200;
        statusFg = AppTheme.slate600;
        statusText = 'Clôturée';
        break;
      case WaveStatus.draft:
        statusBg = AppTheme.payaOrange.withValues(alpha: 0.12);
        statusFg = AppTheme.payaOrange;
        statusText = 'Brouillon';
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.slate50,
        border: Border.all(color: AppTheme.slate200),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () => onWaveSelected(wave.id),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppTheme.deepBlue.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.waves_rounded,
                    color: AppTheme.deepBlue,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        wave.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppTheme.slate900,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${wave.productIds.length} produit(s)',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.slate500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: statusFg,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: AppTheme.slate400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
