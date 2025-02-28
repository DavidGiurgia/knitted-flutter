import 'package:flutter/material.dart';
import 'package:flutter_advanced_avatar/flutter_advanced_avatar.dart';
import 'package:provider/provider.dart';
import 'package:zic_flutter/core/api/friends.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/models/user.dart';
import 'package:zic_flutter/core/providers/user_provider.dart';
import 'package:zic_flutter/screens/shared/user_profile_screen.dart';
import 'package:zic_flutter/widgets/friendship_status_button.dart';
import 'package:zic_flutter/widgets/user_list_tile.dart';

class FriendsSection extends StatefulWidget {
  final User? user;

  const FriendsSection({super.key, this.user});

  @override
  _FriendsSectionState createState() => _FriendsSectionState();
}

class _FriendsSectionState extends State<FriendsSection>
    with TickerProviderStateMixin {
  TabController? _tabController;
  List<User> friends = [];
  List<User> mutualFriends = [];
  bool showMutualTab = false;

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    showMutualTab = widget.user?.id != userProvider.user?.id;
    _tabController = TabController(length: showMutualTab ? 2 : 1, vsync: this);
    loadFriends(userProvider.user?.id);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> loadFriends(userId) async {
    if (widget.user == null || userId == null) return;

    final fetchedFriends = await FriendsService.fetchUserFriends(
      widget.user!.id,
    );
    List<User> fetchedMutualFriends = [];
    if (showMutualTab) {
      fetchedMutualFriends = await FriendsService.fetchMutualFriends(
        userId,
        widget.user!.id,
      );
    }

    setState(() {
      friends = fetchedFriends;
      mutualFriends = fetchedMutualFriends;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user?.fullname ?? "Unknown"),
        bottom: TabBar(
          dividerColor:
              AppTheme.isDark(context) ? AppTheme.grey800 : AppTheme.grey200,
          controller: _tabController,
          tabs: [
            if (showMutualTab) Tab(text: "${mutualFriends.length} mutual"),
            Tab(text: "${friends.length} friends"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          if (showMutualTab) FriendsList(friends: mutualFriends),
          FriendsList(friends: friends),
        ],
      ),
    );
  }
}

class FriendsList extends StatelessWidget {
  final List<User> friends;

  const FriendsList({Key? key, required this.friends}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //final userProvider = Provider.of<UserProvider>(context, listen: false);

    return ListView.builder(
      itemCount: friends.length,
      itemBuilder: (context, index) {
        return UserListTile(
          user: friends[index],
          actionWidget: FriendshipStatusButton(user: friends[index], isCompact: true),
          onTap:
              () => {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => UserProfileScreen(user: friends[index]),
                  ),
                ),
              },
        );
      },
    );
  }
}
