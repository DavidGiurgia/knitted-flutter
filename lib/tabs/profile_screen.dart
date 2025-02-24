import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:provider/provider.dart';
import 'package:zic_flutter/core/providers/user_provider.dart';
import 'package:zic_flutter/screens/post/create_post.dart';
import 'package:zic_flutter/screens/settings/settings_and_activity.dart';
import 'package:zic_flutter/screens/shared/edit_profile.dart';
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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreatePost()),
              );
            },
            isIconOnly: true,
            heroIcon: HeroIcons.plus,
            type: ButtonType.light,
            size: ButtonSize.large,
          ),
          CustomButton(
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder:
                      (context, animation, secondaryAnimation) =>
                          SettingsAndActivity(),
                  transitionsBuilder: (
                    context,
                    animation,
                    secondaryAnimation,
                    child,
                  ) {
                    const begin = Offset(1.0, 0.0);
                    const end = Offset.zero;
                    const curve = Curves.easeInOut;

                    var tween = Tween(
                      begin: begin,
                      end: end,
                    ).chain(CurveTween(curve: curve));
                    var offsetAnimation = animation.drive(tween);

                    return SlideTransition(
                      position: offsetAnimation,
                      child: child,
                    );
                  },
                ),
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
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EditProfile()),
                      );
                    },
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
