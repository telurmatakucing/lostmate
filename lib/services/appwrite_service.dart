import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import '../models/laporan.dart';

class AppwriteService {
  static const String endpoint = 'https://fra.cloud.appwrite.io/v1'; // Ganti dengan endpoint Anda
  static const String projectId = '68512e52003daf6fc1bb'; // Ganti dengan Project ID Anda
  static const String databaseId = '68512ea900341bb86357'; // Ganti dengan Database ID Anda
  static const String collectionId = '68513620000def40b086'; // Ganti dengan Collection ID Anda

  late Client client;
  late Account account;
  late Databases databases;

  AppwriteService() {
    client = Client();
    client.setEndpoint(endpoint).setProject(projectId);
    account = Account(client);
    databases = Databases(client);
  }

  // Authentication Methods
  Future<User?> getCurrentUser() async {
    try {
      return await account.get();
    } catch (e) {
      return null;
    }
  }

  Future<Session> login(String email, String password) async {
    return await account.createEmailSession(email: email, password: password);
  }

  Future<User> register(String email, String password, String name) async {
    return await account.create(
      userId: ID.unique(),
      email: email,
      password: password,
      name: name,
    );
  }

  Future<void> logout() async {
    await account.deleteSession(sessionId: 'current');
  }

  // Database Methods
  Future<List<Laporan>> getAllLaporan() async {
    try {
      final response = await databases.listDocuments(
        databaseId: databaseId,
        collectionId: collectionId,
        queries: [
          Query.orderDesc('tanggal'),
        ],
      );
      return response.documents.map((doc) => Laporan.fromDocument(doc.data)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil data laporan: $e');
    }
  }

  Future<List<Laporan>> getLaporanByUser(String userId) async {
    try {
      final response = await databases.listDocuments(
        databaseId: databaseId,
        collectionId: collectionId,
        queries: [
          Query.equal('user_id', userId),
          Query.orderDesc('tanggal'),
        ],
      );
      return response.documents.map((doc) => Laporan.fromDocument(doc.data)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil laporan user: $e');
    }
  }

  Future<Document> createLaporan(Laporan laporan) async {
    try {
      return await databases.createDocument(
        databaseId: databaseId,
        collectionId: collectionId,
        documentId: ID.unique(),
        data: laporan.toDocument(),
      );
    } catch (e) {
      throw Exception('Gagal membuat laporan: $e');
    }
  }
}