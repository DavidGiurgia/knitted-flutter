import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:provider/provider.dart';
import 'package:zic_flutter/core/api/friends.dart';
import 'package:zic_flutter/core/api/room_service.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/models/user.dart';
import 'package:zic_flutter/core/providers/chat_rooms_provider.dart';
import 'package:zic_flutter/core/providers/user_provider.dart';
import 'package:zic_flutter/screens/chats/chat_room.dart';
import 'package:zic_flutter/screens/shared/edit_profile.dart';
import 'package:zic_flutter/screens/shared/friends_section.dart';
import 'package:zic_flutter/tabs/search_screen.dart';
import 'package:zic_flutter/widgets/button.dart';
import 'package:zic_flutter/widgets/friendship_status_button.dart';
import 'package:zic_flutter/widgets/profile_header.dart';

class UserProfileScreen extends StatefulWidget {
  final User user;
  const UserProfileScreen({super.key, required this.user});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  List<User> friends = [];

  @override
  void initState() {
    super.initState();
    loadFriends();
  }

  Future<void> loadFriends() async {
    final List<User> fetchedFriends = await FriendsService.getUserFriends(
      widget.user.id,
    );

    setState(() {
      friends = fetchedFriends;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor(context),
      appBar: AppBar(
        title: Text(widget.user.fullname),
        actions: [
          IconButton(
            icon: HeroIcon(
              HeroIcons.magnifyingGlass,
              size: 24,
              color:
                  AppTheme.isDark(context)
                      ? AppTheme.grey100
                      : AppTheme.grey950,
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return SearchScreen();
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await userProvider.loadUser();
        },
        child: ListView(
          children: [
            ProfileHeader(user: widget.user),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.user.fullname,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.user.bio.isNotEmpty
                        ? widget.user.bio
                        : widget.user.email,
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      if (widget.user.id == userProvider.user?.id)
                        Expanded(
                          child: CustomButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditProfileScreen(),
                                ),
                              );
                            },
                            text: 'Edit Profile',
                            isFullWidth: true,
                            type: ButtonType.bordered,
                            size: ButtonSize.small,
                          ),
                        ),
                      if (widget.user.id != userProvider.user?.id)
                        Expanded(
                          child: FriendshipStatusButton(user: widget.user),
                        ),
                      if (userProvider.user!.friendsIds.contains(
                        widget.user.id,
                      ))
                        const SizedBox(width: 6),
                      if (userProvider.user!.friendsIds.contains(
                        widget.user.id,
                      ))
                        Expanded(
                          child: CustomButton(
                            onPressed: () async {
                              final room =
                                  await RoomService.createRoomWithFriend(
                                    userProvider.user!.id,
                                    widget.user.id,
                                  );
                              if (room != null && context.mounted) {
                                Provider.of<ChatRoomsProvider>(
                                  context,
                                  listen: false,
                                ).addRoom(room);
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
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => FriendsSection(user: widget.user),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Friends",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              "${friends.length}",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color:
                                    AppTheme.isDark(context)
                                        ? Colors.grey.shade300
                                        : Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "friends",
                              style: TextStyle(
                                fontSize: 16,
                                color:
                                    AppTheme.isDark(context)
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Additional content
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
