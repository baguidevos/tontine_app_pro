import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paya_app/core/theme/app_theme.dart';
import 'package:paya_app/data/models/customer_model.dart';
import 'package:paya_app/presentation/controllers/customer_controller.dart';
import 'package:paya_app/presentation/widgets/confirmation_dialog.dart';
import 'create_customer_page.dart';

class CustomersPage extends StatefulWidget {
  const CustomersPage({super.key});

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  final TextEditingController _searchController = TextEditingController();
  final RxString _searchQuery = ''.obs;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customerController = Get.put(CustomerController());

    return Scaffold(
      backgroundColor: AppTheme.warmCream,
      appBar: AppBar(
        title: const Text(
          'Mes Clients',
          style: TextStyle(
            color: AppTheme.deepBlue,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppTheme.deepBlue),
          onPressed: () => Get.back(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => const CreateCustomerPage()),
        backgroundColor: AppTheme.deepBlue,
        elevation: 4,
        icon: const Icon(Icons.person_add_rounded, color: Colors.white, size: 20),
        label: const Text(
          'Nouveau Client',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
      body: Obx(() {
        if (customerController.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.deepBlue),
            ),
          );
        }

        final allCustomers = customerController.customers;
        final query = _searchQuery.value.toLowerCase().trim();
        final filteredCustomers = query.isEmpty
            ? allCustomers
            : allCustomers.where((c) {
                return c.name.toLowerCase().contains(query) ||
                    c.phone.toLowerCase().contains(query) ||
                    (c.address?.toLowerCase().contains(query) ?? false);
              }).toList();

        final totalCustomers = allCustomers.length;
        final indebtedCustomers = allCustomers.where((c) => c.totalCredit > 0).length;
        final totalDebt = allCustomers.fold<double>(0.0, (sum, c) => sum + c.totalCredit);

        return RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 300));
          },
          color: AppTheme.deepBlue,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Metrics overview
                if (totalCustomers > 0) ...[
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricTile(
                          title: 'Total clients',
                          value: '$totalCustomers',
                          icon: Icons.people_alt_rounded,
                          color: AppTheme.deepBlue,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildMetricTile(
                          title: 'Avec créance',
                          value: '$indebtedCustomers',
                          icon: Icons.hourglass_bottom_rounded,
                          color: indebtedCustomers > 0 ? AppTheme.payaOrange : AppTheme.payaGreen,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildMetricTile(
                          title: 'Total créances',
                          value: '${totalDebt.toStringAsFixed(0)} F',
                          icon: Icons.account_balance_wallet_outlined,
                          color: totalDebt > 0 ? AppTheme.softRed : AppTheme.payaGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                // Search field
                TextField(
                  controller: _searchController,
                  onChanged: (val) => _searchQuery.value = val,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Rechercher par nom, téléphone...',
                    hintStyle: const TextStyle(color: AppTheme.slate400, fontSize: 13),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.slate400, size: 20),
                    suffixIcon: Obx(() => _searchQuery.value.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18, color: AppTheme.slate400),
                            onPressed: () {
                              _searchController.clear();
                              _searchQuery.value = '';
                            },
                          )
                        : const SizedBox.shrink()),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppTheme.slate200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppTheme.slate200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppTheme.deepBlue, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Customer list or empty state
                if (allCustomers.isEmpty)
                  _buildEmptyState(
                    title: 'Aucun client enregistré',
                    subtitle: 'Ajoutez votre premier client pour enregistrer ses commandes et suivre ses paiements.',
                    showButton: true,
                  )
                else if (filteredCustomers.isEmpty)
                  _buildEmptyState(
                    title: 'Aucun résultat trouvé',
                    subtitle: 'Aucun client ne correspond au filtre "$query".',
                    showButton: false,
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredCustomers.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final customer = filteredCustomers[index];
                      return _buildCustomerCard(customer, customerController);
                    },
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.slate200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.slate500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(CustomerModel customer, CustomerController controller) {
    final initials = customer.name.trim().isNotEmpty
        ? customer.name.trim().split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase()
        : '?';

    final hasDebt = customer.totalCredit > 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: hasDebt ? AppTheme.softRed.withValues(alpha: 0.25) : AppTheme.slate200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: () => Get.to(() => CreateCustomerPage(customer: customer)),
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppTheme.deepBlue.withValues(alpha: 0.08),
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: AppTheme.deepBlue,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              customer.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: AppTheme.slate900,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (customer.sexe != null && customer.sexe!.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.slate100,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                customer.sexe!,
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: AppTheme.slate600,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.phone_outlined, size: 13, color: AppTheme.slate400),
                          const SizedBox(width: 4),
                          Text(
                            customer.phone,
                            style: const TextStyle(
                              color: AppTheme.slate600,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      if (hasDebt) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.softRed.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Créance : ${customer.totalCredit.toStringAsFixed(0)} FCFA',
                            style: const TextStyle(
                              color: AppTheme.softRed,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: AppTheme.slate500, size: 20),
                      tooltip: 'Modifier',
                      onPressed: () => Get.to(() => CreateCustomerPage(customer: customer)),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(8),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.softRed, size: 20),
                      tooltip: 'Supprimer',
                      onPressed: () {
                        Get.dialog(
                          ConfirmationDialog(
                            title: 'Supprimer le client',
                            message: 'Voulez-vous vraiment supprimer "${customer.name}" ? Cette action est irréversible.',
                            confirmText: 'Supprimer',
                            isDanger: true,
                            onConfirm: () async {
                              Get.back();
                              await controller.deleteCustomer(customer.id);
                            },
                          ),
                        );
                      },
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(8),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required String title,
    required String subtitle,
    required bool showButton,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.slate200),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.deepBlue.withValues(alpha: 0.06),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.people_outline_rounded,
              size: 42,
              color: AppTheme.deepBlue,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.slate900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: AppTheme.slate500),
          ),
          if (showButton) ...[
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => Get.to(() => const CreateCustomerPage()),
              icon: const Icon(Icons.person_add_rounded, size: 18),
              label: const Text('Ajouter un client'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.deepBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
