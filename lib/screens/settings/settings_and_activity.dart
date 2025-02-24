import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:provider/provider.dart';
import 'package:zic_flutter/auth/login_screen.dart';
import 'package:zic_flutter/core/providers/user_provider.dart';
import 'package:zic_flutter/widgets/button.dart';

class SettingsAndActivity extends StatefulWidget {
  const SettingsAndActivity({super.key});

  @override
  State<SettingsAndActivity> createState() => _SettingsAndActivityState();
}

class _SettingsAndActivityState extends State<SettingsAndActivity> {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings and Activity')),
      body: Center(
        child: Column(
          children: [
            CustomButton(
              onPressed: () async {
                await userProvider.logout();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              isIconOnly: true,
              heroIcon: HeroIcons.arrowLeftEndOnRectangle,
              size: ButtonSize.large,
            ),
          ],
        ),
      ),
    );
  }
}
