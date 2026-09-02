import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../config/api_config.dart';
import 'auth_service.dart';

class ImageUploadResult {
  final bool success;
  final String? imageId;
  final String? downloadUrl;
  final String? error;

  const ImageUploadResult({
    required this.success,
    this.imageId,
    this.downloadUrl,
    this.error,
  });

  String? get errorMessage => error;

  factory ImageUploadResult.success({
    required String imageId,
    required String downloadUrl,
  }) {
    return ImageUploadResult(
      success: true,
      imageId: imageId,
      downloadUrl: downloadUrl,
    );
  }

  factory ImageUploadResult.failure(String error) {
    return ImageUploadResult(success: false, error: error);
  }
}

class ImageServerService extends GetxService {
  String? _cachedToken;

  Map<String, String> get headers {
    final uri = Uri.tryParse(ApiConfig.baseUrl);
    final isLocalLoopback = uri != null &&
        (uri.host == '127.0.0.1' ||
            uri.host == 'localhost' ||
            uri.host == '10.0.2.2');

    return {
      'X-Application-Key': ApiConfig.applicationKey,
      'Accept': 'application/json',
      if (isLocalLoopback) 'Host': 'imageserver.test',
    };
  }

  Map<String, String> get authHeaders => {
        ...headers,
        if (_cachedToken != null && _cachedToken!.isNotEmpty)
          'Authorization': 'Bearer $_cachedToken',
      };

  @override
  Future<void> onInit() async {
    super.onInit();
    await _loadSavedToken();
  }

