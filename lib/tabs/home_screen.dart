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
import 'package:zic_flutter/widgets/community_tab_bar.dart';
import 'package:zic_flutter/widgets/post_items/feed_posts_list.dart';
import 'package:zic_flutter/widgets/post_items/post_input.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  static const String blackLogo = 'lib/assets/images/Knitted-logo.svg';
  static const String whiteLogo = 'lib/assets/images/Knitted-white-logo.svg';

  TabController? _tabController; // Make it nullable
  final ScrollController _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  List<Community> _getAllCommunities(List<Community> joinedCommunities) {
    return [
       Community(id: 'newest', name: 'Newest', description: '', creatorId: ''),
       Community(id: 'friends', name: 'Friends', description: '', creatorId: ''),
      ...joinedCommunities,
    ];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final communitiesState = ref.watch(CommunityNotifier.provider);
    final allCommunities = _getAllCommunities(communitiesState.joinedCommunities);

    // Actualizează controllerul doar dacă este necesar
    if (_tabController == null || _tabController!.length != allCommunities.length) {
      _tabController?.dispose(); // Dispose the old one if it exists
      _tabController = TabController(
        length: allCommunities.length,
        vsync: this,
      );
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final user = ref.watch(userProvider).value;
    final communitiesState = ref.watch(CommunityNotifier.provider);
    final allCommunities = _getAllCommunities(communitiesState.joinedCommunities);

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_tabController == null) {
      return const Center(child: CircularProgressIndicator()); // Or some other loading state
    }

    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              automaticallyImplyLeading: false,
              title: SvgPicture.asset(
                AppTheme.isDark(context) ? whiteLogo : blackLogo,
                semanticsLabel: 'App Logo',
                height: 20,
              ),
              scrolledUnderElevation: 0.0,
              floating: true,
              pinned: true,
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReorderCommunities(),
                      ),
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
              bottom: CommunityTabBar(
                tabController: _tabController!,
                communities: allCommunities,
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController!,
          children: allCommunities.map((community) {
            return KeepAliveWidget(
              child: _buildCommunityTab(community, user.id),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCommunityTab(Community community, String userId) {
    switch (community.id) {
      case 'newest':
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(userPostsProvider); // Invalidează doar postările utilizatorului
          },
          child: ListView(
            children: [
              const PostInput(),
              FeedPostsList(userId: userId, filter: (post) => true),
            ],
          ),
        );
      case 'friends':
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(userPostsProvider); // Invalidează doar postările utilizatorului
          },
          child: FeedPostsList(
            userId: userId,
            filter: (post) => !post.isFromCommunity,
          ),
        );
      default:
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(communityPostsProvider(community.id));
          },
          child: FeedPostsList(
            userId: userId,
            filter: (post) => post.isFromCommunity && post.communityId == community.id,
          ),
        );
    }
  }
}