import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/models/community.dart';
import 'package:zic_flutter/core/providers/community_posts_provider.dart';
import 'package:zic_flutter/core/providers/community_provider.dart';
import 'package:zic_flutter/core/providers/post_provider.dart';
import 'package:zic_flutter/core/providers/user_provider.dart';
import 'package:zic_flutter/screens/comunities/reorder_communities.dart';
import 'package:zic_flutter/screens/notifications/activity_section.dart';
import 'package:zic_flutter/tabs/chats_screen.dart';
import 'package:zic_flutter/utils/keep_alive_widget.dart';
import 'package:zic_flutter/widgets/post_items/feed_posts_list.dart';
import 'package:zic_flutter/widgets/post_items/post_input.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  List<Community> _getAllCommunities(List<Community> joinedCommunities) {
    return [
      Community(id: 'latest', name: 'Latest', description: '', creatorId: ''),
      Community(id: 'friends', name: 'Friends', description: '', creatorId: ''),
      ...joinedCommunities,
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);
    final communitiesState = ref.watch(CommunityNotifier.provider);
    final allCommunities = _getAllCommunities(
      communitiesState.joinedCommunities,
    );

    return userAsync.when(
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
      data: (user) {
        return _HomeScreenTabs(
          userId: user!.id,
          allCommunities: allCommunities,
        );
      },
    );
  }
}

class _HomeScreenTabs extends ConsumerStatefulWidget {
  final String userId;
  final List<Community> allCommunities;

  const _HomeScreenTabs({required this.userId, required this.allCommunities});

  @override
  ConsumerState<_HomeScreenTabs> createState() => _HomeScreenTabsState();
}

class _HomeScreenTabsState extends ConsumerState<_HomeScreenTabs>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  static const String blackLogo = 'lib/assets/images/Troop-black.svg';
  static const String whiteLogo = 'lib/assets/images/Troop-white.svg';

  late TabController _tabController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.allCommunities.length,
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(covariant _HomeScreenTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.allCommunities.length != widget.allCommunities.length) {
      _tabController.dispose();
      _tabController = TabController(
        length: widget.allCommunities.length,
        vsync: this,
        initialIndex: _tabController.index.clamp(
          0,
          widget.allCommunities.length - 1,
        ),
      );
      setState(() {});
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final isScrollable = widget.allCommunities.length > 3;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: SvgPicture.asset(
          AppTheme.isDark(context) ? whiteLogo : blackLogo,
          semanticsLabel: 'App Logo',
          height: 24,
        ),
        scrolledUnderElevation: 0.0,
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
        bottom: TabBar(
          controller: _tabController,
          isScrollable: isScrollable,
          tabAlignment: isScrollable ? TabAlignment.center : TabAlignment.fill,
          tabs:
              widget.allCommunities
                  .map((community) => Tab(text: community.name))
                  .toList(),
          labelColor: AppTheme.foregroundColor(context),
          indicatorColor: AppTheme.foregroundColor(context),
          dividerColor: Colors.grey.withOpacity(0.1),
          unselectedLabelColor:
              AppTheme.isDark(context)
                  ? Colors.grey.shade800
                  : Colors.grey.shade400,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children:
            widget.allCommunities
                .map(
                  (community) => KeepAliveWidget(
                    child: _buildCommunityTab(community, widget.userId),
                  ),
                )
                .toList(),
      ),
    );
  }

  Widget _buildCommunityTab(Community community, String userId) {
    switch (community.id) {
      case 'latest':
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(friendsPostsNotifier);
            ref.invalidate(joinedCommunitiesProvider);
            ref.invalidate(joinedCommunitiesPostsProvider);
          },
          child: ListView(
            children: [
              const PostInput(),
              FeedPostsList(userId: userId, feedType: 'latest'),
            ],
          ),
        );
      case 'friends':
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(friendsPostsNotifier);
          },
          child: ListView(
            children: [
              const PostInput(label: "Say something to your friends..."),
              FeedPostsList(userId: userId, feedType: 'friends'),
            ],
          ),
        );
      default:
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(joinedCommunitiesProvider);
            ref.invalidate(joinedCommunitiesPostsProvider);
            ref.invalidate(communityPostsProvider(community.id));
          },
          child: ListView(
            children: [
              PostInput(
                label: "Post in ${community.name}...",
                initialAudience: community.id,
              ),
              FeedPostsList(userId: userId, feedType: community.id),
            ],
          ),
        );
    }
  }
}
