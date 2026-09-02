import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/services/connectivity_service.dart';
import 'core/services/subscription_service.dart';
import 'core/services/auth_service.dart';
import 'core/services/image_server_service.dart';
import 'core/utils/http_overrides.dart';
import 'presentation/widgets/main_layout.dart';
import 'presentation/pages/subscription_page.dart';
import 'presentation/pages/auth/splash_page.dart';
import 'presentation/pages/auth/login_page.dart';
import 'presentation/pages/auth/registration_page.dart';
import 'presentation/pages/products/create_product_page.dart';
import 'presentation/pages/orders/create_order_page.dart';
import 'presentation/pages/customers/customers_page.dart';
import 'presentation/pages/customers/create_customer_page.dart';
import 'presentation/pages/waves/wave_details_page.dart';
import 'presentation/pages/orders/order_details_page.dart';
import 'presentation/pages/products/product_details_page.dart';
import 'presentation/pages/public/public_order_page.dart';

// Bindings
import 'presentation/bindings/main_layout_binding.dart';
import 'presentation/bindings/order_binding.dart';
import 'presentation/bindings/inventory_binding.dart';
import 'presentation/bindings/customer_binding.dart';
import 'presentation/bindings/public_order_binding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  setupDevHttpOverrides();

  // Initialize Services
  bool firebaseInitialized = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseInitialized = true;
  } catch (e) {
    debugPrint('Firebase init failed: $e');
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
  Get.put(ImageServerService());

  runApp(const PayaApp());
}

class PayaApp extends StatelessWidget {
  const PayaApp({super.key});

  String _determineInitialRoute() {
    if (kIsWeb) {
      final fullUrl = Uri.base.toString();
      if (fullUrl.contains('order') ||
          fullUrl.contains('p=') ||
          fullUrl.contains('productId=')) {
        return '/order';
      }
    }
    return '/splash';
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Paya',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: _determineInitialRoute(),
      getPages: [
        GetPage(
          name: '/order',
          page: () => const PublicOrderPage(),
          binding: PublicOrderBinding(),
        ),
        GetPage(name: '/splash', page: () => const SplashPage()),
        GetPage(name: '/login', page: () => const LoginPage()),
        GetPage(name: '/register', page: () => const RegistrationPage()),
        GetPage(
          name: '/',
          page: () => const MainLayout(),
          binding: MainLayoutBinding(),
        ),
        GetPage(name: '/subscription', page: () => const SubscriptionPage()),
        GetPage(
          name: '/products/create',
          page: () => const CreateProductPage(),
          binding: InventoryBinding(),
        ),
        GetPage(
          name: '/products/edit',
          page: () => const CreateProductPage(),
          binding: InventoryBinding(),
        ),
        GetPage(
          name: '/orders/create',
          page: () => const CreateOrderPage(),
          binding: OrderBinding(),
        ),
        GetPage(
          name: '/customers',
          page: () => const CustomersPage(),
          binding: CustomerBinding(),
        ),
        GetPage(
          name: '/customers/create',
          page: () => const CreateCustomerPage(),
          binding: CustomerBinding(),
        ),
        GetPage(
          name: '/orders/details',
          page: () => const OrderDetailsPage(),
          binding: OrderBinding(),
        ),
        GetPage(
          name: '/waves/details',
          page: () => const WaveDetailsPage(),
          binding: OrderBinding(),
        ),
        GetPage(
          name: '/products/details',
          page: () => const ProductDetailsPage(),
        ),
      ],
    );
  }
}
