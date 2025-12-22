import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../controllers/customer_controller.dart';
import '../../../data/models/customer_model.dart';
import 'create_customer_page.dart';

class CustomersPage extends StatelessWidget {
  const CustomersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final customerController = Get.put(CustomerController());

    return Scaffold(
      backgroundColor: AppTheme.warmCream,
      appBar: AppBar(
        title: const Text(
          'Mes Clients',
          style: TextStyle(color: AppTheme.deepBlue),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.deepBlue),
          onPressed: () => Get.back(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => const CreateCustomerPage()),
        backgroundColor: AppTheme.deepBlue,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text(
          'Nouveau Client',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Obx(() {
        if (customerController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (customerController.customers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 80,
                  color: AppTheme.deepBlue.withOpacity(0.2),
                ),
                const SizedBox(height: 16),
                Text(
                  'Aucun client',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 18),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: customerController.customers.length,
          itemBuilder: (context, index) {
            final customer = customerController.customers[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.deepBlue.withOpacity(0.1),
                  child: Text(
                    customer.name[0].toUpperCase(),
                    style: const TextStyle(
                      color: AppTheme.deepBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  customer.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(customer.phone),
                    if (customer.totalCredit > 0)
                      Text(
                        'Dette: ${customer.totalCredit.toStringAsFixed(0)} FCFA',
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.edit, color: Colors.grey),
                  onPressed: () =>
                      Get.to(() => CreateCustomerPage(customer: customer)),
                ),
                onTap: () {
                  // Navigate to customer details/history
                },
              ),
            );
          },
        );
      }),
    );
  }
}
