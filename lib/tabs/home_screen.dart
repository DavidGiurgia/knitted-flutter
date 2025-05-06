import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/providers/community_posts_provider.dart';
import 'package:zic_flutter/core/providers/community_provider.dart';
import 'package:zic_flutter/core/providers/post_provider.dart';
import 'package:zic_flutter/core/providers/user_provider.dart';
import 'package:zic_flutter/screens/comunities/reorder_communities.dart';
import 'package:zic_flutter/screens/notifications/activity_section.dart';
import 'package:zic_flutter/tabs/chats_screen.dart';
import 'package:zic_flutter/widgets/community_posts_list.dart';
import 'package:zic_flutter/widgets/community_tab_bar.dart';
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
    _initTabController();
  }

  void _initTabController() {
    final communities = ref.read(communitiesProvider);
    _tabController = TabController(length: communities.length, vsync: this);
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final communities = ref.read(communitiesProvider);
    if (_tabController.length != communities.length) {
      _tabController.dispose();
      _initTabController();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.read(userProvider).value;
    final communities = ref.watch(communitiesProvider);
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        bottom: CommunityTabBar(tabController: _tabController),
        automaticallyImplyLeading: false,
        title: SvgPicture.asset(
          AppTheme.isDark(context) ? whiteLogo : blackLogo,
          semanticsLabel: 'App Logo',
          height: 20,
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ReorderCommunities()),
              );
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
        children:
            communities.map((community) {
              if (community.id == '1') {
                // Newest tab
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(userProvider);
                    ref.invalidate(userPostsProvider);
                  },
                  child: ListView(
                    children: [
                      const PostInput(),
                      FeedPostsList(userId: user.id),
                    ],
                  ),
                );
              } else if (community.id == '2') {
                // Friends tab
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(userProvider);
                    ref.invalidate(userPostsProvider);
                  },
                  child: ListView(children: [FeedPostsList(userId: user.id)]),
                );
              } else {
                // Community tabs
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(communityPostsProvider(community.id));
                  },
                  child: CommunityPostsList(communityId: community.id),
                );
              }
            }).toList(),

        
      ),
    );
  }
  
}
