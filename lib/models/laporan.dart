class Laporan {
  final String id;
  final String namaBarang;
  final String lokasi;
  final String deskripsi;
  final DateTime tanggal;
  final String userId;
  final String namaPelapor;

  Laporan({
    required this.id,
    required this.namaBarang,
    required this.lokasi,
    required this.deskripsi,
    required this.tanggal,
    required this.userId,
    required this.namaPelapor,
  });

  // Factory ini sudah benar jika tipe data di Appwrite adalah tunggal
  factory Laporan.fromDocument(Map<String, dynamic> doc) {
    return Laporan(
      id: doc['\$id'],
      namaBarang: doc['nama_barang'] ?? '',
      lokasi: doc['lokasi'] ?? '',
      deskripsi: doc['deskripsi'] ?? '',
      // Ini akan bekerja setelah 'tanggal' diubah menjadi Datetime tunggal
      tanggal: DateTime.parse(doc['tanggal']),
      // Ini akan bekerja setelah 'user_id' diubah menjadi String tunggal
      userId: doc['user_id'] ?? '',
      namaPelapor: doc['nama_pelapor'] ?? '',
    );
  }

  Map<String, dynamic> toDocument() {
    return {
      'nama_barang': namaBarang,
      'lokasi': lokasi,
      'deskripsi': deskripsi,
      'tanggal': tanggal.toIso8601String(),
      'user_id': userId,
      'nama_pelapor': namaPelapor,
    };
  }
}