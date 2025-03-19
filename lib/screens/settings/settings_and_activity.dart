import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heroicons/heroicons.dart';

import 'package:zic_flutter/auth/login_screen.dart';
import 'package:zic_flutter/core/providers/user_provider.dart';
import 'package:zic_flutter/widgets/button.dart';

class SettingsAndActivity extends ConsumerStatefulWidget {
  const SettingsAndActivity({super.key});

  @override
  ConsumerState<SettingsAndActivity> createState() =>
      _SettingsAndActivityState();
}

class _SettingsAndActivityState extends ConsumerState<SettingsAndActivity> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings and Activity')),
      body: Center(
        child: Column(
          children: [
            CustomButton(
              onPressed: () async {
                await ref.read(userProvider.notifier).logout();
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
