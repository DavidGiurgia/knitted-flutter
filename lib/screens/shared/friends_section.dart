import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/models/user.dart';
import 'package:zic_flutter/core/providers/friends_provider.dart';
import 'package:zic_flutter/core/providers/user_provider.dart';
import 'package:zic_flutter/screens/shared/find_friends_section.dart';
import 'package:zic_flutter/screens/shared/user_profile_screen.dart';
import 'package:zic_flutter/widgets/friendship_status_button.dart';
import 'package:zic_flutter/widgets/user_list_tile.dart';

class FriendsSection extends ConsumerStatefulWidget {
  final User? user;

  const FriendsSection({super.key, this.user});

  @override
  ConsumerState<FriendsSection> createState() => _FriendsSectionState();
}

class _FriendsSectionState extends ConsumerState<FriendsSection>
    with TickerProviderStateMixin {
  TabController? _tabController;
  bool showMutualTab = false;

  @override
  void initState() {
    super.initState();
    final currentUserAsync = ref.read(userProvider);
    showMutualTab = widget.user?.id != currentUserAsync.value?.id;
    _tabController = TabController(length: showMutualTab ? 3 : 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserAsync = ref.watch(userProvider);
    final userId = currentUserAsync.value?.id;

    if (userId == null || (widget.user == null && widget.user?.id == null)) {
      return const Center(child: Text("Please log in again!"));
    }

    final friendsAsync = ref.watch(friendsProvider(widget.user?.id));
    final mutualFriendsAsync = ref.watch(
      mutualFriendsProvider((userId, widget.user!.id)),
    );
    final suggestedUsersAsync = ref.watch(suggestedUsersProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user?.fullname ?? "Unknown"),
        bottom: TabBar(
          dividerColor:
              AppTheme.isDark(context) ? AppTheme.grey800 : AppTheme.grey200,
          controller: _tabController,
          tabs: [
            if (showMutualTab)
              Tab(text: "${mutualFriendsAsync.value?.length ?? 0} mutual"),
            Tab(text: "${friendsAsync.value?.length ?? 0} friends"),
            Tab(text: "${suggestedUsersAsync.value?.length ?? 0} Suggested"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          if (showMutualTab)
            FriendsList(
              friendsAsync: mutualFriendsAsync,
              currentUser: widget.user,
            ),
          FriendsList(friendsAsync: friendsAsync, currentUser: widget.user),
          FriendsList(
            friendsAsync: suggestedUsersAsync,
            currentUser: widget.user,
          ),
        ],
      ),
    );
  }
}

class FriendsList extends ConsumerWidget {
  final AsyncValue<List<User>> friendsAsync;
  final User? currentUser;

  const FriendsList({
    super.key,
    required this.friendsAsync,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserAsync = ref.watch(userProvider);
    final userId = currentUserAsync.value?.id;

    if (userId == null || currentUser == null) {
      return const Center(child: Text("Please log in again!"));
    }

    return friendsAsync.when(
      data: (friends) {
        if (currentUserAsync.value?.id == currentUser?.id && friends.isEmpty) {
          return _buildEmptyState(context);
        } else if (friends.isEmpty) {
          return const Center(child: Text("No users found."));
        }

        return ListView.builder(
          itemCount: friends.length,
          itemBuilder: (context, index) {
            return UserListTile(
              user: friends[index],
              actionWidget: FriendshipStatusButton(
                user: friends[index],
                isCompact: true,
              ),
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => UserProfileScreen(user: friends[index]),
                    ),
                  ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Error: $error')),
    );
  }
}

Widget _buildEmptyState(BuildContext context) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.person_search_rounded,
          size: 60,
          color:
              AppTheme.isDark(context)
                  ? Colors.grey.shade700
                  : Colors.grey.shade400,
        ),
        const SizedBox(height: 16),
        Text(
          "No friends found",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color:
                AppTheme.isDark(context)
                    ? Colors.grey.shade500
                    : Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 8),
        Text.rich(
          TextSpan(
            text: "You can ",
            style: TextStyle(
              fontSize: 16,
              color:
                  AppTheme.isDark(context)
                      ? Colors.grey.shade500
                      : Colors.grey.shade600,
            ),
            children: [
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FindFriendsSection(),
                      ),
                    );
                  },
                  child: Text(
                    "find friends",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ),
              const TextSpan(text: " to start chatting."),
            ],
          ),
        ),
      ],
    ),
  );
}
