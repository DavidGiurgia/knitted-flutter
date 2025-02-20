import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:zic_flutter/core/app_theme.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          CustomButton(
            onPressed: () => print("HeroIcon pressed!"),
            isIconOnly: true,
            heroIcon: HeroIcons.plus,
            type: ButtonType.light,
            size: ButtonSize.large,
          ),
          CustomButton(
            onPressed: () => print("HeroIcon pressed!"),
            isIconOnly: true,
            heroIcon: HeroIcons.bars3,
            size: ButtonSize.large,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(Duration(seconds: 2));
          setState(() {});
        },
        child: ListView(
          children: [
            ProfileHeader(onEditCover: () {}, onEditAvatar: () {}, fullName: "Giurgia David",),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ' John Doe',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'I love Football, Volley and others',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  CustomButton(
                    onPressed: () => print("Edit Profile pressed!"),
                    text: 'Edit Profile',
                    isFullWidth: true,
                    type: ButtonType.bordered,
                    size: ButtonSize.small,
                    bgColor:
                        AppTheme.isDark(context)
                            ? AppTheme.grey400
                            : AppTheme.grey700,
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
