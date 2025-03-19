import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zic_flutter/core/api/auth.dart';
import 'package:zic_flutter/core/models/user.dart';

class UserNotifier extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    try {
      final currentUser = await ApiService.getCurrentUserFromApi();
      if (currentUser == null) {
        return null;
      }
      return User.fromJson(currentUser);
    } catch (e) {
      return null;
    }
  }

  Future<bool> login(String email, String password) async {
    final success = await ApiService.loginUser(email, password);
    if (success) {
      state = AsyncValue.data(await build());
    }
    return success;
  }

  Future<bool> register(
    String fullname,
    String username,
    String email,
    String password,
  ) async {
    try {
      final success = await ApiService.registerUser(
        fullname,
        username,
        email,
        password,
      );
      if (success) {
        state = AsyncValue.data(await build());
      }
      return success;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await ApiService.logout();
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

final userProvider = AsyncNotifierProvider<UserNotifier, User?>(
  () => UserNotifier(),
);
