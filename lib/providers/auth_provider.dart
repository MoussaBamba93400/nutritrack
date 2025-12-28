import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  loading,
}

class User {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  
  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
  });
  
  /// Full name (firstName + lastName)
  String get fullName => '$firstName $lastName'.trim();
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      firstName: json['first_name'] ?? json['firstName'] ?? '',
      lastName: json['last_name'] ?? json['lastName'] ?? '',
      email: json['email'] ?? '',
    );
  }
}

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  AuthStatus _status = AuthStatus.initial;
  User? _user;
  String? _error;
  
  AuthStatus get status => _status;
  User? get user => _user;
  String? get error => _error;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;
  
  // Check if user is already logged in (on app start)
  Future<void> checkAuthStatus() async {
    _status = AuthStatus.loading;
    notifyListeners();
    
    final token = await _apiService.getToken();
    
    if (token != null) {
      // Verify token by fetching user profile
      final response = await _apiService.get('/user');
      
      if (response.success && response.data != null) {
        _user = User.fromJson(response.data);
        _status = AuthStatus.authenticated;
      } else {
        // Token invalid, clear it
        await _apiService.deleteTokens();
        _status = AuthStatus.unauthenticated;
      }
    } else {
      _status = AuthStatus.unauthenticated;
    }
    
    notifyListeners();
  }
  
  // Login
  Future<bool> login(String email, String password) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();
    
    final response = await _apiService.post('/auth/login', {
      'email': email,
      'password': password,
    }, withAuth: false);
    
    if (response.success && response.data != null) {
      final data = response.data;
      
      // Check if data contains the actual response (might be nested in 'data')
      final responseData = data['data'] ?? data;
      
      // Save token
      if (responseData['token'] != null) {
        await _apiService.saveToken(responseData['token']);
      }
      
      // Save refresh token if provided
      if (responseData['refresh_token'] != null) {
        await _apiService.saveRefreshToken(responseData['refresh_token']);
      }
      
      // Get user data
      if (responseData['user'] != null) {
        _user = User.fromJson(responseData['user']);
      }
      
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } else {
      _error = response.errorMessage ?? 'Erreur de connexion';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }
  
  // Register
  Future<bool> register(String firstName, String lastName, String email, String password, String passwordConfirmation) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();
    
    final response = await _apiService.post('/auth/register', {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'password': password,
    }, withAuth: false);
    
    if (response.success && response.data != null) {
      final data = response.data;
      
      // Check if data contains the actual response (might be nested in 'data')
      final responseData = data['data'] ?? data;
      
      // Save token
      if (responseData['token'] != null) {
        await _apiService.saveToken(responseData['token']);
      }
      
      // Get user data
      if (responseData['user'] != null) {
        _user = User.fromJson(responseData['user']);
      }
      
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } else {
      // Use errorMessage getter which checks both 'errors' and 'message' fields
      _error = response.errorMessage ?? 'Erreur lors de l\'inscription';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }
  
  // Logout
  Future<void> logout() async {
    _status = AuthStatus.loading;
    notifyListeners();
    // Clear tokens
    await _apiService.deleteTokens();
    
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
  
  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

