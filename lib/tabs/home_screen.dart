import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:heroicons/heroicons.dart';
import 'package:provider/provider.dart';
import 'package:zic_flutter/core/api/notifications.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/providers/user_provider.dart';
import 'package:zic_flutter/screens/notifications/notifications_section.dart';
import 'package:zic_flutter/screens/post/create_post.dart';
import 'package:zic_flutter/widgets/button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const String assetName = 'lib/assets/images/ZIC-logo.svg';
  bool unreadNotifications = true;

  /// verifica cu functia de mai sus

  @override
  void initState() {
    super.initState();
    _checkUnreadNotifications();
  }

  Future<void> _checkUnreadNotifications() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      List<dynamic> notifications =
          await NotificationService.fetchNotifications(
            userProvider.user!.id,
            unreadOnly: true,
          );
      setState(() {
        unreadNotifications = notifications.isNotEmpty;
      });
    } catch (error) {
      print("Error checking unread notifications: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: SvgPicture.asset(
          assetName,
          semanticsLabel: 'ZiC Logo',
          //width: 32,
          height: 26,
        ),
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
            onPressed: () async {
              await _checkUnreadNotifications();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationsSection()),
              );
            },
            isIconOnly: true,
            heroIcon:
                unreadNotifications ? HeroIcons.bellAlert : HeroIcons.bell,
            iconStyle:
                unreadNotifications
                    ? HeroIconStyle.mini
                    : HeroIconStyle.outline,
            bgColor:
                unreadNotifications
                    ? AppTheme.primaryColor
                    : AppTheme.foregroundColor(context),
            size: ButtonSize.large,
          ),
        ],
      ),
    );
  }
}
