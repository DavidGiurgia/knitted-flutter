import 'package:flutter/material.dart';
import 'package:zic_flutter/auth/login_screen.dart';
import 'package:zic_flutter/core/services/auth_service.dart';
import 'package:zic_flutter/tabs/tabs_layout.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AuthService.isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data == true) {
          return const TabsLayout(); // Dacă e logat, merge la home
        } else {
          return const LoginScreen(); // Altfel, rămâne la Login
        }
      },
    );
  }
}