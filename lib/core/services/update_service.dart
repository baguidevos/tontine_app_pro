import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ota_update/ota_update.dart';
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
  final bool isForceUpdate; // Vrai si la mise à jour est obligatoire / bloquante
  final String? minSupportedVersion;
  final bool isMaintenanceMode; // Vrai si le système est en maintenance

  const AppUpdateInfo({
    required this.latestVersion,
    required this.currentVersion,
    required this.releaseName,
    required this.releaseNotes,
    this.apkDownloadUrl,
    required this.releasePageUrl,
    this.publishedAt,
    required this.isUpdateAvailable,
    this.isForceUpdate = false,
    this.minSupportedVersion,
    this.isMaintenanceMode = false,
  });
}

/// Service de gestion des stratégies de mise à jour In-App de l'application Paya.
/// - Stratégie 1 : Mise à jour Forcée (Hard / Force Update) pour ruptures de compatibilité.
/// - Stratégie 2 : Mise à jour Flexible (Soft / Flexible Update) non bloquante.
/// - Stratégie 3 : Double source de vérification (Firestore Config prioritaire + GitHub API Fallback).
/// - Stratégie 4 : Bandeau In-App persistant et mode maintenance d'urgence.
class UpdateService extends GetxService {
  static UpdateService get to => Get.find<UpdateService>();

