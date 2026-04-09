import 'package:flutter/material.dart';
import 'package:paya_app/presentation/widgets/main_layout.dart';

/// Helper widget to add a menu button that opens the main drawer
class MenuButton extends StatelessWidget {
  const MenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.menu, color: Color(0xFF1a237e)),
      onPressed: () {
        MainLayout.scaffoldKey.currentState?.openDrawer();
      },
      tooltip: 'Menu',
    );
  }
}

/// Helper widget to provide a back button that also shows menu option
class DrawerAwareAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final List<Widget>? actions;
  final bool showMenuButton;

  const DrawerAwareAppBar({
    super.key,
    this.title,
    this.actions,
    this.showMenuButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title,
      actions: [
        if (showMenuButton) const MenuButton(),
        if (actions != null) ...actions!,
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
