import 'package:dio/dio.dart';

class OpensearchApiService {
  final Dio _dio;
  final String baseUrl;

  // Replace with environment-specific config if needed. For Flutter web, use a .env file or a runtime config.
  // For auth, adjust Dio options (e.g., add headers, interceptors).
  OpensearchApiService({
    required this.baseUrl,
    Dio? dio,
  }) : _dio = dio ?? Dio();

  Future<Response> createDocument({
    required String index,
    required String id,
    required Map<String, dynamic> document,
  }) async {
    return await _dio.post(
      '$baseUrl/opensearch/$index/$id',
      data: {'document': document},
    );
  }

  Future<Response> getDocument({
    required String index,
    required String id,
  }) async {
    return await _dio.get('$baseUrl/opensearch/$index/$id');
  }

  Future<Response> updateDocument({
    required String index,
    required String id,
    required Map<String, dynamic> document,
  }) async {
    return await _dio.put(
      '$baseUrl/opensearch/$index/$id',
      data: {'document': document},
    );
  }

  Future<Response> deleteDocument({
    required String index,
    required String id,
  }) async {
    return await _dio.delete('$baseUrl/opensearch/$index/$id');
  }

  Future<Response> searchDocuments({
    required String index,
    required Map<String, dynamic> body,
  }) async {
    return await _dio.post(
      '$baseUrl/opensearch/$index/_search',
      data: body,
    );
  }
}
