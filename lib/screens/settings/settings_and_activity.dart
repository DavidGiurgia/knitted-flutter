import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heroicons/heroicons.dart';
import 'package:zic_flutter/auth/login_screen.dart';
import 'package:zic_flutter/core/providers/theme_provider.dart';
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
    final themeMode = ref.watch(themeProvider);
    final isDark =
        themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);
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
            IconButton(
              icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
              onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
            ),
          ],
        ),
      ),
    );
  }
}
