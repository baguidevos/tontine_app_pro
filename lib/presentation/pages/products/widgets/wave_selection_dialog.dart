import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/wave_model.dart';
import '../../../controllers/wave_controller.dart';

class WaveSelectionDialog extends StatelessWidget {
  final Function(String waveId) onWaveSelected;

  const WaveSelectionDialog({super.key, required this.onWaveSelected});

  @override
  Widget build(BuildContext context) {
    final WaveController waveController = Get.find<WaveController>();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      elevation: 8,
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.warmCream,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.copy_all,
                    color: AppTheme.deepBlue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dupliquer vers...',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const Text(
                        'Sélectionner une vague',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.deepBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // List of Waves
            Expanded(
              child: Obx(() {
                final waves = waveController.waves;
                if (waves.isEmpty) {
                  return Center(
                    child: Text(
                      'Aucune vague disponible',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: waves.length,
                  itemBuilder: (context, index) {
                    final wave = waves[index];
                    return _buildWaveItem(wave);
                  },
                );
              }),
            ),

            const SizedBox(height: 16),

            // Cancel Button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Get.back(),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Annuler',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaveItem(WaveModel wave) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => onWaveSelected(wave.id),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppTheme.deepBlue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.waves,
                    color: AppTheme.deepBlue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        wave.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppTheme.deepBlue,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
