import 'package:zic_flutter/core/api/auth.dart';

class AuthService {
  // 🔹 Verifică dacă utilizatorul este logat
  static Future<bool> isLoggedIn() async {
    print("�� Calling ApiService.getCurrentUser() response");
    var user = await ApiService.getCurrentUserFromApi();
    print("��� User received: $user");
    return user != null; // Verificăm dacă user există
  }

  static Future<bool> register(
    String fullname,
    String username,
    String email,
    String password,
  ) async {
    print("📝 Calling ApiService.registerUser()");

    return await ApiService.registerUser(fullname, username, email, password);
  }

  static Future<bool> login(String email, String password) async {
    print(
      "🔑 Calling ApiService.loginUser() with email and password $email, $password",
    );
    return await ApiService.loginUser(email, password);
  }

  // 🔹 Funcție pentru logout
  static Future<void> logout() async {
    await ApiService.logout();
  }
}
