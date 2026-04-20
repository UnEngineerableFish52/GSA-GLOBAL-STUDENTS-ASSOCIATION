import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';

class AppState extends ChangeNotifier {
  final ApiService _apiService;
  final SocketService _socketService;
  
  Map<String, dynamic>? _user;
  bool _verified = false;
  bool _isLoading = false;
  String? _error;
  
  AppState(this._apiService, this._socketService);
  
  Map<String, dynamic>? get user => _user;
  bool get verified => _verified;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;
  
  ApiService get apiService => _apiService;
  SocketService get socketService => _socketService;
  
  Future<void> login() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _apiService.anonymousLogin();
      _user = response['user'];
      _verified = _user?['verified'] ?? false;
      
      // Connect socket
      final token = _apiService.token;
      if (token != null) {
        _socketService.connect(token);
      }
      
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void toggleVerified() {
    _verified = !_verified;
    notifyListeners();
  }
  
  void logout() {
    _user = null;
    _verified = false;
    _socketService.disconnect();
    notifyListeners();
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