  static const String repoOwner = 'baguidevos';
  static const String repoName = 'tontine_app_pro';
  static const String latestReleaseApi =
      'https://api.github.com/repos/$repoOwner/$repoName/releases/latest';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final isChecking = false.obs;
  final latestUpdate = Rxn<AppUpdateInfo>();
  final showInAppBanner = false.obs; // Affichage d'un bandeau discret dans l'accueil
  final appVersion = ''.obs;
  final appBuildNumber = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      appVersion.value = packageInfo.version;
      appBuildNumber.value = packageInfo.buildNumber;
    } catch (e) {
      debugPrint('UpdateService: Erreur lors de la lecture de PackageInfo: $e');
    }
  }

  // Évite de redemander sans cesse pendant la même session si l'utilisateur a cliqué "Plus tard"
  String? _dismissedVersion;

  /// Vérifie si une mise à jour est disponible via Firestore (prioritaire) puis GitHub Releases.
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
      appVersion.value = currentVersion;
      appBuildNumber.value = currentBuild;

      // 2. Tenter d'abord la source Firestore (Remote Config) pour éviter les quotas GitHub
      AppUpdateInfo? firestoreInfo = await _checkFromFirestore(
        currentVersion: currentVersion,
        currentBuild: currentBuild,
      );

      // Si le mode maintenance est actif dans Firestore
      if (firestoreInfo != null && firestoreInfo.isMaintenanceMode) {
        latestUpdate.value = firestoreInfo;
        showMaintenanceDialog(firestoreInfo.releaseNotes);
        return firestoreInfo;
      }

      AppUpdateInfo? resolvedInfo = firestoreInfo;

      // 3. Si aucun document Firestore n'a statué, fallback sur GitHub Releases
      resolvedInfo ??= await _checkFromGitHub(
        currentVersion: currentVersion,
        currentBuild: currentBuild,
        showNotificationIfUpToDate: showNotificationIfUpToDate,
      );

      if (resolvedInfo == null) {
        return null;
      }

      latestUpdate.value = resolvedInfo;

      // 4. Déclenchement de la stratégie In-App appropriée
      if (resolvedInfo.isUpdateAvailable) {
        if (resolvedInfo.isForceUpdate) {
          // STRATÉGIE FORCÉE : Bloquante, incontournable
          showInAppBanner.value = false;
          showForceUpdateDialog(resolvedInfo);
        } else {
          // STRATÉGIE FLEXIBLE : L'utilisateur peut reporter
          if (silent && _dismissedVersion == resolvedInfo.latestVersion) {
            // Afficher discrètement le bandeau In-App
            showInAppBanner.value = true;
            return resolvedInfo;
          }

          showFlexibleUpdateDialog(resolvedInfo);
        }
      } else if (showNotificationIfUpToDate) {
        showInAppBanner.value = false;
        _showSnackbar(
          title: 'Application à jour',
          message: 'Vous utilisez déjà la dernière version de Paya (v$currentVersion).',
          isError: false,
        );
      }

      return resolvedInfo;
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

  /// Vérifie la configuration de version sur Firestore (`app_config/version`)
  Future<AppUpdateInfo?> _checkFromFirestore({
    required String currentVersion,
    String? currentBuild,
  }) async {
    try {
      final doc = await _firestore.collection('app_config').doc('version').get();
      if (!doc.exists || doc.data() == null) {
        return null;
      }

      final data = doc.data()!;
      final latestVersion = (data['latest_version'] as String? ?? '').trim();
      final minVersion = (data['min_version'] as String? ?? '').trim();
      final forceUpdateFlag = data['force_update'] as bool? ?? false;
      final maintenanceMode = data['maintenance_mode'] as bool? ?? false;
      final apkUrl = data['download_url'] as String?;
      final notes = data['release_notes'] as String? ?? '';
      final releaseName = data['release_name'] as String? ?? 'Version $latestVersion';

      if (maintenanceMode) {
        return AppUpdateInfo(
          latestVersion: latestVersion,
          currentVersion: currentVersion,
          releaseName: 'Maintenance en cours',
          releaseNotes: notes.isNotEmpty ? notes : 'Paya est en maintenance technique temporaire.',
          releasePageUrl: '',
          isUpdateAvailable: false,
          isMaintenanceMode: true,
        );
      }

      if (latestVersion.isEmpty) return null;

      final isNewer = _isVersionGreater(
        latestVersion: latestVersion,
        currentVersion: currentVersion,
        currentBuild: currentBuild,
      );

      // La mise à jour est forcée si flag direct ou si version courante < version minimale
      final isBelowMin = minVersion.isNotEmpty &&
          _isVersionGreater(
            latestVersion: minVersion,
            currentVersion: currentVersion,
            currentBuild: currentBuild,
          );

      final isForce = isNewer && (forceUpdateFlag || isBelowMin);

      return AppUpdateInfo(
        latestVersion: latestVersion,
        currentVersion: currentVersion,
        releaseName: releaseName,
        releaseNotes: notes,
        apkDownloadUrl: apkUrl,
        releasePageUrl: apkUrl ?? 'https://github.com/$repoOwner/$repoName/releases',
        isUpdateAvailable: isNewer,
        isForceUpdate: isForce,
        minSupportedVersion: minVersion.isNotEmpty ? minVersion : null,
      );
    } catch (e) {
      debugPrint('[UpdateService] Firestore version check ignoré: $e');
      return null;
    }
  }

  /// Vérifie l'API GitHub Releases (Fallback)
  Future<AppUpdateInfo?> _checkFromGitHub({
    required String currentVersion,
    String? currentBuild,
    bool showNotificationIfUpToDate = false,
  }) async {
    try {
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

      // Détection de mot-clé critique dans les release notes (ex: [CRITICAL] ou [FORCE])
      final isForceFlag = releaseNotes.toUpperCase().contains('[CRITICAL]') ||
          releaseNotes.toUpperCase().contains('[FORCE]');

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

      apkDownloadUrl ??= releasePageUrl;

      final isNewer = _isVersionGreater(
        latestVersion: latestVersion,
        currentVersion: currentVersion,
        currentBuild: currentBuild,
      );

      return AppUpdateInfo(
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
        isForceUpdate: isForceFlag,
      );
    } catch (e) {
      debugPrint('[UpdateService] Exception GitHub Releases: $e');
      return null;
    }
  }

  /// Compare deux versions SemVer (ex: 0.10.1 vs 0.10.0)
  bool _isVersionGreater({
    required String latestVersion,
    required String currentVersion,
    String? currentBuild,
  }) {
    try {
      final latestParts = latestVersion.split('+')[0].split('.').map(int.parse).toList();
      final currentParts = currentVersion.split('+')[0].split('.').map(int.parse).toList();

      for (int i = 0; i < 3; i++) {
        final l = i < latestParts.length ? latestParts[i] : 0;
        final c = i < currentParts.length ? currentParts[i] : 0;
        if (l > c) return true;
        if (l < c) return false;
      }

      if (latestVersion.contains('+') && currentBuild != null && currentBuild.isNotEmpty) {
        final latestBuildNum = int.tryParse(latestVersion.split('+')[1]) ?? 0;
        final currentBuildNum = int.tryParse(currentBuild) ?? 0;
        return latestBuildNum > currentBuildNum;
      }

      return false;
    } catch (e) {
      return latestVersion != currentVersion;
    }
  }

  /// Résout la redirection HTTP 302 de GitHub pour extraire le lien direct
  /// de téléchargement CDN (release-assets.githubusercontent.com).
  /// Cela contourne définitivement l'application native GitHub sur Android.
  Future<String> _resolveDirectDownloadUrl(String url) async {
    if (!url.contains('github.com') || !url.contains('/releases/download/')) {
      return url;
    }

    try {
      final client = http.Client();
      final request = http.Request('GET', Uri.parse(url))..followRedirects = false;
      final streamedResponse = await client.send(request).timeout(const Duration(seconds: 8));

      if (streamedResponse.isRedirect && streamedResponse.headers.containsKey('location')) {
        final directUrl = streamedResponse.headers['location']!;
        debugPrint('[UpdateService] URL directe résolue (hors domaine GitHub): $directUrl');
        return directUrl;
      }
    } catch (e) {
      debugPrint('[UpdateService] Exception résolution URL directe: $e');
    }
    return url;
  }

  StreamSubscription<OtaEvent>? _otaSubscription;

  /// Lance le téléchargement direct In-App avec suivi de progression et installation automatique Android (OTA).
  Future<void> launchDownload(String url) async {
    // Sur Flutter Web ou autres plateformes qu'Android, bascule directe vers le navigateur
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      _fallbackBrowserDownload(url);
      return;
    }

    try {
      // 1. Résoudre le lien CDN direct si l'URL provient de GitHub Releases
      final directDownloadUrl = await _resolveDirectDownloadUrl(url);

      // Si l'URL ne pointe pas vers un fichier APK, ouvrir dans le navigateur de secours
      if (!directDownloadUrl.toLowerCase().contains('.apk')) {
        _fallbackBrowserDownload(directDownloadUrl);
        return;
      }

      // 2. Afficher la modale de progression In-App et démarrer le téléchargement OTA
      _showOtaDownloadDialog(directDownloadUrl);
    } catch (e) {
      debugPrint('[UpdateService] Erreur lors du lancement OTA: $e');
      _fallbackBrowserDownload(url);
    }
  }

  /// Affiche le dialogue modal de progression In-App
  void _showOtaDownloadDialog(String downloadUrl) {
    if (Get.context == null) return;

    final progress = 0.obs;
    final statusText = 'Connexion au serveur...'.obs;
    final isDone = false.obs;

    _otaSubscription?.cancel();

    Get.dialog(
      PopScope(
        canPop: false, // Empêche la fermeture accidentelle pendant le téléchargement
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Obx(
              () => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icône animée de mise à niveau
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.payaBlue, AppTheme.payaLightBlue],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.payaBlue.withValues(alpha: 0.3),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.system_update_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'Mise à jour en cours',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.darkerBlue,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    statusText.value,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.slate600,
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Barre de progression
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress.value > 0 ? progress.value / 100.0 : null,
                      minHeight: 10,
                      backgroundColor: AppTheme.slate200,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.payaGreen),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Indicateur de pourcentage
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${progress.value} %',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.payaGreen,
                        ),
                      ),
                      const Text(
                        'Installation automatique',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.slate400,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),

                  // Bouton Annuler
                  if (!isDone.value)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          _otaSubscription?.cancel();
                          if (Get.isDialogOpen == true) {
                            Get.back();
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.slate600,
                          side: const BorderSide(color: AppTheme.slate300),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Annuler'),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );

    // Déclenchement du téléchargement OTA en tâche de fond
    try {
      _otaSubscription = OtaUpdate()
          .execute(
            downloadUrl,
            destinationFilename: 'paya_update.apk',
          )
          .listen(
        (OtaEvent event) {
          switch (event.status) {
            case OtaStatus.DOWNLOADING:
              final p = int.tryParse(event.value ?? '0') ?? 0;
              progress.value = p;
              statusText.value = 'Téléchargement de la mise à jour ($p%)...';
              break;
            case OtaStatus.INSTALLING:
            case OtaStatus.INSTALLATION_DONE:
              isDone.value = true;
              statusText.value = 'Lancement de l\'installateur Android...';
              progress.value = 100;
              Future.delayed(const Duration(milliseconds: 1200), () {
                if (Get.isDialogOpen == true) {
                  Get.back();
                }
              });
              break;
            case OtaStatus.ALREADY_RUNNING_ERROR:
              statusText.value = 'Téléchargement déjà en cours...';
              break;
            case OtaStatus.CANCELED:
              statusText.value = 'Téléchargement annulé.';
              break;
            case OtaStatus.PERMISSION_NOT_GRANTED_ERROR:
              _handleOtaError(
                'Autorisation requise pour installer des applications.',
                downloadUrl,
              );
              break;
            case OtaStatus.INTERNAL_ERROR:
            case OtaStatus.DOWNLOAD_ERROR:
            case OtaStatus.CHECKSUM_ERROR:
            case OtaStatus.INSTALLATION_ERROR:
              _handleOtaError(
                'Échec du téléchargement direct.',
                downloadUrl,
              );
              break;
          }
        },
        onError: (error) {
          debugPrint('[UpdateService] Exception stream OtaUpdate: $error');
          _handleOtaError(
            'Impossible de terminer le téléchargement direct.',
            downloadUrl,
          );
        },
      );
    } catch (e) {
      debugPrint('[UpdateService] Exception initialisation OtaUpdate: $e');
      _handleOtaError('Échec du service d\'installation.', downloadUrl);
    }
  }

  void _handleOtaError(String message, String fallbackUrl) {
    _otaSubscription?.cancel();
    if (Get.isDialogOpen == true) {
      Get.back();
    }
    _showSnackbar(
      title: 'Mise à jour',
      message: '$message Ouverture du lien de secours...',
      isError: true,
    );
    _fallbackBrowserDownload(fallbackUrl);
  }

  Future<void> _fallbackBrowserDownload(String url) async {
    try {
      final directDownloadUrl = await _resolveDirectDownloadUrl(url);
      final uri = Uri.parse(directDownloadUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('[UpdateService] Exception fallback navigateur: $e');
    }
  }

  /// STRATÉGIE 1 : Dialogue bloquant de mise à jour forcée (Incontournable)
  void showForceUpdateDialog(AppUpdateInfo info) {
    if (Get.context == null) return;

    Get.dialog(
      PopScope(
        canPop: false, // Empêche la fermeture via le bouton retour Android
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header rouge alerte
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppTheme.softRed.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        color: AppTheme.softRed,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Mise à jour obligatoire',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.darkerBlue,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.softRed.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'ACTION REQUISE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.softRed,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                const Text(
                  'Une mise à jour critique de sécurité et de fonctionnalités est requise pour continuer à utiliser Paya en toute sécurité.',
                  style: TextStyle(fontSize: 13, color: AppTheme.slate700, height: 1.4),
                ),
                const SizedBox(height: 14),

                if (info.releaseNotes.isNotEmpty) ...[
                  Container(
                    constraints: const BoxConstraints(maxHeight: 140),
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
                        style: const TextStyle(fontSize: 12, height: 1.4, color: AppTheme.slate700),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                ],

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (info.apkDownloadUrl != null) {
                        launchDownload(info.apkDownloadUrl!);
                      }
                    },
                    icon: const Icon(Icons.system_update_rounded, size: 20),
                    label: const Text(
                      'Installer la mise à jour',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.payaBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// STRATÉGIE 2 : Dialogue modal de mise à jour flexible (Optionnelle)
  void showFlexibleUpdateDialog(AppUpdateInfo info) {
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
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                              style: const TextStyle(fontSize: 11, color: AppTheme.slate500),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

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
                      style: const TextStyle(fontSize: 12, height: 1.4, color: AppTheme.slate700),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
              ],

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.back();
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
                    showInAppBanner.value = true; // Activer le bandeau discret dans l'accueil
                    Get.back();
                  },
                  child: const Text(
                    'Plus tard',
                    style: TextStyle(color: AppTheme.slate500, fontWeight: FontWeight.w600),
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

  /// STRATÉGIE 4 : Dialogue bloquant en cas de mode maintenance générale
  void showMaintenanceDialog(String message) {
    if (Get.context == null) return;

    Get.dialog(
      PopScope(
        canPop: false,
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.payaOrange.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.construction_rounded,
                    color: AppTheme.payaOrange,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Maintenance en cours',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.darkerBlue),
                ),
                const SizedBox(height: 10),
                Text(
                  message.isNotEmpty
                      ? message
                      : 'Paya fait l\'objet d\'une mise à niveau technique. Nos services seront rétablis dans quelques instants.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: AppTheme.slate600, height: 1.4),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => checkForUpdate(silent: false),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Vérifier à nouveau'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.payaBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
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
