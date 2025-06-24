import 'package:lostmate/Data/app_data.dart';
import 'package:lostmate/Data/models/profile.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../Data/app_data.dart';


class AuthService {
  static final AuthService _instance = AuthService._internal();
  late final PocketBase _pb;
  bool _isInitialized = false;


  factory AuthService() {
    return _instance;
  }


  AuthService._internal() {
    const baseUrl = String.fromEnvironment('POCKETBASE_URL', defaultValue: 'http://127.0.0.1:8090');
    _pb = PocketBase(baseUrl);
    _initializeAuth(); // Load saved auth data
  }




  // Initialize dan load saved auth data
  Future<void> _initializeAuth() async {
    if (_isInitialized) return;
   
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString('auth_token');
      final savedModelJson = prefs.getString('auth_model');
     
      if (savedToken != null && savedModelJson != null) {
        try {
          // Parse saved model JSON
          final modelData = jsonDecode(savedModelJson);
          final model = RecordModel.fromJson(modelData);
         
          // Restore auth store dari saved data
          _pb.authStore.save(savedToken, model);
          print('Auth data restored from storage');
          print('User ID after restore: ${_pb.authStore.model?.id}');
          print('Is valid after restore: ${_pb.authStore.isValid}');
         
          // Try to refresh auth to make sure it's still valid
          if (_pb.authStore.isValid) {
            try {
              await _pb.collection('users').authRefresh();
              print('Auth refreshed successfully after restore');
            } catch (e) {
              print('Auth refresh failed, clearing stored data: $e');
              await _clearAuthData();
              _pb.authStore.clear();
            }
          }
        } catch (e) {
          print('Error parsing saved auth data: $e');
          await _clearAuthData();
        }
      } else {
        print('No saved auth data found');
      }
    } catch (e) {
      print('Error loading auth data: $e');
    }
   
    _isInitialized = true;
  }


  // Simpan auth data ke storage
Future<void> _saveAuthData() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    if (_pb.authStore.isValid) {
      await prefs.setString('auth_token', _pb.authStore.token);
      // INCORRECT LINE
      await prefs.setString('auth_model', _pb.authStore.model.toString()); 
      print('Auth data saved to storage');
    }
  } catch (e) {
    print('Error saving auth data: $e');
  }
}


  // Clear auth data dari storage
  Future<void> _clearAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('auth_model');
      print('Auth data cleared from storage');
    } catch (e) {
      print('Error clearing auth data: $e');
    }
  }


  Future<void> testConnection() async {
    try {
      final response = await http.get(Uri.parse(_pb.baseUrl));
      print('Respons server: ${response.statusCode}');
    } catch (e) {
      print('Uji koneksi gagal: $e');
    }
  }


  Future<void> register({
    required String email,
    required String password,
    required String passwordConfirm,
    required String name,
    required String phone,
  }) async {
    try {
      final body = <String, dynamic>{
        "email": email,
        "password": password,
        "passwordConfirm": passwordConfirm,
        "name": name,
        "phone": phone,
      };
      print('Mengirim ke: ${_pb.baseUrl}/api/collections/users/records');
      print('Body: $body');
      final response = await _pb.collection('users').create(body: body);
      print('Pengguna dibuat: $response');
     
      // Otomatis login setelah register berhasil
      print('Mencoba login otomatis...');
      await login(email: email, password: password);
      print('Login otomatis berhasil!');
    } catch (e) {
      print('Kesalahan registrasi: $e');
      rethrow;
    }
  }


  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final authData = await _pb.collection('users').authWithPassword(email, password);
     
      // Simpan auth data setelah login berhasil
      await _saveAuthData();
     
      print('Login berhasil!');
      print('User ID: ${authData.record?.id}');
      print('Auth token: ${authData.token}');
      print('Auth store valid: ${_pb.authStore.isValid}');
     
      return {
        'id': authData.record?.id,
        'email': authData.record?.data['email'],
        'name': authData.record?.data['name'],
        'token': authData.token,
      };
    } catch (e) {
      print('Kesalahan login: $e');
      rethrow;
    }
  }


  Future<void> logout() async {
    _pb.authStore.clear();
    await _clearAuthData(); // Clear saved data
    print('Logout berhasil');
  }


Future<Map<String, dynamic>> getUserData({required String userId}) async {
  try {
    // Langsung gunakan userId yang diberikan sebagai parameter
    final userData = await _pb.collection('users').getOne(userId);
    final data = Map<String, dynamic>.from(userData.data);
    data['id'] = userId; // Pastikan ID selalu ada
    print('Data pengguna berhasil diambil: $data');
    return data;
  } catch (e) {
    print('Kesalahan mendapatkan data pengguna dengan ID $userId: $e');

    // Logika untuk menangani sesi tidak valid (error 404)
    if (e is ClientException && e.statusCode == 404) {
      print('Pengguna tidak ditemukan di server. Sesi tidak valid, melakukan logout...');
      await logout();
    }

    rethrow; // Lemparkan kembali error agar bisa ditangani oleh UI
  }
}


  Future<void> updateProfile(String id, Map<String, dynamic> data) async {
    try {
      await _pb.collection('users').update(id, body: data);
    } catch (e) {
      print('Kesalahan memperbarui profil: $e');
      rethrow;
    }
  }


  // METHOD BARU - Tambahkan ini
  String? getCurrentUserId() {
    return _pb.authStore.model?.id;
  }


  bool isLoggedIn() {
    return _pb.authStore.isValid;
  }


  Map<String, dynamic>? getCurrentUser() {
    return _pb.authStore.model?.toJson();
  }


  // Method untuk force refresh auth status
  Future<void> refreshAuth() async {
    await _initializeAuth();
  }


  PocketBase get pb => _pb;
}
