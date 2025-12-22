import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
import 'core/services/connectivity_service.dart';
import 'core/services/subscription_service.dart';
import 'core/services/auth_service.dart';
import 'presentation/widgets/main_layout.dart';
import 'presentation/pages/subscription_page.dart';
import 'presentation/pages/auth/splash_page.dart';
import 'presentation/pages/auth/login_page.dart';
import 'presentation/pages/auth/registration_page.dart';
import 'presentation/pages/products/create_product_page.dart';
import 'presentation/pages/orders/create_order_page.dart';
import 'presentation/pages/customers/customers_page.dart';
import 'presentation/pages/customers/create_customer_page.dart';
import 'presentation/pages/orders/order_details_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Note: Firebase initialization will fail without google-services.json
  // but we provide the structure as requested.
  // Initialize Services
  bool firebaseInitialized = false;
  try {
    await Firebase.initializeApp();
    firebaseInitialized = true;
  } catch (e) {
    debugPrint('Firebase init failed (expected in dev without config): $e');
  }

  if (firebaseInitialized) {
    await Get.putAsync(() => AuthService().init());
    await Get.putAsync(() => SubscriptionService().init());
  } else {
    debugPrint(
      'Skipping Auth/Subscription services due to Firebase init failure',
    );
  }

  Get.put(ConnectivityService());

  runApp(const TontineApp());
}

class TontineApp extends StatelessWidget {
  const TontineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'TontineManager Pro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/splash',
      getPages: [
        GetPage(name: '/splash', page: () => const SplashPage()),
        GetPage(name: '/login', page: () => const LoginPage()),
        GetPage(name: '/register', page: () => const RegistrationPage()),
        GetPage(name: '/', page: () => const MainLayout()),
        GetPage(name: '/subscription', page: () => const SubscriptionPage()),
        GetPage(
          name: '/products/create',
          page: () => const CreateProductPage(),
        ),
        GetPage(name: '/products/edit', page: () => const CreateProductPage()),
        GetPage(name: '/orders/create', page: () => const CreateOrderPage()),
        GetPage(name: '/customers', page: () => const CustomersPage()),
        GetPage(
          name: '/customers/create',
          page: () => const CreateCustomerPage(),
        ),
        GetPage(name: '/orders/details', page: () => const OrderDetailsPage()),
      ],
    );
  }
}
