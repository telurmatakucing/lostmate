import 'package:flutter/material.dart';
import 'package:lostmate/service/auth_service.dart';
import 'package:lostmate/presentation/screens/auth/login_screen.dart';
import 'package:lostmate/presentation/screens/profile/edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  // ID sekarang 'required' untuk memastikan ProfileScreen selalu tahu profil siapa yang harus dimuat.
  final String id;

  const ProfileScreen({Key? key, required this.id}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Gunakan FutureBuilder untuk menangani state (loading, error, data) secara otomatis.
  late Future<Map<String, dynamic>> _userDataFuture;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _userDataFuture = _loadProfileData();
  }

  /// Memuat data profil dari AuthService.
  Future<Map<String, dynamic>> _loadProfileData() async {
    try {
      // Memanggil method yang sudah kita perbaiki, yang memerlukan userId.
      return await _authService.getUserData(userId: widget.id);
    } catch (e) {
      // Jika terjadi error (termasuk 404 Not Found dari AuthService),
      // lemparkan kembali error agar FutureBuilder bisa menanganinya.
      print('Error loading profile data in screen: $e');
      rethrow;
    }
  }

  /// Fungsi untuk refresh data, baik untuk pull-to-refresh maupun setelah edit.
  void _refreshData() {
    setState(() {
      _userDataFuture = _loadProfileData();
    });
  }

  /// Fungsi untuk logout
  Future<void> _logout() async {
    await _authService.logout();
    if (mounted) {
      // Arahkan ke LoginScreen dan hapus semua halaman sebelumnya.
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
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
        actions: [
          // Tombol Logout
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _userDataFuture,
        builder: (context, snapshot) {
          // 1. Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.yellow),
                  SizedBox(height: 16),
                  Text('Memuat data profil...'),
                ],
              ),
            );
          }

          // 2. Error State
          if (snapshot.hasError) {
            // Ini akan menangani error yang dilempar dari _loadProfileData,
            // termasuk kasus sesi tidak valid (404).
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 60),
                    const SizedBox(height: 16),
                    const Text(
                      'Gagal memuat data profil.',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sesi Anda mungkin tidak valid atau terjadi masalah jaringan.',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _refreshData,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba Lagi'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow[700],
                        foregroundColor: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          
          // 3. Success State
          if (snapshot.hasData) {
            final userData = snapshot.data!;
            return RefreshIndicator(
              onRefresh: () async => _refreshData(),
              color: Colors.yellow[600],
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    _buildProfileHeader(userData),
                    const SizedBox(height: 16),
                    _buildProfileCard(userData),
                  ],
                ),
              ),
            );
          }

          // Fallback state (seharusnya tidak pernah tercapai)
          return const Center(child: Text('Terjadi kesalahan tidak diketahui.'));
        },
      ),
    );
  }

  Widget _buildProfileHeader(Map<String, dynamic> userData) {
    final userName = userData['name']?.toString() ?? 'Nama Pengguna';
    final userEmail = userData['email']?.toString() ?? 'email@domain.com';

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
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.yellow[900]),
            ),
          ),
          const SizedBox(height: 12),
          Text(userName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.black87)),
          const SizedBox(height: 4),
          Text(userEmail, style: const TextStyle(fontSize: 16, color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildProfileCard(Map<String, dynamic> userData) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Informasi Profil', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87)),
              const SizedBox(height: 16),
              _buildInfoRow(icon: Icons.phone, label: 'Nomor Telepon', value: userData['phone']?.toString() ?? 'Tidak tersedia'),
              const SizedBox(height: 16),
              _buildInfoRow(icon: Icons.school, label: 'Fakultas', value: userData['fakultas']?.toString() ?? 'Tidak tersedia'),
              const SizedBox(height: 16),
              _buildInfoRow(icon: Icons.book, label: 'Jurusan', value: userData['jurusan']?.toString() ?? 'Tidak tersedia'),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Navigasi ke EditProfileScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EditProfileScreen(id: widget.id)),
                    ).then((_) {
                      // Setelah kembali dari halaman edit, muat ulang data.
                      _refreshData();
                    });
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Profil'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow[600],
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({required IconData icon, required String label, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.yellow[700], size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w400)),
            ],
          ),
        ),
      ],
    );
  }
}