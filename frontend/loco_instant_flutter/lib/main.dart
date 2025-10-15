import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(const LocoApp());
}

class LocoApp extends StatelessWidget {
  const LocoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/home', builder: (_, __) => const HomePage()),
    ]);

    return MaterialApp.router(
      title: 'Loco Instant',
      routerConfig: router,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final pass = TextEditingController();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: email, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: pass, decoration: const InputDecoration(labelText: 'Parola'), obscureText: true),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: loading ? null : () async { context.go('/home'); },
              child: Text(loading ? '...' : 'Continuă'),
            )
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Loco Instant')),
      body: const Center(child: Text('Skeleton Flutter – conectează API-ul backend aici')),
    );
  }
}