import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/opensearch_api_service.dart';

final opensearchApiServiceProvider = Provider<OpensearchApiService>((ref) {
  // Pe emulator Android, localhost-ul mașinii este 10.0.2.2.
  // Pe web / alte platforme folosim localhost:3000.
  final isAndroidEmulator =
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  final baseUrl =
      isAndroidEmulator ? 'http://10.0.2.2:3000' : 'http://localhost:3000';

  return OpensearchApiService(baseUrl: baseUrl);
});

final opensearchResponseProvider = StateProvider<String?>((ref) => null);
