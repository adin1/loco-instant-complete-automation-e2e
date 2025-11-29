import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final Dio _dio;
  final String baseUrl;

  AuthService({
    required this.baseUrl,
    Dio? dio,
  }) : _dio = dio ?? Dio();

  static const _tokenKey = 'auth_token';

  Future<String> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      '$baseUrl/auth/login',
      data: <String, dynamic>{
        'email': email,
        'password': password,
      },
    );

    final data = response.data;
    if (data is! Map<String, dynamic> || data['access_token'] is! String) {
      throw Exception('Răspuns neașteptat de la server');
    }

    final token = data['access_token'] as String;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);

    return token;
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      '$baseUrl/auth/register',
      data: <String, dynamic>{
        'name': name,
        'email': email,
        'password': password,
      },
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Înregistrare eșuată');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }
}


