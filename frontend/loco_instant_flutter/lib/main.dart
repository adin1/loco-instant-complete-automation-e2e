import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/opensearch/opensearch_crud_screen.dart';
import 'features/home/home_screen.dart';
import 'features/home/client_home_screen.dart';
import 'features/chat/chat_screen.dart';
import 'features/payments/payment_screen.dart';
import 'features/reviews/review_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/orders/orders_history_screen.dart';
import 'features/orders/order_detail_screen.dart';
import 'features/orders/evidence_upload_screen.dart';
import 'features/orders/report_problem_screen.dart';
import 'features/info/payment_policy_screen.dart';
import 'features/info/how_it_works_screen.dart';
import 'features/info/terms_client_screen.dart';
import 'features/info/terms_prestator_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/notifications/notifications_screen.dart';
import 'features/provider/provider_dashboard_screen.dart';
import 'features/provider/provider_services_screen.dart';
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
      builder: (context, state) => const ClientHomeScreen(),
      routes: [
        GoRoute(
          path: 'map',
          builder: (context, state) => const HomeScreen(),
        ),
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
          path: 'order/:orderId',
          builder: (context, state) {
            final idParam = state.pathParameters['orderId'] ?? '0';
            final orderId = int.tryParse(idParam) ?? 0;
            return OrderDetailScreen(orderId: orderId);
          },
        ),
        GoRoute(
          path: 'order/:orderId/evidence',
          builder: (context, state) {
            final idParam = state.pathParameters['orderId'] ?? '0';
            final orderId = int.tryParse(idParam) ?? 0;
            return EvidenceUploadScreen(orderId: orderId);
          },
        ),
        GoRoute(
          path: 'order/:orderId/report',
          builder: (context, state) {
            final idParam = state.pathParameters['orderId'] ?? '0';
            final orderId = int.tryParse(idParam) ?? 0;
            return ReportProblemScreen(orderId: orderId);
          },
        ),
        GoRoute(
          path: 'payment-policy',
          builder: (context, state) => const PaymentPolicyScreen(),
        ),
        GoRoute(
          path: 'how-it-works',
          builder: (context, state) => const HowItWorksScreen(),
        ),
        GoRoute(
          path: 'terms-client',
          builder: (context, state) => const TermsClientScreen(),
        ),
        GoRoute(
          path: 'terms-prestator',
          builder: (context, state) => const TermsPrestatorScreen(),
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
    // Rute pentru prestatori
    GoRoute(
      path: '/provider',
      builder: (context, state) => const ProviderDashboardScreen(),
      routes: [
        GoRoute(
          path: 'services',
          builder: (context, state) => const ProviderServicesScreen(),
        ),
        GoRoute(
          path: 'orders',
          builder: (context, state) => const OrdersHistoryScreen(), // TODO: Provider orders
        ),
        GoRoute(
          path: 'profile',
          builder: (context, state) => const ProfileScreen(), // TODO: Provider profile
        ),
        GoRoute(
          path: 'chat/:orderId',
          builder: (context, state) {
            final idParam = state.pathParameters['orderId'] ?? '0';
            final orderId = int.tryParse(idParam) ?? 0;
            return ChatScreen(orderId: orderId);
          },
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
