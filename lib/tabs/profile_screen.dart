import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:provider/provider.dart';
import 'package:zic_flutter/core/providers/user_provider.dart';
import 'package:zic_flutter/screens/settings/settings_and_activity.dart';
import 'package:zic_flutter/widgets/button.dart';
import 'package:zic_flutter/widgets/profile_header.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          CustomButton(
            onPressed: () => print("add post pressed!"),
            isIconOnly: true,
            heroIcon: HeroIcons.plus,
            type: ButtonType.light,
            size: ButtonSize.large,
          ),
          CustomButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsAndActivity()),
              );
            },
            isIconOnly: true,
            heroIcon: HeroIcons.bars3,
            size: ButtonSize.large,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await userProvider.loadUser();
        },
        child: ListView(
          children: [
            ProfileHeader(user: userProvider.user),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userProvider.user?.fullname ?? "Unknown",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    userProvider.user!.bio.isNotEmpty
                        ? userProvider.user!.bio
                        : userProvider.user!.email,
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  CustomButton(
                    onPressed: () {},
                    text: 'Edit Profile',
                    isFullWidth: true,
                    type: ButtonType.bordered,
                    size: ButtonSize.small,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
