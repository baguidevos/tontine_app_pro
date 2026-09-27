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
      backgroundColor: AppTheme.payaCream,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'waves_page_fab',
        onPressed: () => Get.dialog(const CreateWaveDialog()),
        backgroundColor: AppTheme.payaBlue,
        elevation: 3,
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
        label: const Text(
          'Nouvelle Vague',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
      body: Obx(() {
        if (waveController.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.payaBlue));
        }

        if (waveController.waves.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.slate200),
                    ),
                    child: const Icon(
                      Icons.waves_rounded,
                      size: 48,
                      color: AppTheme.slate400,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Aucune vague créée',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.slate800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Organisez vos ventes et vos tontines en créant une vague de commande.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.slate500,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => Get.dialog(const CreateWaveDialog()),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Créer votre première vague'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          physics: const BouncingScrollPhysics(),
          itemCount: waveController.waves.length,
          itemBuilder: (context, index) {
            final wave = waveController.waves[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.slate200.withValues(alpha: 0.8), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.payaBlue.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    Get.toNamed('/waves/details', arguments: wave);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppTheme.payaOrange.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.waves_rounded,
                                color: AppTheme.payaOrange,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    wave.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                      color: AppTheme.slate900,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'Lancée le ${_formatDate(wave.createdAt)}',
                                    style: const TextStyle(
                                      color: AppTheme.slate500,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _buildStatusChip(wave.status),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: const Icon(Icons.more_horiz_rounded, color: AppTheme.slate400, size: 20),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () => _showWaveOptions(context, waveController, wave),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(color: AppTheme.slate100, height: 1),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.slate50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppTheme.slate200),
                              ),
                              child: Text(
                                '${wave.productIds.length} produit(s) inclus',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.slate700,
                                ),
                              ),
                            ),
                            const Row(
                              children: [
                                Text(
                                  'Voir détails',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.payaBlue,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(Icons.chevron_right_rounded, size: 18, color: AppTheme.payaBlue),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildStatusChip(WaveStatus status) {
    Color color;
    Color bgColor;
    String label;

    switch (status) {
      case WaveStatus.active:
        color = AppTheme.payaGreen;
        bgColor = AppTheme.greenLight;
        label = 'En cours';
        break;
      case WaveStatus.closed:
        color = AppTheme.slate600;
        bgColor = AppTheme.slate100;
        label = 'Clôturée';
        break;
      case WaveStatus.draft:
        color = AppTheme.payaOrange;
        bgColor = AppTheme.orangeLight;
        label = 'Brouillon';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _showWaveOptions(
    BuildContext context,
    WaveController controller,
    WaveModel wave,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppTheme.slate200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              wave.name,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppTheme.darkerBlue,
              ),
            ),
            const SizedBox(height: 18),
            _buildOptionTile(
              icon: Icons.edit_rounded,
              iconColor: AppTheme.payaBlue,
              bgColor: AppTheme.payaBlue.withValues(alpha: 0.1),
              title: 'Modifier la vague',
              onTap: () {
                Get.back();
                Get.dialog(CreateWaveDialog(wave: wave));
              },
            ),
            const SizedBox(height: 8),
            _buildOptionTile(
              icon: Icons.delete_outline_rounded,
              iconColor: AppTheme.payaRed,
              bgColor: AppTheme.redLight,
              title: 'Supprimer la vague',
              textColor: AppTheme.payaRed,
              onTap: () {
                Get.back();
                _confirmDelete(context, controller, wave.id);
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.slate50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.slate200),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: textColor ?? AppTheme.slate800,
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: AppTheme.slate400),
        onTap: onTap,
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
        message: 'Êtes-vous sûr de vouloir supprimer cette vague ? Cette action est irréversible.',
        confirmText: 'Supprimer',
        cancelText: 'Annuler',
        isDanger: true,
        icon: Icons.delete_outline_rounded,
        onConfirm: () {
          Get.back();
          controller.deleteWave(id);
        },
      ),
    );
  }
}
