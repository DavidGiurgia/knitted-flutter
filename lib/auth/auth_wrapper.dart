import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zic_flutter/auth/login_screen.dart';
import 'package:zic_flutter/core/providers/user_provider.dart';
import 'package:zic_flutter/tabs/tabs_layout.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    if (userProvider.user == null) {
      return const LoginScreen();
    } else {
      return const TabsLayout();
    }
  }
}