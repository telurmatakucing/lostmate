import 'package:flutter/material.dart';
import '../models/laporan.dart';
import '../services/appwrite_service.dart';

class LaporanProvider with ChangeNotifier {
  final AppwriteService _appwriteService = AppwriteService();
  List<Laporan> _allLaporan = [];
  List<Laporan> _userLaporan = [];
  bool _isLoading = false;

  List<Laporan> get allLaporan => _allLaporan;
  List<Laporan> get userLaporan => _userLaporan;
  bool get isLoading => _isLoading;

  Future<void> fetchAllLaporan() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allLaporan = await _appwriteService.getAllLaporan();
    } catch (e) {
      print('Error fetching laporan: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUserLaporan(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _userLaporan = await _appwriteService.getLaporanByUser(userId);
    } catch (e) {
      print('Error fetching user laporan: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createLaporan(Laporan laporan) async {
    try {
      await _appwriteService.createLaporan(laporan);
      await fetchAllLaporan(); // Refresh data
      return true;
    } catch (e) {
      print('Error creating laporan: $e');
      return false;
    }
  }
}