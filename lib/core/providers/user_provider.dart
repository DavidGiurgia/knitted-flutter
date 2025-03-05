import 'package:flutter/material.dart';
import 'package:zic_flutter/core/api/auth.dart';
import 'package:zic_flutter/core/models/user.dart';

class UserProvider extends ChangeNotifier {
  User? _user; // Stochează datele utilizatorului

  User? get user => _user;

  void setUser(Map<String, dynamic> userData) {
    _user = User.fromJson(userData);
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }

  bool get isLoggedIn => _user != null;

  // 🔹 Încarcă userul curent (de la API)
   Future<void> loadUser() async {
    var userData = await ApiService.getCurrentUserFromApi();
    setUser(userData!);
    notifyListeners(); // Notifică UI-ul că s-a schimbat user-ul
  }

  // 🔹 Login și încărcare user
  Future<bool> login(String email, String password) async {
    bool success = await ApiService.loginUser(email, password);
    if (success) {
      await loadUser(); // Reîncarcă datele userului
    }
    return success;
  }

  Future<bool> register(
    String fullname,
    String username,
    String email,
    String password,
  ) async {
    bool success = await ApiService.registerUser(
      fullname,
      username,
      email,
      password,
    );
    if (success) {
      await loadUser(); // Reîncarcă datele userului
    }
    return success;
  }

  // 🔹 Logout
  Future<void> logout() async {
    await ApiService.logout();
    clearUser();
    notifyListeners();
  }
}
