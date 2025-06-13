import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:pocketbase/pocketbase.dart';

class LostItemReport {
  String? id;
  String namabarang;
  String deskripsi;
  String lokasi;
  DateTime lostDate;
  String? waktuHilang;
  String kontak;
  String? fotobarang;
  DateTime createdAt;

  LostItemReport({
    this.id,
    required this.namabarang,
    required this.deskripsi,
    required this.lokasi,
    required this.lostDate,
    this.waktuHilang,
    required this.kontak,
    this.fotobarang,
    required this.createdAt,
  });

  factory LostItemReport.fromJson(Map<String, dynamic> json) {
    return LostItemReport(
      id: json['id'],
      namabarang: json['namabarang'],
      deskripsi: json['deskripsi'],
      lokasi: json['lokasi'],
      lostDate: DateTime.parse(json['lostDate']),
      waktuHilang: json['waktuHilang'],
      kontak: json['kontak'],
      fotobarang: json['fotobarang'],
      createdAt: DateTime.parse(json['created']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'namabarang': namabarang,
      'deskripsi': deskripsi,
      'lokasi': lokasi,
      'lostDate': lostDate.toIso8601String(),
      'waktuHilang': waktuHilang,
      'kontak': kontak,
      'fotobarang': fotobarang,
    };
  }
}

class LostItemRepository {
  final PocketBase pb;

  LostItemRepository(this.pb);

  Future<List<LostItemReport>> getReports({bool onlyMine = false}) async {
    try {
      final records = await pb.collection('report').getFullList(
            filter: onlyMine ? 'user_id = "${pb.authStore.model.id}"' : null,
            sort: '-created',
          );
      return records.map((e) => LostItemReport.fromJson(e.toJson())).toList();
    } catch (e) {
      throw Exception('Failed to load reports: $e');
    }
  }

  Future<LostItemReport> createReport(LostItemReport report) async {
    try {
      final record = await pb.collection('report').create(
            body: report.toJson(),
          );
      return LostItemReport.fromJson(record.toJson());
    } catch (e) {
      throw Exception('Failed to create report: $e');
    }
  }

  Future<void> updateReport(LostItemReport report) async {
    try {
      await pb.collection('report').update(
            report.id!,
            body: report.toJson(),
          );
    } catch (e) {
      throw Exception('Failed to update report: $e');
    }
  }

  Future<void> deleteReport(String id) async {
    try {
      await pb.collection('report').delete(id);
    } catch (e) {
      throw Exception('Failed to delete report: $e');
    }
  }

  Future<String?> uploadImage(File image) async {
    try {
      final file = http.MultipartFile.fromBytes(
        'fotobarang',
        await image.readAsBytes(),
        filename: image.path.split('/').last,
      );

      // Pastikan autentikasi masih valid sebelum unggah
      if (!pb.authStore.isValid) {
        throw Exception('Sesi autentikasi tidak valid');
      }

      final record = await pb.collection('report').create(
            body: {}, // Data kosong untuk unggah file saja
            files: [file],
          );

      return pb.files.getUrl(record, record.data['fotobarang']).toString();
    } catch (e) {
      print('Error uploading image: $e');
      throw Exception('Failed to upload image: $e');
    }
  }
}