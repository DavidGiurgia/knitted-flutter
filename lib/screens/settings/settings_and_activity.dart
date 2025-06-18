import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heroicons/heroicons.dart';
import 'package:zic_flutter/auth/login_screen.dart'; // Ensure this path is correct
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/providers/theme_provider.dart'; // Ensure this path is correct
import 'package:zic_flutter/core/providers/user_provider.dart'; // Ensure this path is correct
import 'package:zic_flutter/screens/shared/edit_profile.dart';
import 'package:zic_flutter/widgets/button.dart'; // Assuming CustomButton is still desired for logout

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
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: false, // Align title to the left for a modern look
        elevation: 0, // Remove shadow
        backgroundColor: Colors.transparent, // Make app bar transparent
        foregroundColor:
            Theme.of(context).colorScheme.onSurface, // Set color of title/icons
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Account Section ---
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Account',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              Card(
                elevation: 1, // Subtle shadow for card
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: HeroIcon(
                        HeroIcons.userCircle,
                        color: AppTheme.foregroundColor(context),
                      ),
                      title: const Text('Edit Profile'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // navigate to profile editing screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfileScreen(),
                          ),
                        );
                      },
                    ),
                    Divider(
                      height: 0,
                      indent: 16,
                      endIndent: 16,
                      color: Theme.of(context).dividerColor.withOpacity(0.5),
                    ),
                    ListTile(
                      leading: HeroIcon(
                        HeroIcons.key,
                        color: AppTheme.foregroundColor(context),
                      ),
                      title: const Text('Change Password'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // Handle navigation to change password screen
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24), // Spacer
              // --- App Settings Section ---
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'App Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: HeroIcon(
                        isDark ? HeroIcons.sun : HeroIcons.moon,
                        color: AppTheme.foregroundColor(context),
                      ),
                      title: const Text('Dark Mode'),
                      trailing: Switch(
                        value: isDark,
                        onChanged:
                            (value) =>
                                ref.read(themeProvider.notifier).toggleTheme(),
                        activeColor: AppTheme.foregroundColor(context),
                      ),
                    ),
                    Divider(
                      height: 0,
                      indent: 16,
                      endIndent: 16,
                      color: Theme.of(context).dividerColor.withOpacity(0.5),
                    ),
                    ListTile(
                      leading: HeroIcon(
                        HeroIcons.bell,
                        color: AppTheme.foregroundColor(context),
                      ),
                      title: const Text('Notifications'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // Handle navigation to notification settings
                      },
                    ),
                    Divider(
                      height: 0,
                      indent: 16,
                      endIndent: 16,
                      color: Theme.of(context).dividerColor.withOpacity(0.5),
                    ),
                    ListTile(
                      leading: HeroIcon(
                        HeroIcons.language,
                        color: AppTheme.foregroundColor(context),
                      ),
                      title: const Text('Language'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // Handle navigation to language settings
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24), // Spacer
              // --- Support & Legal Section ---
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Support & Legal',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: HeroIcon(
                        HeroIcons.questionMarkCircle,
                        color: AppTheme.foregroundColor(context),
                      ),
                      title: const Text('Help & FAQ'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // Handle navigation to help/FAQ
                      },
                    ),
                    Divider(
                      height: 0,
                      indent: 16,
                      endIndent: 16,
                      color: Theme.of(context).dividerColor.withOpacity(0.5),
                    ),
                    ListTile(
                      leading: HeroIcon(
                        HeroIcons.documentText,
                        color: AppTheme.foregroundColor(context),
                      ),
                      title: const Text('Privacy Policy'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // Handle navigation to privacy policy
                      },
                    ),
                    Divider(
                      height: 0,
                      indent: 16,
                      endIndent: 16,
                      color: Theme.of(context).dividerColor.withOpacity(0.5),
                    ),
                    ListTile(
                      leading: HeroIcon(
                        HeroIcons.clipboardDocumentList,
                        color: AppTheme.foregroundColor(context),
                      ),
                      title: const Text('Terms of Service'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // Handle navigation to terms of service
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32), // More space before logout
              // --- Logout Button ---
              Center(
                child: CustomButton(
                  bgColor: AppTheme.foregroundColor(context),
                  onPressed: () async {
                    await ref.read(userProvider.notifier).logout();
                    // Using pushReplacement to prevent going back to settings after logout
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  // Removed isIconOnly to show full button, adjust as needed
                  // heroIcon: HeroIcons.arrowLeftEndOnRectangle,
                  // size: ButtonSize.large,
                  text: 'Log Out',
                  heroIcon:
                      HeroIcons
                          .arrowRightOnRectangle, // A more common logout icon
                ),
              ),
              const SizedBox(height: 20), // Footer space
            ],
          ),
        ),
      ),
    );
  }
}
