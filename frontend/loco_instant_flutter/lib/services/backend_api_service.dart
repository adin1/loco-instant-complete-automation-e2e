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
      // Fallback demo providers - coordonate fixe în Cluj-Napoca
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
          lat: 46.778,  // Cluj-Napoca centru
          lon: 23.601,
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
          lat: 46.765,  // Cluj-Napoca Mărăști
          lon: 23.585,
        ),
        ProviderSearchResult(
          id: 'p3',
          tenantCode: 'cluj',
          providerId: '3',
          name: 'Curățenie profesională',
          serviceIds: const ['menaj'],
          serviceNames: const ['Curățenie', 'Menaj'],
          ratingAvg: 4.9,
          ratingCount: 56,
          isInstant: true,
          lat: 46.772,  // Cluj-Napoca Gheorgheni
          lon: 23.612,
        ),
        ProviderSearchResult(
          id: 'p4',
          tenantCode: 'cluj',
          providerId: '4',
          name: 'Mecanic auto rapid',
          serviceIds: const ['auto'],
          serviceNames: const ['Mecanic', 'Auto'],
          ratingAvg: 4.6,
          ratingCount: 41,
          isInstant: true,
          lat: 46.758,  // Cluj-Napoca Zorilor
          lon: 23.572,
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

  // ========================================
  // ORDER WORKFLOW ENDPOINTS
  // ========================================

  /// Get order by ID with full details
  Future<Response<dynamic>> getOrderById(int orderId) async {
    return _dio.get('$baseUrl/orders/$orderId');
  }

  /// Get order status timeline
  Future<Response<dynamic>> getOrderTimeline(int orderId) async {
    return _dio.get('$baseUrl/orders/$orderId/timeline');
  }

  /// Provider marks as en route
  Future<Response<dynamic>> markEnRoute(int orderId) async {
    return _dio.post('$baseUrl/orders/$orderId/en-route');
  }

  /// Provider starts work
  Future<Response<dynamic>> startWork(int orderId) async {
    return _dio.post('$baseUrl/orders/$orderId/start-work');
  }

  /// Provider completes work
  Future<Response<dynamic>> completeWork(int orderId, {String? notes}) async {
    return _dio.post('$baseUrl/orders/$orderId/complete-work', data: {
      if (notes != null) 'completionNotes': notes,
    });
  }

  /// Customer confirms work
  Future<Response<dynamic>> confirmOrder(int orderId, {int? rating, String? feedback}) async {
    return _dio.post('$baseUrl/orders/$orderId/confirm', data: {
      if (rating != null) 'rating': rating,
      if (feedback != null) 'feedback': feedback,
    });
  }

  // ========================================
  // EVIDENCE ENDPOINTS
  // ========================================

  /// Get evidence for an order
  Future<Response<dynamic>> getEvidence(int orderId) async {
    return _dio.get('$baseUrl/evidence/order/$orderId');
  }

  /// Get upload URL for evidence
  Future<Response<dynamic>> getEvidenceUploadUrl({
    required int orderId,
    required String evidenceType,
    required String mediaType,
    required String fileName,
    required int fileSize,
  }) async {
    return _dio.post('$baseUrl/evidence/upload-url', data: {
      'orderId': orderId,
      'evidenceType': evidenceType,
      'mediaType': mediaType,
      'fileName': fileName,
      'fileSize': fileSize,
    });
  }

  /// Create evidence record after upload
  Future<Response<dynamic>> createEvidence({
    required int orderId,
    required String evidenceType,
    required String mediaType,
    required String fileUrl,
    String? thumbnailUrl,
    String? description,
  }) async {
    return _dio.post('$baseUrl/evidence', data: {
      'orderId': orderId,
      'evidenceType': evidenceType,
      'mediaType': mediaType,
      'fileUrl': fileUrl,
      if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
      if (description != null) 'description': description,
    });
  }

  /// Check if required evidence exists
  Future<Response<dynamic>> checkEvidenceRequired(int orderId) async {
    return _dio.get('$baseUrl/evidence/order/$orderId/check');
  }

  // ========================================
  // DISPUTE ENDPOINTS
  // ========================================

  /// Create a dispute (report problem)
  Future<Response<dynamic>> createDispute({
    required int orderId,
    required String category,
    required String title,
    required String description,
    String? whatNotWorking,
    String? technicalDetails,
    List<String>? evidenceUrls,
  }) async {
    return _dio.post('$baseUrl/disputes', data: {
      'orderId': orderId,
      'category': category,
      'title': title,
      'description': description,
      if (whatNotWorking != null) 'whatNotWorking': whatNotWorking,
      if (technicalDetails != null) 'technicalDetails': technicalDetails,
      if (evidenceUrls != null) 'evidenceUrls': evidenceUrls,
    });
  }

  /// Get dispute by ID
  Future<Response<dynamic>> getDispute(int disputeId) async {
    return _dio.get('$baseUrl/disputes/$disputeId');
  }

  /// Get disputes for an order
  Future<Response<dynamic>> getDisputesByOrder(int orderId) async {
    return _dio.get('$baseUrl/disputes/order/$orderId');
  }

  // ========================================
  // PAYMENT ESCROW ENDPOINTS
  // ========================================

  /// Get payment status for an order
  Future<Response<dynamic>> getPaymentByOrder(int orderId) async {
    return _dio.get('$baseUrl/payments/order/$orderId');
  }

  /// Authorize payment (pre-auth)
  Future<Response<dynamic>> authorizePayment({
    required int paymentId,
    required String paymentMethodId,
  }) async {
    return _dio.post('$baseUrl/payments/authorize', data: {
      'paymentId': paymentId,
      'stripePaymentMethodId': paymentMethodId,
    });
  }

  /// Release escrow payment
  Future<Response<dynamic>> releasePayment(int paymentId, {String? notes}) async {
    return _dio.post('$baseUrl/payments/release', data: {
      'paymentId': paymentId,
      if (notes != null) 'notes': notes,
    });
  }

  // ========================================
  // CHAT ENDPOINTS
  // ========================================

  /// Get chat messages for an order
  Future<Response<dynamic>> getChatMessages(int orderId, {int? limit, String? before}) async {
    return _dio.get('$baseUrl/chat/order/$orderId', queryParameters: {
      if (limit != null) 'limit': limit,
      if (before != null) 'before': before,
    });
  }

  /// Mark messages as read
  Future<Response<dynamic>> markMessagesRead(int orderId) async {
    return _dio.post('$baseUrl/chat/mark-read', data: {
      'orderId': orderId,
    });
  }

  /// Get unread count
  Future<Response<dynamic>> getUnreadCount(int orderId) async {
    return _dio.get('$baseUrl/chat/order/$orderId/unread');
  }

  // ========================================
  // BLOCK/RATING ENDPOINTS
  // ========================================

  /// Block a user
  Future<Response<dynamic>> blockUser({
    required int userId,
    required String reason,
    String? notes,
  }) async {
    return _dio.post('$baseUrl/reviews/block', data: {
      'userId': userId,
      'reason': reason,
      if (notes != null) 'notes': notes,
    });
  }

  /// Unblock a user
  Future<Response<dynamic>> unblockUser(int userId) async {
    return _dio.delete('$baseUrl/reviews/block/$userId');
  }

  /// Check if blocked
  Future<Response<dynamic>> checkBlocked(int userId) async {
    return _dio.get('$baseUrl/reviews/block/check/$userId');
  }
}


