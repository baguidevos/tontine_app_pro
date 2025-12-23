import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../controllers/wave_controller.dart';
import '../../../data/models/wave_model.dart';
import 'widgets/create_wave_dialog.dart';

class WavesPage extends StatelessWidget {
  const WavesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final waveController = Get.find<WaveController>();

    return Scaffold(
      backgroundColor: AppTheme.warmCream,
      floatingActionButton: FloatingActionButton.extended(
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
                trailing: PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined),
                          SizedBox(width: 8),
                          Text('Modifier'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'close',
                      child: Row(
                        children: [
                          Icon(Icons.lock_outline),
                          SizedBox(width: 8),
                          Text('Clôturer'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, color: Colors.red),
                          SizedBox(width: 8),
                          Text(
                            'Supprimer',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'delete') {
                      _confirmDelete(context, waveController, wave.id);
                    } else if (value == 'edit') {
                      Get.dialog(CreateWaveDialog(wave: wave));
                    }
                    // TODO: Implement close
                  },
                ),
                onTap: () {
                  // Navigate to products filtered by this wave?
                  // Get.toNamed('/products', arguments: wave);
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

  void _confirmDelete(
    BuildContext context,
    WaveController controller,
    String id,
  ) {
    Get.defaultDialog(
      title: 'Confirmer la suppression',
      middleText:
          'Êtes-vous sûr de vouloir supprimer cette vague ? Cette action est irréversible.',
      textConfirm: 'Supprimer',
      textCancel: 'Annuler',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        controller.deleteWave(id);
        Get.back();
      },
    );
  }
}
