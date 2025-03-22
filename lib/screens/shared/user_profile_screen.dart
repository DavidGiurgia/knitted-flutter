import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heroicons/heroicons.dart';
import 'package:zic_flutter/core/api/room_service.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/models/user.dart';
import 'package:zic_flutter/core/providers/friends_provider.dart';
import 'package:zic_flutter/core/providers/rooms_provider.dart';
import 'package:zic_flutter/core/providers/user_provider.dart';
import 'package:zic_flutter/screens/chats/chat_room.dart';
import 'package:zic_flutter/screens/shared/edit_profile.dart';
import 'package:zic_flutter/screens/friends/friends_section.dart';
import 'package:zic_flutter/tabs/search_screen.dart';
import 'package:zic_flutter/widgets/button.dart';
import 'package:zic_flutter/widgets/friendship_status_button.dart';
import 'package:zic_flutter/widgets/profile_header.dart';

class UserProfileScreen extends ConsumerWidget {
  final User user;
  const UserProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);
    final currentUser = userAsync.value;
    if (currentUser == null) return SizedBox.shrink();
    final friendsAsync = ref.watch(friendsProvider(user.id));
    final friends = friendsAsync.value ?? [];

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor(context),
      appBar: AppBar(
        title: Text(user.fullname),
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
          ref.invalidate(friendsProvider);
          ref.invalidate(userProvider);
        },
        child: ListView(
          children: [
            ProfileHeader(user: user),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.fullname,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.bio.isNotEmpty ? user.bio : user.email,
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      if (currentUser.id == user.id)
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
                      if (currentUser.id != user.id)
                        Expanded(child: FriendshipStatusButton(user: user)),
                      if (user.friendsIds.contains(currentUser.id))
                        const SizedBox(width: 6),
                      if (user.friendsIds.contains(currentUser.id) &&
                          currentUser.id != user.id)
                        Expanded(
                          child: CustomButton(
                            onPressed: () async {
                              final room = await RoomService.createPrivateRoom(
                                currentUser.id,
                                user.id,
                              );
                              if (room != null && context.mounted) {
                                ref.read(roomsProvider.notifier).addRoom(room);
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
                          builder: (context) => FriendsSection(user: user),
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
