import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';

import '../../services/backend_api_service.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key, required this.orderId});

  final int orderId;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late final BackendApiService _api;
  bool _isProcessing = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    final isAndroidEmulator =
        !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
    final baseUrl =
        isAndroidEmulator ? 'http://10.0.2.2:3000' : 'http://localhost:3000';
    _api = BackendApiService(baseUrl: baseUrl);
  }

  Future<void> _startPayment() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _statusMessage = null;
    });

    try {
      // 1. Creează intentul de plată (mock pe backend)
      final intentResponse = await _api.createPaymentIntent(
        orderId: widget.orderId,
        amount: 100, // ex: 100 RON pentru demo
      );

      final intentData = intentResponse.data;
      final clientSecret =
          intentData is Map<String, dynamic> ? intentData['clientSecret'] : null;

      // 2. (Într-o integrare reală ai apela aici SDK-ul de plăți, ex. Stripe)
      // Pentru demo, confirmăm direct plata pe backend.

      final confirmResponse = await _api.confirmPayment(
        paymentId: clientSecret?.toString() ?? 'mock_payment_id',
      );

      final confirmData = confirmResponse.data;
      final success = confirmData is Map<String, dynamic>
          ? confirmData['success'] == true
          : false;

      if (!mounted) return;

      setState(() {
        _statusMessage = success
            ? 'Plata a fost procesată cu succes (demo).'
            : 'Plata nu a putut fi confirmată.';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_statusMessage ?? 'Status necunoscut'),
          backgroundColor: success ? Colors.green : Colors.redAccent,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _statusMessage = 'Eroare la procesarea plății: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_statusMessage!),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Plată comandă #${widget.orderId}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Detalii plată (demo)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pentru demonstrație, plata este simulată pe server '
              'și nu se folosește un procesator real (ex. Stripe).',
            ),
            const SizedBox(height: 24),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Suma de plată',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  '100 RON',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Spacer(),
            if (_statusMessage != null) ...[
              Text(
                _statusMessage!,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _startPayment,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Plătește acum'),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
