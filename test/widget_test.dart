// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:paya_app/presentation/pages/auth/splash_page.dart';

void main() {
  testWidgets('SplashPage UI smoke test', (WidgetTester tester) async {
    Get.testMode = true;
    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: '/splash',
        getPages: [
          GetPage(name: '/splash', page: () => const SplashPage()),
          GetPage(
            name: '/login',
            page: () => const Scaffold(body: Text('Login Page')),
          ),
        ],
      ),
    );

    expect(find.text('Paya Pro'), findsOneWidget);
    expect(find.text('Gérez vos ventes en vague avec facilité'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });
}
