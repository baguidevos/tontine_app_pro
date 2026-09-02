import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/image_server_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/platform_file_image.dart';
import '../../data/models/product_model.dart';

/// Widget pour afficher l'image d'un produit avec stratégie de résilience complète :
/// 1. Tente d'afficher l'image distante (`imageUrl`) via `CachedNetworkImage` (avec headers d'authentification)
/// 2. Si hors-ligne ou erreur de chargement réseau, bascule immédiatement sur le fichier local (`localImagePath`)
/// 3. Si aucun fichier local n'existe, affiche un placeholder élégant.
class ProductImage extends StatelessWidget {
  final ProductModel? product;
  final String? imageUrl;
  final String? localImagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const ProductImage({
    super.key,
    this.product,
    this.imageUrl,
    this.localImagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  String? get _resolvedImageUrl => imageUrl ?? product?.imageUrl;
  String? get _resolvedLocalPath => localImagePath ?? product?.localImagePath;

  @override
  Widget build(BuildContext context) {
    Widget content;

    final onlineUrl = _resolvedImageUrl;
    final localPath = _resolvedLocalPath;

    if (onlineUrl != null && onlineUrl.isNotEmpty) {
      // 1. Tenter le chargement en ligne avec cache
      Map<String, String>? headers;
      if (Get.isRegistered<ImageServerService>()) {
        headers = Get.find<ImageServerService>().authHeaders;
      }

      content = CachedNetworkImage(
        imageUrl: onlineUrl,
        httpHeaders: headers,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => placeholder ?? _buildLoadingPlaceholder(),
        errorWidget: (context, url, error) {
          // Fallback immédiat vers l'image locale si l'image distante échoue
          if (hasValidPlatformFile(localPath)) {
            return buildPlatformFileImage(
              path: localPath!,
              width: width,
              height: height,
              fit: fit,
              errorBuilder: (context, error, stackTrace) =>
                  errorWidget ?? _buildDefaultPlaceholder(),
            );
          }
          return errorWidget ?? _buildDefaultPlaceholder();
        },
      );
    } else if (hasValidPlatformFile(localPath)) {
      // 2. Pas d'URL distante mais fichier local disponible
      content = buildPlatformFileImage(
        path: localPath!,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) =>
            errorWidget ?? _buildDefaultPlaceholder(),
      );
    } else {
      // 3. Aucune image disponible
      content = errorWidget ?? _buildDefaultPlaceholder();
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: content,
      );
    }

    return content;
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade200,
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.deepBlue),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade200,
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          size: (width != null && width! < 60) ? 24 : 36,
          color: Colors.grey.shade400,
        ),
      ),
    );
  }
}
