import 'package:pocketbase/pocketbase.dart';

class AuthNotifier {
  final PocketBase pb = PocketBase('http://127.0.0.1:8090');

  Future<bool> login(String email, String password) async {
    try {
      await pb.collection('users').authWithPassword(email, password);
      return pb.authStore.isValid;
    } catch (e) {
      print('Auth error: $e');
      // Clear any invalid stored auth
      pb.authStore.clear();
      return false;
    }
  }

  Future<void> logout() async {
    pb.authStore.clear();
  }

  bool get isLoggedIn => pb.authStore.isValid;
}