import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zic_flutter/core/api/notifications.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/models/chat_room.dart';
import 'package:zic_flutter/core/models/user.dart';
import 'package:zic_flutter/core/providers/friends_provider.dart';
import 'package:zic_flutter/core/providers/user_provider.dart';
import 'package:zic_flutter/screens/chats/temporary_chat_room.dart';
import 'package:zic_flutter/widgets/button.dart';
import 'package:zic_flutter/widgets/search_input.dart';
import 'package:zic_flutter/widgets/user_list_tile.dart';

class InviteFriendsSection extends ConsumerStatefulWidget {
  final Room room;
  const InviteFriendsSection({super.key, required this.room});

  @override
  ConsumerState<InviteFriendsSection> createState() =>
      _InviteFriendsSectionState();
}

class _InviteFriendsSectionState extends ConsumerState<InviteFriendsSection> {
  bool isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  List<User> _filteredFriends = [];
  final List<User> _selectedFriends = [];

  void handleSendNotifications() async {
    setState(() => isLoading = true);
    try {
      final user = ref.read(userProvider).value;
      if (user == null) {
        throw Exception("User not logged in");
      }
      for (var friend in _selectedFriends) {
        await NotificationService.createNotification(
          user.id,
          friend.id,
          "chat_invitation",
          {"chatRoomTopic": widget.room.topic, "chatRoomId": widget.room.id},
        );
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TemporaryChatRoomSection(room: widget.room),
        ),
      );
    } catch (error) {
      print("Error sending notifications: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error sending notifications: $error")),
      );
    }
    setState(() => isLoading = false);
  }

  void _onSearchChanged(String query) {
    final friendsAsync = ref.read(friendsProvider(null));
    friendsAsync.when(
    data: (friends) {
      setState(() {
        _filteredFriends = friends
            .where((friend) =>
                friend.fullname.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    },
    loading: () {
      print("Loading friends...");
    },
    error: (error, stackTrace) {
      print("Error loading friends: $error");
    },
  );
  }

  void _toggleFriendSelection(User friend) {
    setState(() {
      if (_selectedFriends.contains(friend)) {
        _selectedFriends.remove(friend);
      } else {
        _selectedFriends.add(friend);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final friendsAsync = ref.watch(friendsProvider(null));

    return Scaffold(
      appBar: AppBar(
        title: Text("Invite your friends"),
        leading: IconButton(
          icon: Icon(Icons.close, color: AppTheme.foregroundColor(context)),
          onPressed:
              () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => TemporaryChatRoomSection(room: widget.room),
                ),
              ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: CustomButton(
              onPressed: handleSendNotifications,
              text: "Done",
              isLoading: isLoading,
              bgColor: AppTheme.primaryColor,
              size: ButtonSize.small,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Indiciu pentru invitație
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Colors.blue, size: 23),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      "Invite your friends—they’ll get a notification. Keep in mind, you won’t be able to see who joins the chat.",
                      style: TextStyle(
                        fontSize: 14,
                        color:
                            AppTheme.isDark(context)
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Selectorul de prieteni
            SizedBox(
              height:
                  MediaQuery.of(context).size.height * 0.8, // Adjust as needed
              child: Column(
                children: [
                  /// Search Input
                  SearchInput(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                  ),

                  /// Suggested Friends List
                  if (_searchController.text.isEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Suggested Friends",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ),
                    ),
                  ],

                  Expanded(
                    child: friendsAsync.when(
                      data: (friends) {
                        if (_searchController.text.isEmpty) {
                          _filteredFriends = friends;
                        }
                        if (_filteredFriends.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Center(
                              child: Text(
                                "No results found",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          );
                        }
                        return ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: _filteredFriends.length,
                          itemBuilder: (context, index) {
                            final friend = _filteredFriends[index];
                            return UserListTile(
                              user: friend,
                              onTap: () {},
                              actionWidget: CustomButton(
                                onPressed: () => _toggleFriendSelection(friend),
                                text:
                                    _selectedFriends.contains(friend)
                                        ? "Undo"
                                        : "Invite",
                                bgColor:
                                    _selectedFriends.contains(friend)
                                        ? null
                                        : AppTheme.primaryColor,
                                type:
                                    _selectedFriends.contains(friend)
                                        ? ButtonType.light
                                        : ButtonType.solid,
                                size: ButtonSize.xs,
                              ),
                            );
                          },
                        );
                      },
                      loading:
                          () =>
                              const Center(child: CircularProgressIndicator()),
                      error:
                          (error, stackTrace) => Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Center(
                              child: Text(
                                "Error: $error",
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
