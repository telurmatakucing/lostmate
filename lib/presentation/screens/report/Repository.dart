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
      print('Error fetching reports: $e'); // Logging untuk debugging
      throw Exception('Failed to load reports: $e');
    }
  }

  Future<LostItemReport> createReport(LostItemReport report, {File? image}) async {
    try {
      http.MultipartFile? file;
      if (image != null) {
        file = http.MultipartFile.fromBytes(
          'fotobarang',
          await image.readAsBytes(),
          filename: image.path.split('/').last,
        );
      }

      if (!pb.authStore.isValid) {
        throw Exception('Sesi autentikasi tidak valid');
      }

      final record = await pb.collection('report').create(
            body: {
              ...report.toJson(),
              'user_id': pb.authStore.model.id,
            },
            files: file != null ? [file] : [],
          );

      return LostItemReport.fromJson(record.toJson());
    } catch (e) {
      print('Error creating report: $e'); // Logging untuk debugging
      throw Exception('Failed to create report: $e');
    }
  }

  Future<void> updateReport(LostItemReport report, {File? image}) async {
    try {
      http.MultipartFile? file;
      if (image != null) {
        file = http.MultipartFile.fromBytes(
          'fotobarang',
          await image.readAsBytes(),
          filename: image.path.split('/').last,
        );
      }

      await pb.collection('report').update(
            report.id!,
            body: report.toJson(),
            files: file != null ? [file] : [],
          );
    } catch (e) {
      print('Error updating report: $e'); // Logging untuk debugging
      throw Exception('Failed to update report: $e');
    }
  }

  Future<void> deleteReport(String id) async {
    try {
      await pb.collection('report').delete(id);
    } catch (e) {
      print('Error deleting report: $e'); // Logging untuk debugging
      throw Exception('Failed to delete report: $e');
    }
  }
}