import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  // TODO: Change this to your actual API URL
  static const String baseUrl = 'http://localhost:8000/api';
  
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  // Token keys
  static const String _tokenKey = 'jwt_token';
  static const String _refreshTokenKey = 'refresh_token';
  
  // Get stored token
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }
  
  // Store token
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }
  
  // Store refresh token
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }
  
  // Get refresh token
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }
  
  // Delete tokens (logout)
  Future<void> deleteTokens() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }
  
  // Get headers with auth token
  Future<Map<String, String>> _getHeaders({bool withAuth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (withAuth) {
      final token = await getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    
    return headers;
  }
  
  // GET request
  Future<ApiResponse> get(String endpoint, {bool withAuth = true}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _getHeaders(withAuth: withAuth),
      );
      return ApiResponse.fromResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        statusCode: 0,
        message: 'Erreur de connexion: $e',
      );
    }
  }
  
  // POST request
  Future<ApiResponse> post(String endpoint, Map<String, dynamic> data, {bool withAuth = true}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _getHeaders(withAuth: withAuth),
        body: jsonEncode(data),
      );
      return ApiResponse.fromResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        statusCode: 0,
        message: 'Erreur de connexion: $e',
      );
    }
  }
  
  // PUT request
  Future<ApiResponse> put(String endpoint, Map<String, dynamic> data, {bool withAuth = true}) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _getHeaders(withAuth: withAuth),
        body: jsonEncode(data),
      );
      return ApiResponse.fromResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        statusCode: 0,
        message: 'Erreur de connexion: $e',
      );
    }
  }
  
  // DELETE request
  Future<ApiResponse> delete(String endpoint, {bool withAuth = true}) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _getHeaders(withAuth: withAuth),
      );
      return ApiResponse.fromResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        statusCode: 0,
        message: 'Erreur de connexion: $e',
      );
    }
  }
}

class ApiResponse {
  final bool success;
  final int statusCode;
  final dynamic data;
  final String? message;
  final dynamic errors;
  
  ApiResponse({
    required this.success,
    required this.statusCode,
    this.data,
    this.message,
    this.errors,
  });
  
  /// Get error message from either 'errors' or 'message' field
  String? get errorMessage {
    if (errors != null) {
      if (errors is String) return errors;
      if (errors is Map) {
        // Handle validation errors like { "email": ["The email is required"] }
        final firstError = (errors as Map).values.first;
        if (firstError is List && firstError.isNotEmpty) {
          return firstError.first.toString();
        }
        return firstError.toString();
      }
    }
    return message;
  }
  
  factory ApiResponse.fromResponse(http.Response response) {
    dynamic jsonData;
    String? message;
    dynamic errors;
    
    try {
      jsonData = jsonDecode(response.body);
      if (jsonData is Map) {
        if (jsonData.containsKey('message')) {
          message = jsonData['message'];
        }
        if (jsonData.containsKey('errors')) {
          errors = jsonData['errors'];
        }
      }
    } catch (_) {
      jsonData = response.body;
    }
    
    return ApiResponse(
      success: response.statusCode >= 200 && response.statusCode < 300,
      statusCode: response.statusCode,
      data: jsonData,
      message: message,
      errors: errors,
    );
  }
}

