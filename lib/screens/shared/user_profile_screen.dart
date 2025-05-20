import 'package:flutter/material.dart';
import 'package:flutter_advanced_avatar/flutter_advanced_avatar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:zic_flutter/core/api/room_service.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/models/user.dart';
import 'package:zic_flutter/core/providers/friends_provider.dart';
import 'package:zic_flutter/core/providers/rooms_provider.dart';
import 'package:zic_flutter/core/providers/user_provider.dart';
import 'package:zic_flutter/screens/chats/chat_room.dart';
import 'package:zic_flutter/screens/shared/edit_profile.dart';
import 'package:zic_flutter/screens/friends/friends_section.dart';
import 'package:zic_flutter/screens/shared/profile_photo.dart';
import 'package:zic_flutter/screens/shared/profile_tabs.dart';
import 'package:zic_flutter/tabs/search_screen.dart';
import 'package:zic_flutter/widgets/button.dart';
import 'package:zic_flutter/widgets/friendship_status_button.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  final User user;
  const UserProfileScreen({super.key, required this.user});

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
    ); // Changed tab length
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProvider);
    final currentUser = userAsync.value;
    if (currentUser == null) return const SizedBox.shrink();
    final friendsAsync = ref.watch(friendsProvider(widget.user.id));
    final friends = friendsAsync.value ?? [];

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor(context),

      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        actions: [
          IconButton(
            icon: Icon(
              TablerIcons.search,
              color:
                  AppTheme.isDark(context)
                      ? AppTheme.grey100
                      : AppTheme.grey950,
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) => const SearchScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(
              TablerIcons.dots_vertical,
              color:
                  AppTheme.isDark(context)
                      ? AppTheme.grey100
                      : AppTheme.grey950,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(friendsProvider);
          ref.invalidate(userProvider);
        },
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 2,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start, // Align items to the start
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 12),
                                Text(
                                  widget.user.fullname,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  widget.user.username,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                if (widget.user.bio.isNotEmpty)
                                  Text(
                                    widget.user.bio,
                                    style: TextStyle(fontSize: 16),
                                  ),
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => FriendsSection(
                                              user: widget.user,
                                            ),
                                      ),
                                    );
                                  },
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        "${friends.length} friends",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          color:
                                              AppTheme.isDark(context)
                                                  ? Colors.grey.shade600
                                                  : Colors.grey.shade400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16), // Add some spacing
                          GestureDetector(
                            onTap: () {
                              if (widget.user.avatarUrl != "") {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => ProfilePhoto(
                                          imagePath: widget.user.avatarUrl,
                                        ),
                                  ),
                                );
                              }
                            },
                            child: AdvancedAvatar(
                              size: 64,
                              image: NetworkImage(widget.user.avatarUrl),
                              autoTextSize: true,
                              name: widget.user.fullname,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color:
                                    AppTheme.isDark(context)
                                        ? AppTheme.grey200
                                        : AppTheme.grey800,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    AppTheme.isDark(context)
                                        ? AppTheme.grey800
                                        : AppTheme.grey200,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),

                      Row(
                        children: [
                          if (currentUser.id == widget.user.id)
                            Expanded(
                              child: CustomButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              const EditProfileScreen(),
                                    ),
                                  );
                                },
                                text: 'Edit Profile',
                                isFullWidth: true,
                                type: ButtonType.bordered,
                                size: ButtonSize.small,
                              ),
                            ),
                          if (currentUser.id != widget.user.id)
                            Expanded(
                              child: FriendshipStatusButton(user: widget.user),
                            ),
                          if (widget.user.friendsIds.contains(currentUser.id) &&
                              currentUser.id != widget.user.id)
                            const SizedBox(width: 6),
                          if (widget.user.friendsIds.contains(currentUser.id) &&
                              currentUser.id != widget.user.id)
                            Expanded(
                              child: CustomButton(
                                onPressed: () async {
                                  final room =
                                      await RoomService.createPrivateRoom(
                                        currentUser.id,
                                        widget.user.id,
                                      );
                                  if (room != null && context.mounted) {
                                    ref
                                        .read(roomsProvider.notifier)
                                        .addRoom(room);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                                ChatRoomSection(room: room),
                                      ),
                                    );
                                  }
                                },
                                text: 'Message',
                                isFullWidth: true,
                                type: ButtonType.bordered,
                                size: ButtonSize.small,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                    ],
                  ),
                ),
              ),

              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  tabBar: TabBar(
                    dividerColor:
                        AppTheme.isDark(context)
                            ? AppTheme.grey800
                            : AppTheme.grey200,
                    controller: _tabController,
                    indicatorColor: AppTheme.foregroundColor(context),
                    labelColor: AppTheme.foregroundColor(context),
                    unselectedLabelColor: Colors.grey,
                    tabs: const [
                      Tab(text: 'Posts'),
                      Tab(text: 'Media'),
                      Tab(text: 'Replies'),
                    ],
                  ),
                ),
              ),
            ];
          },
          body:
              widget.user.friendsIds.contains(currentUser.id) ||
                      widget.user.id == currentUser.id
                  ? ProfileTabs(
                    userId: widget.user.id,
                    tabController: _tabController,
                  )
                  : Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'This profile is private. Add to your friends to see their posts.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  const _SliverAppBarDelegate({required this.tabBar});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
