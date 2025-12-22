import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../waves/waves_page.dart';
import '../products/products_page.dart';

class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppTheme.warmCream,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Inventaire',
            style: TextStyle(
              color: AppTheme.deepBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: const TabBar(
            labelColor: AppTheme.deepBlue,
            indicatorColor: AppTheme.deepBlue,
            tabs: [
              Tab(text: 'Vagues'),
              Tab(text: 'Produits'),
            ],
          ),
        ),
        body: const TabBarView(children: [WavesPage(), ProductsPage()]),
      ),
    );
  }
}
