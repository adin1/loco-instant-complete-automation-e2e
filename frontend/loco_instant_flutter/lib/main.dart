import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'features/auth/login_screen.dart';
import 'features/opensearch/opensearch_crud_screen.dart';
import 'features/home/home_screen.dart';
import 'features/chat/chat_screen.dart';
import 'features/payments/payment_screen.dart';
import 'features/reviews/review_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

// Define router
final _router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
      routes: [
        GoRoute(
          path: 'opensearch',
          builder: (context, state) => const OpensearchCrudScreen(),
        ),
        GoRoute(
          path: 'chat/:orderId',
          builder: (context, state) {
            final idParam = state.pathParameters['orderId'] ?? '0';
            final orderId = int.tryParse(idParam) ?? 0;
            return ChatScreen(orderId: orderId);
          },
        ),
        GoRoute(
          path: 'payment/:orderId',
          builder: (context, state) {
            final idParam = state.pathParameters['orderId'] ?? '0';
            final orderId = int.tryParse(idParam) ?? 0;
            return PaymentScreen(orderId: orderId);
          },
        ),
        GoRoute(
          path: 'review/:orderId',
          builder: (context, state) {
            final idParam = state.pathParameters['orderId'] ?? '0';
            final orderId = int.tryParse(idParam) ?? 0;
            return ReviewScreen(orderId: orderId);
          },
        ),
      ],
    ),
  ],
);

// App root
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF2563EB); // albastru LOCO Instant
    const surfaceColor = Color(0xFFF3F4F6);

    return MaterialApp.router(
      routerConfig: _router,
      title: 'LOCO Instant',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: surfaceColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: primaryColor,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: primaryColor,
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 8,
          shadowColor: Colors.black.withValues(alpha: 0.08),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
