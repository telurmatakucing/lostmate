import 'package:flutter/material.dart';
import 'package:lostmate/Service/auth_service.dart';
import 'package:lostmate/presentation/screens/profile/edit_profile_screen.dart';
import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  final String? id;

  const ProfileScreen({Key? key, this.id}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = false;
  Map<String, dynamic> _userData = {};
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _initializeProfile();
  }

  Future<void> _initializeProfile() async {
    setState(() => _isLoading = true);
    try {
      await AuthService().refreshAuth();
      await _loadUserData();
    } catch (e) {
      print('Error initializing profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal menginisialisasi profil: $e"),
            backgroundColor: Colors.red[400],
          ),
        );
      }
    }
  }

  Future<void> _loadUserData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = AuthService();

      final currentUserId = authService.getCurrentUserId();
      _currentUserId = widget.id ?? currentUserId;

      print('Current User ID: $_currentUserId'); // Debug log

      if (_currentUserId == null || _currentUserId!.isEmpty) {
        throw Exception('Tidak ada ID user yang valid atau user belum login');
      }

      final userData = await authService.getUserData();

      if (mounted) {
        setState(() {
          // Check if userData is not null and is the correct type
          if (userData != null && userData is Map<String, dynamic>) {
            _userData = Map<String, dynamic>.from(userData);
          } else {
            _userData = <String, dynamic>{};
          }
          _isLoading = false;
        });
        print('UI updated with data: $_userData'); // Debug log
      }
    } catch (e) {
      print('Error loading user data: $e'); // Debug log
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Gagal memuat data profil: $e"),
              backgroundColor: Colors.red[400],
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil Saya"),
        backgroundColor: Colors.yellow[600],
        centerTitle: true,
        foregroundColor: Colors.black87,
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.yellow),
                  SizedBox(height: 16),
                  Text('Memuat data profil...'),
                ],
              ),
            )
          : _userData.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_off, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Data profil tidak tersedia',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadUserData,
                  color: Colors.yellow[600],
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        _buildProfileHeader(),
                        const SizedBox(height: 16),
                        _buildProfileCard(),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildProfileHeader() {
    final userName = _userData['name']?.toString() ?? 'Nama Pengguna';
    final userEmail = _userData['email']?.toString() ?? 'email@domain.com';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.yellow[600],
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.yellow[100],
            child: Text(
              userName.isNotEmpty ? userName.substring(0, 1).toUpperCase() : 'U',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.yellow[900],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            userName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            userEmail,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Informasi Profil',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                icon: Icons.phone,
                label: 'Nomor Telepon',
                value: _userData['phone']?.toString() ?? 'Tidak tersedia',
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                icon: Icons.school,
                label: 'Fakultas',
                value: _userData['fakultas']?.toString() ?? 'Tidak tersedia',
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                icon: Icons.book,
                label: 'Jurusan',
                value: _userData['jurusan']?.toString() ?? 'Tidak tersedia',
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _currentUserId != null
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProfileScreen(id: _currentUserId!),
                            ),
                          ).then((_) {
                            _loadUserData(); // Don't return this
                          });
                        }
                      : null,
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Profil'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow[600],
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.yellow[700], size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}