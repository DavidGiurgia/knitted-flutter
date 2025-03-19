import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:heroicons/heroicons.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/providers/notifications_provider.dart';
import 'package:zic_flutter/screens/notifications/notifications_section.dart';
import 'package:zic_flutter/screens/post/create_post/create_post.dart';
import 'package:zic_flutter/widgets/button.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static const String assetName = 'lib/assets/images/ZIC-logo.svg';

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(notificationsProvider);

    bool unreadNotifications = notificationsAsync.when(
      data:
          (notifications) =>
              notifications.any((notification) => !notification.read),
      loading: () => false,
      error: (error, stackTrace) => false,
    );

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
