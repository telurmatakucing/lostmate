import 'package:flutter/material.dart';
import 'package:lostmate/presentation/screens/chat/chat_screen.dart';
import 'package:lostmate/presentation/screens/profile/profile_screen.dart';
import 'package:lostmate/presentation/screens/report/report_screen.dart'; // Perbarui impor ini
import 'package:lostmate/data/models/lost_item_model.dart';

class DashboardScreen extends StatefulWidget {
  final String id; // Tambahkan parameter userId

  const DashboardScreen({Key? key, required this.id}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  // Daftar layar yang akan ditampilkan berdasarkan navigasi
  late final List<Widget> _screens; // Gunakan late untuk inisialisasi di initState

  @override
  void initState() {
    super.initState();
    // Inisialisasi _screens dengan userId
    _screens = [
      const LostItemsFeed(),
      const ReportScreen(), // Ganti ReportLostItemScreen dengan ReportScreen
      const ChatScreen(),
      ProfileScreen(id: widget.id) // Berikan userId ke ProfileScreen
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 10,
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add),
              label: 'Lapor',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xFFF9A826),
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}

// Kode lainnya (LostItemsFeed, LostItemDetailCard) tetap sama
class LostItemsFeed extends StatelessWidget {
  const LostItemsFeed({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Data contoh untuk barang hilang
    final List<LostItem> lostItems = [
      LostItem(
        id: '1',
        title: 'Handphone Samsung',
        description: 'Handphone Samsung warna hitam dengan case biru ditemukan di gazebo',
        imageUrl: 'https://example.com/image1.jpg',
        location: 'Gazebo Kampus',
        date: DateTime.now().subtract(const Duration(days: 1)),
        reporterName: 'Bella',
        reporterPhotoUrl: null,
      ),
      LostItem(
        id: '2',
        title: 'Dompet Coklat',
        description: 'Dompet kulit warna coklat berisi KTP dan kartu ATM',
        imageUrl: null,
        location: 'Kamar Mandi Gedung EF',
        date: DateTime.now().subtract(const Duration(days: 2)),
        reporterName: 'Kenzie',
        reporterPhotoUrl: null,
      ),
      LostItem(
        id: '3',
        title: 'STNK Motor',
        description: 'STNK motor dengan plat nomor L4900LU',
        imageUrl: null,
        location: 'Parkiran Gedung C',
        date: DateTime.now().subtract(const Duration(days: 3)),
        reporterName: 'Telurmatakucing',
        reporterPhotoUrl: null,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'LostMate',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {
              // Implementasi pencarian
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: lostItems.length,
        itemBuilder: (context, index) {
          final item = lostItems[index];
          return LostItemDetailCard(item: item);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigasi ke halaman laporan (ReportScreen)
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ReportScreen()),
          );
        },
        backgroundColor: const Color(0xFFF9A826),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class LostItemDetailCard extends StatelessWidget {
  final LostItem item;

  const LostItemDetailCard({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Format tanggal dan waktu
    final formattedDate = '${item.date.day.toString().padLeft(2, '0')}/${item.date.month.toString().padLeft(2, '0')}/${item.date.year}';
    final formattedTime = '${item.date.hour.toString().padLeft(2, '0')}:${item.date.minute.toString().padLeft(2, '0')}';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: const Color(0xFFFFF8E1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header dengan informasi pengguna dan judul
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: item.reporterPhotoUrl != null
                          ? NetworkImage(item.reporterPhotoUrl!)
                          : null,
                      child: item.reporterPhotoUrl == null
                          ? Text(
                              item.reporterName[0].toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Dilaporkan oleh ${item.reporterName}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9A826),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Hilang',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Deskripsi barang
                Text(
                  item.description,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 12),
                
                // Gambar barang (jika ada)
                if (item.imageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.imageUrl!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: 200,
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(Icons.image_not_supported, size: 50),
                          ),
                        );
                      },
                    ),
                  ),
                
                const SizedBox(height: 12),
                
                // Informasi detail (lokasi, tanggal, waktu, kontak)
                _buildInfoRow(Icons.location_on, item.location),
                const SizedBox(height: 4),
                _buildInfoRow(Icons.calendar_today, formattedDate),
                const SizedBox(height: 4),
                _buildInfoRow(Icons.access_time, formattedTime),
                const SizedBox(height: 4),
              ],
            ),
          ),
          
          // Footer dengan tombol kontak
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: OutlinedButton(
              onPressed: () {
                // Implementasi kontak pelapor
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFF9A826)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'Hubungi Pelapor',
                style: TextStyle(
                  color: Color(0xFFF9A826),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[800],
            ),
          ),
        ),
      ],
    );
  }
}