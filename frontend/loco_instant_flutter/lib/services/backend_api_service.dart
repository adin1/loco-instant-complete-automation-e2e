import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/provider_search_result.dart';

class BackendApiService {
  final Dio _dio;
  final String baseUrl;

  BackendApiService({
    required this.baseUrl,
    Dio? dio,
  }) : _dio = dio ?? Dio() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('auth_token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  /// Search providers around a given location
  Future<List<ProviderSearchResult>> searchProviders({
    required String q,
    required double lat,
    required double lon,
    String radius = '5km',
  }) async {
    try {
      final response = await _dio.get(
        '$baseUrl/search/providers',
        queryParameters: <String, dynamic>{
          'q': q,
          'lat': lat.toString(),
          'lon': lon.toString(),
          'radius': radius,
        },
      );

      final data = response.data;
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(ProviderSearchResult.fromJson)
            .toList();
      }

      if (data is Map<String, dynamic> && data['results'] is List) {
        final results = data['results'] as List<dynamic>;
        return results
            .whereType<Map<String, dynamic>>()
            .map(ProviderSearchResult.fromJson)
            .toList();
      }

      return const <ProviderSearchResult>[];
    } catch (_) {
      // Fallback demo providers when backend or search is unavailable
      return <ProviderSearchResult>[
        ProviderSearchResult(
          id: 'p1',
          tenantCode: 'cluj',
          providerId: '1',
          name: 'Electrician non-stop',
          serviceIds: const ['auto'],
          serviceNames: const ['Electrician', 'Intervenții rapide'],
          ratingAvg: 4.8,
          ratingCount: 32,
          isInstant: true,
          lat: lat + 0.01,
          lon: lon + 0.01,
        ),
        ProviderSearchResult(
          id: 'p2',
          tenantCode: 'cluj',
          providerId: '2',
          name: 'Instalator urgențe',
          serviceIds: const ['croitorie'],
          serviceNames: const ['Instalator', 'Urgent'],
          ratingAvg: 4.5,
          ratingCount: 18,
          isInstant: true,
          lat: lat - 0.01,
          lon: lon - 0.01,
        ),
      ];
    }
  }

  /// Create a new order (service request)
  Future<Response<dynamic>> createOrder({
    required int customerId,
    required int serviceId,
    int? providerId,
    required String status,
    double? priceEstimate,
    String? currency,
    required double originLat,
    required double originLng,
  }) async {
    final body = <String, dynamic>{
      'customerId': customerId,
      'serviceId': serviceId,
      if (providerId != null) 'providerId': providerId,
      'status': status,
      if (priceEstimate != null) 'priceEstimate': priceEstimate,
      if (currency != null) 'currency': currency,
      'originLat': originLat,
      'originLng': originLng,
    };

    try {
      return await _dio.post('$baseUrl/orders', data: body);
    } on DioException {
      // Fallback local demo response when backend is not reachable
      return Response<dynamic>(
        requestOptions: RequestOptions(path: '$baseUrl/orders'),
        data: <String, dynamic>{
          'id': DateTime.now().millisecondsSinceEpoch,
          'status': status,
        },
        statusCode: 200,
      );
    }
  }

  /// Send a chat message related to an order or provider
  Future<Response<dynamic>> sendChatMessage({
    required int orderId,
    required String message,
    String? fromRole,
  }) async {
    final body = <String, dynamic>{
      'orderId': orderId,
      'message': message,
      if (fromRole != null) 'fromRole': fromRole,
    };

    return _dio.post('$baseUrl/chat/send', data: body);
  }

  /// Create a mock payment intent (backend currently returns test data)
  Future<Response<dynamic>> createPaymentIntent({
    required int orderId,
    required int amount,
    String currency = 'RON',
  }) async {
    final body = <String, dynamic>{
      'orderId': orderId,
      'amount': amount,
      'currency': currency,
    };

    return _dio.post('$baseUrl/payments/intent', data: body);
  }

  /// Confirm a mock payment
  Future<Response<dynamic>> confirmPayment({
    required String paymentId,
  }) async {
    final body = <String, dynamic>{
      'paymentId': paymentId,
    };

    return _dio.post('$baseUrl/payments/confirm', data: body);
  }

  /// Create a review / rating for a completed order
  Future<Response<dynamic>> createReview({
    required int orderId,
    required int rating,
    String? comment,
  }) async {
    final body = <String, dynamic>{
      'orderId': orderId,
      'rating': rating,
      if (comment != null && comment.isNotEmpty) 'comment': comment,
    };

    return _dio.post('$baseUrl/reviews', data: body);
  }
}


