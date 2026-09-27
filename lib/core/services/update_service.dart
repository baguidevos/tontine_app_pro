import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:paya_app/core/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

/// Modèle contenant les détails d'une mise à jour disponible.
class AppUpdateInfo {
  final String latestVersion;
  final String currentVersion;
  final String releaseName;
  final String releaseNotes;
  final String? apkDownloadUrl;
  final String releasePageUrl;
  final DateTime? publishedAt;
  final bool isUpdateAvailable;

  const AppUpdateInfo({
    required this.latestVersion,
    required this.currentVersion,
    required this.releaseName,
    required this.releaseNotes,
    this.apkDownloadUrl,
    required this.releasePageUrl,
    this.publishedAt,
    required this.isUpdateAvailable,
  });
}

/// Service vérifiant les mises à jour publiées sur GitHub Releases.
class UpdateService extends GetxService {
  static UpdateService get to => Get.find<UpdateService>();

  static const String repoOwner = 'baguidevos';
  static const String repoName = 'tontine_app_pro';
  static const String latestReleaseApi =
      'https://api.github.com/repos/$repoOwner/$repoName/releases/latest';

  final isChecking = false.obs;
  final latestUpdate = Rxn<AppUpdateInfo>();

  // Évite de redemander sans cesse pendant la même session si l'utilisateur a cliqué "Plus tard"
  String? _dismissedVersion;

