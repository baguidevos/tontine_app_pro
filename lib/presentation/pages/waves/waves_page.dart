import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paya_app/core/theme/app_theme.dart';
import 'package:paya_app/data/models/wave_model.dart';
import 'package:paya_app/presentation/controllers/wave_controller.dart';
import 'package:paya_app/presentation/widgets/confirmation_dialog.dart';
import 'widgets/create_wave_dialog.dart';

class WavesPage extends StatelessWidget {
  const WavesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final waveController = Get.find<WaveController>();

    return Scaffold(
      backgroundColor: AppTheme.warmCream,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'waves_page_fab',
        onPressed: () => Get.dialog(const CreateWaveDialog()),
        backgroundColor: AppTheme.deepBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Nouvelle Vague',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Obx(() {
        if (waveController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (waveController.waves.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.waves,
                  size: 80,
                  color: AppTheme.deepBlue.withOpacity(0.2),
                ),
                const SizedBox(height: 16),
                Text(
                  'Aucune vague',
                  style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Get.dialog(const CreateWaveDialog()),
                  child: const Text('Créer votre première vague'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: waveController.waves.length,
          itemBuilder: (context, index) {
            final wave = waveController.waves[index];
            return Card(
              
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 2,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: AppTheme.payaGray.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Text(
                  wave.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildStatusChip(wave.status),
                        const SizedBox(width: 8),
                        Text(
                          'Créée le ${_formatDate(wave.createdAt)}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                  onPressed: () =>
                      _showWaveOptions(context, waveController, wave),
                ),
                onTap: () {
                  // Navigate to wave details page
                  Get.toNamed('/waves/details', arguments: wave);
                },
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildStatusChip(WaveStatus status) {
    Color color;
    String label;

    switch (status) {
      case WaveStatus.active:
        color = Colors.green;
        label = 'Active';
        break;
      case WaveStatus.closed:
        color = Colors.grey;
        label = 'Clôturée';
        break;
      case WaveStatus.draft:
        color = Colors.orange;
        label = 'Brouillon';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showWaveOptions(
    BuildContext context,
    WaveController controller,
    WaveModel wave,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              wave.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.deepBlue,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.deepBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.edit_outlined,
                  color: AppTheme.deepBlue,
                ),
              ),
              title: const Text('Modifier la vague'),
              onTap: () {
                Get.back();
                Get.dialog(CreateWaveDialog(wave: wave));
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.lock_outline, color: Colors.orange),
              ),
              title: const Text('Clôturer la vague'),
              onTap: () {
                Get.back();
                // TODO: Implement close logic
                Get.snackbar('Info', 'Fonctionnalité à venir');
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.softRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.delete_outline,
                  color: AppTheme.softRed,
                ),
              ),
              title: const Text(
                'Supprimer la vague',
                style: TextStyle(color: AppTheme.softRed),
              ),
              onTap: () {
                Get.back();
                _confirmDelete(context, controller, wave.id);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    WaveController controller,
    String id,
  ) {
    Get.dialog(
      ConfirmationDialog(
        title: 'Confirmer la suppression',
        message:
            'Êtes-vous sûr de vouloir supprimer cette vague ? Cette action est irréversible.',
        confirmText: 'Supprimer',
        cancelText: 'Annuler',
        isDanger: true,
        icon: Icons.delete_outline,
        onConfirm: () {
          Get.back(); // Close dialog
          controller.deleteWave(id);
        },
      ),
    );
  }
}
