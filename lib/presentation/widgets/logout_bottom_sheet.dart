import 'package:flutter/material.dart';
import 'package:paya_app/core/theme/app_theme.dart';
import 'package:paya_app/presentation/controllers/auth_controller.dart';

/// Bottom sheet premium de confirmation de déconnexion.
/// Utilisé dans [MoreMenuPage] et [AppDrawer].
class LogoutBottomSheet extends StatefulWidget {
  final AuthController authController;
  const LogoutBottomSheet({super.key, required this.authController});

  @override
  State<LogoutBottomSheet> createState() => _LogoutBottomSheetState();
}

class _LogoutBottomSheetState extends State<LogoutBottomSheet> {
  bool _isLoading = false;

  Future<void> _doLogout() async {
    setState(() => _isLoading = true);
    Navigator.pop(context);
    await widget.authController.logout();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 28),
            decoration: BoxDecoration(
              color: AppTheme.slate200,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Icône principale avec dégradé rouge
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.softRed.withValues(alpha: 0.15),
                  AppTheme.payaRed.withValues(alpha: 0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.softRed.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.logout_rounded,
              color: AppTheme.softRed,
              size: 36,
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Se déconnecter ?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppTheme.slate900,
              letterSpacing: -0.3,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            "Vous serez redirigé vers l'écran de connexion.\nVos données locales seront conservées.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.slate500,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 28),

          // Bandeau d'avertissement
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3F3),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.softRed.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 18, color: AppTheme.softRed.withValues(alpha: 0.8)),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Toutes les sessions actives sur cet appareil seront fermées.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.softRed,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Bouton Déconnecter
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _doLogout,
              icon: _isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.logout_rounded, size: 20),
              label: Text(
                _isLoading ? 'Déconnexion...' : 'Oui, me déconnecter',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  letterSpacing: 0.1,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.softRed,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Bouton Annuler
          SizedBox(
            width: double.infinity,
            height: 48,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.slate600,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppTheme.slate200),
                ),
              ),
              child: const Text(
                'Annuler',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper pour afficher le bottom sheet depuis n'importe où.
void showLogoutSheet(BuildContext context, AuthController authController) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => LogoutBottomSheet(authController: authController),
  );
}