  /// Vérifie si une mise à jour est disponible sur GitHub Releases.
  Future<AppUpdateInfo?> checkForUpdate({
    bool showNotificationIfUpToDate = false,
    bool silent = false,
  }) async {
    // Sur Flutter Web, les mises à jour sont automatiques au chargement de la page
    if (kIsWeb) return null;

    try {
      isChecking.value = true;

      // 1. Récupérer la version actuelle installée
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      final currentBuild = packageInfo.buildNumber;

      // 2. Interroger l'API publique GitHub Releases
      final response = await http.get(
        Uri.parse(latestReleaseApi),
        headers: {
          'Accept': 'application/vnd.github.v3+json',
          'User-Agent': 'PayaApp-Mobile',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        debugPrint(
          '[UpdateService] Erreur GitHub API (${response.statusCode}): ${response.body}',
        );
        if (showNotificationIfUpToDate) {
          _showSnackbar(
            title: 'Vérification impossible',
            message: 'Impossible de vérifier les mises à jour pour le moment.',
            isError: true,
          );
        }
        return null;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final rawTag = (data['tag_name'] as String? ?? '').trim();
      final latestVersion = rawTag.startsWith('v') ? rawTag.substring(1) : rawTag;
      final releaseName = (data['name'] as String?) ?? 'Version $latestVersion';
      final releaseNotes = (data['body'] as String?) ?? '';
      final releasePageUrl = (data['html_url'] as String?) ??
          'https://github.com/$repoOwner/$repoName/releases';

      // Recherche de l'APK dans les assets
      String? apkDownloadUrl;
      final assets = data['assets'] as List<dynamic>? ?? [];
      for (final asset in assets) {
        final name = (asset['name'] as String? ?? '').toLowerCase();
        if (name.endsWith('.apk')) {
          apkDownloadUrl = asset['browser_download_url'] as String?;
          break;
        }
      }

      // Si aucun asset APK n'est attaché, fallback sur la page de la release
      apkDownloadUrl ??= releasePageUrl;

      // 3. Comparaison sémantique des versions
      final isNewer = _isVersionGreater(
        latestVersion: latestVersion,
        currentVersion: currentVersion,
        currentBuild: currentBuild,
      );

      final updateInfo = AppUpdateInfo(
        latestVersion: latestVersion,
        currentVersion: currentVersion,
        releaseName: releaseName,
        releaseNotes: releaseNotes,
        apkDownloadUrl: apkDownloadUrl,
        releasePageUrl: releasePageUrl,
        publishedAt: data['published_at'] != null
            ? DateTime.tryParse(data['published_at'])
            : null,
        isUpdateAvailable: isNewer,
      );

      latestUpdate.value = updateInfo;

      if (isNewer) {
        // Si cette version a déjà été refusée dans cette session et qu'on est en mode silencieux, on n'affiche pas
        if (silent && _dismissedVersion == latestVersion) {
          return updateInfo;
        }

        // Afficher la boîte de dialogue de mise à jour
        showUpdateDialog(updateInfo);
      } else if (showNotificationIfUpToDate) {
        _showSnackbar(
          title: 'Application à jour',
          message: 'Vous utilisez déjà la dernière version de Paya (v$currentVersion).',
          isError: false,
        );
      }

      return updateInfo;
    } catch (e) {
      debugPrint('[UpdateService] Exception lors du check mise à jour: $e');
      if (showNotificationIfUpToDate) {
        _showSnackbar(
          title: 'Erreur réseau',
          message: 'Vérifiez votre connexion internet.',
          isError: true,
        );
      }
      return null;
    } finally {
      isChecking.value = false;
    }
  }

  /// Compare deux versions SemVer (ex: 0.10.1 vs 0.10.0)
  bool _isVersionGreater({
    required String latestVersion,
    required String currentVersion,
    String? currentBuild,
  }) {
    try {
      // Découper la version (ex: 0.10.1+19 ou 0.10.1)
      final latestParts = latestVersion.split('+')[0].split('.').map(int.parse).toList();
      final currentParts = currentVersion.split('+')[0].split('.').map(int.parse).toList();

      for (int i = 0; i < 3; i++) {
        final l = i < latestParts.length ? latestParts[i] : 0;
        final c = i < currentParts.length ? currentParts[i] : 0;
        if (l > c) return true;
        if (l < c) return false;
      }

      // Si les parties X.Y.Z sont égales, vérifier le numéro de build si présent
      if (latestVersion.contains('+') && currentBuild != null && currentBuild.isNotEmpty) {
        final latestBuildNum = int.tryParse(latestVersion.split('+')[1]) ?? 0;
        final currentBuildNum = int.tryParse(currentBuild) ?? 0;
        return latestBuildNum > currentBuildNum;
      }

      return false;
    } catch (e) {
      // Comparaison textuelle de secours
      return latestVersion != currentVersion;
    }
  }

  /// Ouvre le lien de téléchargement direct de l'APK
  Future<void> launchDownload(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _showSnackbar(
        title: 'Erreur',
        message: 'Impossible d\'ouvrir le lien de téléchargement.',
        isError: true,
      );
    }
  }

  /// Affiche le dialogue modal de mise à jour moderne
  void showUpdateDialog(AppUpdateInfo info) {
    if (Get.context == null) return;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header avec icône moderne
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppTheme.payaBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.system_update_rounded,
                      color: AppTheme.payaBlue,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Mise à jour disponible',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.darkerBlue,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.greenLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'v${info.latestVersion}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.payaGreen,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '(actuelle: v${info.currentVersion})',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.slate500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Titre de la release
              if (info.releaseName.isNotEmpty) ...[
                Text(
                  info.releaseName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.slate800,
                  ),
                ),
                const SizedBox(height: 8),
              ],

              // Notes de version (Changelog)
              if (info.releaseNotes.isNotEmpty) ...[
                Container(
                  constraints: const BoxConstraints(maxHeight: 180),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.slate50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.slate200),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Text(
                      info.releaseNotes,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: AppTheme.slate700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
              ],

              // Actions
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.back(); // Ferme le dialogue
                    if (info.apkDownloadUrl != null) {
                      launchDownload(info.apkDownloadUrl!);
                    }
                  },
                  icon: const Icon(Icons.download_rounded, size: 20),
                  label: const Text(
                    'Mettre à jour maintenant',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.payaBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    _dismissedVersion = info.latestVersion;
                    Get.back();
                  },
                  child: const Text(
                    'Plus tard',
                    style: TextStyle(
                      color: AppTheme.slate500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  void _showSnackbar({
    required String title,
    required String message,
    required bool isError,
  }) {
    Get.snackbar(
      title,
      message,
      backgroundColor: isError ? AppTheme.softRed : AppTheme.payaGreen,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
    );
  }
}
