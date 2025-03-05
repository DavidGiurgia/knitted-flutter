import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:provider/provider.dart';
import 'package:zic_flutter/core/api/friends.dart';
import 'package:zic_flutter/core/api/notifications.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/models/chat_room.dart';
import 'package:zic_flutter/core/models/user.dart';
import 'package:zic_flutter/core/providers/user_provider.dart';
import 'package:zic_flutter/screens/chats/temporary_chat_room.dart';
import 'package:zic_flutter/widgets/button.dart';
import 'package:zic_flutter/widgets/user_list_tile.dart';

class InviteFriendsSection extends StatefulWidget {
  final Room room;
  const InviteFriendsSection({super.key, required this.room});

  @override
  State<InviteFriendsSection> createState() => _InviteFriendsSectionState();
}

class _InviteFriendsSectionState extends State<InviteFriendsSection> {
  bool isLoading = false;
  final TextEditingController nameController = TextEditingController();
  final List<String> participants = [];
  final TextEditingController _searchController = TextEditingController();
  List<User> friends = [];
  List<User> filteredFriends = [];
  List<User> selectedFriends = [];

  void handleSendNotifications() async {
    setState(() => isLoading = true);
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.user == null) {
        throw Exception("User not logged in");
      }
      for (var friend in selectedFriends) {
        await NotificationService.createNotification(
          userProvider.user!.id,
          friend.id,
          "chat_invitation",
          {
            "chatRoomTopic": widget.room.topic,
            "chatRoomId": widget.room.id,
          },
        );
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TemporaryChatRoom(room: widget.room)),
      );
    } catch (error) {
      print("Error sending notifications: $error");
      // Show an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error sending notifications: $error")),
      );
    }
    setState(() => isLoading = false);
  }

  void setSelectedFriends(List<String> selectedFriends) {
    setState(() {
      participants
        ..clear()
        ..addAll(selectedFriends);
    });
  }

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  void _loadFriends() async {
    setState(() => isLoading = true);
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      friends = await FriendsService.getUserFriends(userProvider.user!.id);
      filteredFriends = friends;
    } catch (error) {
      print("Error fetching friends: $error");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      filteredFriends =
          friends
              .where(
                (friend) =>
                    friend.fullname.toLowerCase().contains(query.toLowerCase()),
              )
              .toList();
    });
  }

  void _toggleFriendSelection(User friend) {
    setState(() {
      if (selectedFriends.contains(friend)) {
        selectedFriends.remove(friend);
      } else {
        selectedFriends.add(friend);
        //_searchController.clear();
      }
      setSelectedFriends(selectedFriends.map((f) => f.id).toList());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Invite your friends"),
        leading: IconButton(
          icon: Icon(Icons.close, color: AppTheme.foregroundColor(context)),
          onPressed:
              () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => TemporaryChatRoom(room: widget.room,)),
              ),

          /// go to created chat
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
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color:
                            AppTheme.isDark(context)
                                ? Colors.grey.shade900
                                : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          HeroIcon(
                            HeroIcons.magnifyingGlass,
                            style: HeroIconStyle.outline,
                            color: Colors.grey.shade500,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: _onSearchChanged,
                              style: const TextStyle(
                                fontSize: 15,
                                decoration: TextDecoration.none,
                              ),
                              decoration: InputDecoration(
                                hintText: "Search friends...",
                                hintStyle: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey.shade500,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
                    child:
                        isLoading
                            ? Center(child: CircularProgressIndicator())
                            : filteredFriends.isEmpty
                            ? Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Center(
                                child: Text(
                                  "No results found",
                                  style: TextStyle(color: Colors.grey.shade500),
                                ),
                              ),
                            )
                            : ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: filteredFriends.length,
                              itemBuilder: (context, index) {
                                final friend = filteredFriends[index];
                                return UserListTile(
                                  user: friend,
                                  onTap:
                                      () {}, // Remove feedback effect by not providing a callback
                                  actionWidget: CustomButton(
                                    onPressed:
                                        () => _toggleFriendSelection(friend),
                                    text:
                                        selectedFriends.contains(friend)
                                            ? "Undo"
                                            : "Invite",
                                    bgColor:
                                        selectedFriends.contains(friend)
                                            ? null
                                            : AppTheme.primaryColor,
                                    type:
                                        selectedFriends.contains(friend)
                                            ? ButtonType.light
                                            : ButtonType.solid,
                                    size: ButtonSize.xs,
                                  ),
                                );
                              },
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
