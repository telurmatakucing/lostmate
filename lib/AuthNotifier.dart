import 'package:pocketbase/pocketbase.dart';
import 'package:retry/retry.dart';
import 'dart:async'; // Added for TimeoutException

class AuthNotifier {
  final PocketBase pb = PocketBase('http://10.0.2.2:8090'); // Update to ngrok URL or host IP if needed

  Future<bool> login(String email, String password) async {
    try {
      final authData = await retry(
        () => pb.collection('users').authWithPassword(email, password).timeout(Duration(seconds: 30)),
        retryIf: (e) => e is ClientException || e is TimeoutException,
        maxAttempts: 3,
        delayFactor: Duration(milliseconds: 500),
      );
      print('Auth successful: ${authData.record?.data}');
      return pb.authStore.isValid;
    } catch (e) {
      print('Auth error: $e');
      pb.authStore.clear();
      return false;
    }
  }

  Future<void> logout() async {
    pb.authStore.clear();
  }

  bool get isLoggedIn => pb.authStore.isValid;
}