import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:zic_flutter/core/app_theme.dart';
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

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  static const String blackLogo = 'lib/assets/images/Knitted-logo.svg';
  static const String whiteLogo = 'lib/assets/images/Knitted-white-logo.svg';

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.read(userProvider).value;
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Newest'),
                  Tab(text: 'Friends'),
                  Tab(text: 'Comunity'),
                ],
                indicatorColor: AppTheme.foregroundColor(context),
                labelColor: AppTheme.foregroundColor(context),

                unselectedLabelColor: Colors.grey,
                dividerColor:
                    AppTheme.isDark(context)
                        ? AppTheme.grey800
                        : AppTheme.grey200,
              ),
              Container(
                color:
                    AppTheme.isDark(context)
                        ? AppTheme.grey800
                        : AppTheme.grey200,
                height: 0.5,
              ),
            ],
          ),
        ),
        automaticallyImplyLeading: false,
        title: SvgPicture.asset(
          AppTheme.isDark(context) ? whiteLogo : blackLogo,
          semanticsLabel: 'App Logo',
          height: 20,
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Show bottom sheet
            },
            icon: const Icon(TablerIcons.reorder),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ActivityScreen()),
              );
            },
            icon: const Icon(TablerIcons.bell),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatsScreen()),
              );
            },
            icon: const Icon(TablerIcons.message),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // First tab - Following
          RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(userProvider);
              ref.invalidate(userPostsProvider);
            },
            child: ListView(
              children: [const PostInput(), FeedPostsList(userId: user.id)],
            ),
          ),

          // Second tab - For You
          RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(userProvider);
              ref.invalidate(userPostsProvider);
            },
            child: ListView(
              children: [
                //const PostInput(),
                FeedPostsList(userId: user.id),
              ],
            ),
          ),
          RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(userProvider);
              ref.invalidate(userPostsProvider);
            },
            child: Center(
              child: Text(
                'Coming soon!',
                style: TextStyle(fontSize: 20, color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
