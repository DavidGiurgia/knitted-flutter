import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/providers/notifications_provider.dart';
import 'package:zic_flutter/core/providers/post_provider.dart';
import 'package:zic_flutter/core/providers/user_provider.dart';
import 'package:zic_flutter/screens/notifications/activity_section.dart';
import 'package:zic_flutter/tabs/chats_screen.dart';
import 'package:zic_flutter/widgets/post_items/feed_posts_list.dart';
import 'package:zic_flutter/widgets/post_items/post_input.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static const String blackLogo = 'lib/assets/images/Knitted-logo.svg';
  static const String whiteLogo = 'lib/assets/images/Knitted-white-logo.svg';

  @override
  Widget build(BuildContext context) {
    final user = ref.read(userProvider).value;
    if (user == null) return SizedBox.shrink();

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
        scrolledUnderElevation: 0.0,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(0.5), // Înălțimea bordurii
          child: Container(
            color:
                AppTheme.isDark(context)
                    ? AppTheme.grey800
                    : AppTheme.grey200, // Culoarea bordurii
            height: 1.0,
          ),
        ),
        automaticallyImplyLeading: false,
        title: SvgPicture.asset(
          AppTheme.isDark(context) ? whiteLogo : blackLogo,
          semanticsLabel: 'App Logo',
          //width: 32,
          height: 20,
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ActivityScreen()),
              );
            },
            icon: Icon(unreadNotifications ? TablerIcons.heart_filled : TablerIcons.heart),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatsScreen()),
              );
            },
            icon: Icon(TablerIcons.send),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(userProvider);
          ref.invalidate(userPostsProvider);
        },
        child: ListView(
          children: [PostInput(), FeedPostsList(userId: user.id)],
        ),
      ),
    );
  }
}
