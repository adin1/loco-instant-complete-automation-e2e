import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/opensearch/opensearch_crud_screen.dart';
import 'features/home/home_screen.dart';
import 'features/chat/chat_screen.dart';
import 'features/payments/payment_screen.dart';
import 'features/reviews/review_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/orders/orders_history_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/notifications/notifications_screen.dart';
import 'providers/theme_provider.dart';

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
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
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
        GoRoute(
          path: 'profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: 'orders',
          builder: (context, state) => const OrdersHistoryScreen(),
        ),
        GoRoute(
          path: 'settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: 'notifications',
          builder: (context, state) => const NotificationsScreen(),
        ),
      ],
    ),
  ],
);

// App root with Dark Mode support
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      routerConfig: _router,
      title: 'LOCO Instant',
      debugShowCheckedModeBanner: false,
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: themeMode,
    );
  }
}
