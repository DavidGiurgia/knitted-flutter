import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:provider/provider.dart';
import 'package:zic_flutter/core/api/friends.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/models/user.dart';
import 'package:zic_flutter/core/providers/user_provider.dart';
import 'package:zic_flutter/screens/post/create_post.dart';
import 'package:zic_flutter/screens/settings/settings_and_activity.dart';
import 'package:zic_flutter/screens/shared/edit_profile.dart';
import 'package:zic_flutter/screens/shared/friends_section.dart';
import 'package:zic_flutter/widgets/button.dart';
import 'package:zic_flutter/widgets/profile_header.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<User> friends = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.user != null) {
        loadFriends(userProvider.user!.id);
      }
    });
  }

  Future<void> loadFriends(String userId) async {
    try {
      final List<User> fetchedFriends = await FriendsService.fetchUserFriends(userId);

      setState(() {
        friends = fetchedFriends;
      });
    } catch (error) {
      print("Error loading friends: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: true);
    final user = userProvider.user;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Profile'),
        ),
        body: Center(
          child: Text('No user data available'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
                  pageBuilder: (context, animation, secondaryAnimation) =>
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
          await loadFriends(user.id);
        },
        child: ListView(
          children: [
            ProfileHeader(user: user),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.fullname,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.bio.isNotEmpty ? user.bio : user.email,
                    style: TextStyle(
                      fontSize: 18,
                      color: AppTheme.isDark(context)
                          ? Colors.grey.shade200
                          : Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  CustomButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfileScreen(),
                        ),
                      );
                    },
                    text: 'Edit Profile',
                    isFullWidth: true,
                    type: ButtonType.bordered,
                    size: ButtonSize.small,
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FriendsSection(user: user),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Friends",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              "${friends.length}",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.isDark(context)
                                    ? Colors.grey.shade300
                                    : Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "friends",
                              style: TextStyle(
                                fontSize: 16,
                                color: AppTheme.isDark(context)
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // aici
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}