  /// Charge le token stocké localement au démarrage
  Future<void> _loadSavedToken() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, 'image_server_token.txt'));
      if (await file.exists()) {
        _cachedToken = await file.readAsString();
      }
    } catch (e) {
      debugPrint('[ImageServerService] Erreur chargement token: $e');
    }
  }

  /// Sauvegarde le token localement
  Future<void> _saveToken(String token) async {
    _cachedToken = token;
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, 'image_server_token.txt'));
      await file.writeAsString(token);
    } catch (e) {
      debugPrint('[ImageServerService] Erreur sauvegarde token: $e');
    }
  }

  /// Efface le token en cache
  Future<void> clearToken() async {
    _cachedToken = null;
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, 'image_server_token.txt'));
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }

  /// S'assure que le client dispose d'un token Sanctum valide.
  /// Se connecte ou s'enregistre automatiquement avec le compte vendeur Firebase.
  Future<bool> ensureAuthenticated() async {
    if (_cachedToken != null && _cachedToken!.isNotEmpty) {
      return true;
    }

    // Récupère l'utilisateur connecté via AuthService
    String email = 'default_vendor@gmail.com';
    String name = 'Vendeur Paya';
    String password = 'PasswordPaya2026!'; // Minimum 12 caractères requis par l'API

    if (Get.isRegistered<AuthService>()) {
      final auth = Get.find<AuthService>();
      final vendor = auth.currentVendor.value;
      if (vendor != null && vendor.email.isNotEmpty) {
        email = vendor.email;
        name = vendor.businessName.isNotEmpty ? vendor.businessName : 'Vendeur';
        password = 'Paya_${vendor.id.padRight(12, '0')}!';
      } else if (auth.firebaseUser.value?.email != null &&
          auth.firebaseUser.value!.email!.isNotEmpty) {
        email = auth.firebaseUser.value!.email!;
        final uid = auth.firebaseUser.value!.uid;
        password = 'Paya_${uid.padRight(12, '0')}!';
      }
    }

    debugPrint('[ImageServerService] Tentative auth sur ${ApiConfig.loginUrl} ($email)...');

    // 1. Tenter la connexion
    try {
      final loginResponse = await http
          .post(
            Uri.parse(ApiConfig.loginUrl),
            headers: {...headers, 'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 10));

      if (loginResponse.statusCode == 200) {
        final data = jsonDecode(loginResponse.body);
        final token = data['token'] as String?;
        if (token != null) {
          await _saveToken(token);
          debugPrint('[ImageServerService] Connexion réussie, token obtenu.');
          return true;
        }
      } else {
        debugPrint('[ImageServerService] Login status ${loginResponse.statusCode}: ${loginResponse.body}');
      }
    } catch (e) {
      debugPrint('[ImageServerService] Exception login: $e');
    }

    // 2. Si non connecté, tenter l'inscription
    try {
      final registerResponse = await http
          .post(
            Uri.parse(ApiConfig.registerUrl),
            headers: {...headers, 'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': name,
              'email': email,
              'password': password,
              'password_confirmation': password,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (registerResponse.statusCode == 201 ||
          registerResponse.statusCode == 200) {
        final data = jsonDecode(registerResponse.body);
        final token = data['token'] as String?;
        if (token != null) {
          await _saveToken(token);
          debugPrint('[ImageServerService] Inscription réussie, token obtenu.');
          return true;
        }
      } else {
        debugPrint('[ImageServerService] Register status ${registerResponse.statusCode}: ${registerResponse.body}');
      }
    } catch (e) {
      debugPrint('[ImageServerService] Exception inscription: $e');
    }

    return false;
  }

  /// Sauvegarde une image localement de manière permanente dans le dossier documents de l'app
  Future<String> saveImagePermanently(File sourceFile) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final productsDir = Directory(p.join(dir.path, 'products'));
      if (!await productsDir.exists()) {
        await productsDir.create(recursive: true);
      }

      final ext = p.extension(sourceFile.path);
      final uniqueName =
          'prod_${DateTime.now().millisecondsSinceEpoch}_${p.basenameWithoutExtension(sourceFile.path)}$ext';
      final targetPath = p.join(productsDir.path, uniqueName);

      // Copier le fichier vers le dossier permanent
      final copied = await sourceFile.copy(targetPath);
      return copied.path;
    } catch (e) {
      debugPrint('[ImageServerService] Erreur copie locale permanente: $e');
      // En cas d'échec, renvoie le chemin source
      return sourceFile.path;
    }
  }

  /// Upload une image vers le serveur Laravel
  Future<ImageUploadResult> uploadImage(
    File file, {
    bool retryOnAuthError = true,
  }) async {
    try {
      if (!await file.exists()) {
        return ImageUploadResult.failure('Le fichier image local n\'existe pas.');
      }

      // S'assurer d'être authentifié
      final authOk = await ensureAuthenticated();
      if (!authOk) {
        return ImageUploadResult.failure(
          'Impossible de s\'authentifier sur le serveur d\'images.',
        );
      }

      debugPrint(
        '[ImageServerService] Début upload image: ${file.path} vers ${ApiConfig.imagesUrl}',
      );

      final request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.imagesUrl),
      );
      request.headers.addAll(authHeaders);

      final multipartFile = await http.MultipartFile.fromPath(
        'image',
        file.path,
        filename: p.basename(file.path),
      );
      request.files.add(multipartFile);

      final streamedResponse = await request
          .send()
          .timeout(const Duration(seconds: 25));
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint(
        '[ImageServerService] Réponse upload (${response.statusCode}): ${response.body}',
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final imageId = data['id']?.toString() ?? '';
        final downloadUrl = data['download_url']?.toString() ??
            ApiConfig.imageUrl(imageId);

        return ImageUploadResult.success(
          imageId: imageId,
          downloadUrl: downloadUrl,
        );
      } else if (response.statusCode == 401 && retryOnAuthError) {
        debugPrint(
          '[ImageServerService] 401 sur upload, réauthentification et tentative unique...',
        );
        await clearToken();
        final reAuth = await ensureAuthenticated();
        if (reAuth) {
          return uploadImage(file, retryOnAuthError: false);
        }
        return ImageUploadResult.failure('Session expirée (401).');
      } else {
        return ImageUploadResult.failure(
          'Erreur serveur (${response.statusCode}): ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('[ImageServerService] Erreur réseau lors de l\'upload: $e');
      return ImageUploadResult.failure('Serveur d\'images injoignable: $e');
    }
  }

  /// Supprimer une image du serveur Laravel
  Future<bool> deleteImage(
    String imageId, {
    bool retryOnAuthError = true,
  }) async {
    try {
      if (imageId.isEmpty) return false;
      await ensureAuthenticated();

      debugPrint(
        '[ImageServerService] Suppression image $imageId sur ${ApiConfig.imageUrl(imageId)}',
      );

      final response = await http
          .delete(Uri.parse(ApiConfig.imageUrl(imageId)), headers: authHeaders)
          .timeout(const Duration(seconds: 10));

      debugPrint(
        '[ImageServerService] Réponse suppression ($imageId): ${response.statusCode}',
      );

      if (response.statusCode == 401 && retryOnAuthError) {
        await clearToken();
        final reAuth = await ensureAuthenticated();
        if (reAuth) {
          return deleteImage(imageId, retryOnAuthError: false);
        }
      }

      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      debugPrint('[ImageServerService] Erreur suppression distante: $e');
      return false;
    }
  }
}
