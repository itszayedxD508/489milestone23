import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/user_service.dart';

class AuthProvider extends ChangeNotifier {
  final UserService _userService = UserService();

  User? _currentUser;
  bool _isLoading = true;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _initAuth();
  }

  Future<void> _initAuth() async {
    _currentUser = await _userService.getCurrentUser();
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _userService.login(email, password);
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return user != null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signup(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _userService.signup(email, password);
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return user != null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await _userService.logout();
    _currentUser = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshUser() async {
    _currentUser = await _userService.getCurrentUser();
    notifyListeners();
  }
}
