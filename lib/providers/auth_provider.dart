import 'package:flutter/material.dart';
import 'package:appwrite/models.dart';
import '../services/appwrite_service.dart';

class AuthProvider with ChangeNotifier {
  final AppwriteService _appwriteService = AppwriteService();
  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _appwriteService.getCurrentUser();
    } catch (e) {
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _appwriteService.login(email, password);
      _user = await _appwriteService.getCurrentUser();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception('Login gagal: ${e.toString()}');
    }
  }

  Future<bool> register(String email, String password, String name) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _appwriteService.register(email, password, name);
      await _appwriteService.login(email, password);
      _user = await _appwriteService.getCurrentUser();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception('Registrasi gagal: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    try {
      await _appwriteService.logout();
      _user = null;
      notifyListeners();
    } catch (e) {
      throw Exception('Logout gagal: ${e.toString()}');
    }
  }
}