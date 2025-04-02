import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:zic_flutter/core/api/room_service.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/models/user.dart';
import 'package:zic_flutter/core/providers/friends_provider.dart';
import 'package:zic_flutter/core/providers/user_provider.dart';
import 'package:zic_flutter/screens/chats/chat_room.dart';
import 'package:zic_flutter/screens/chats/new_group_chat_section.dart';
import 'package:zic_flutter/screens/chats/new_temporary_chat_section.dart';
import 'package:zic_flutter/widgets/search_input.dart';
import 'package:zic_flutter/widgets/user_list_tile.dart';

class NewMessageSection extends ConsumerStatefulWidget {
  const NewMessageSection({super.key});

  @override
  ConsumerState<NewMessageSection> createState() => _NewMessageSectionState();
}

class _NewMessageSectionState extends ConsumerState<NewMessageSection> {
  bool isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  List<User> _filteredFriends = [];

  void _onSearchChanged(String query) {
    final friendsAsync = ref.read(friendsProvider(null));
    friendsAsync.when(
      data: (friends) {
        setState(() {
          _filteredFriends =
              friends
                  .where(
                    (friend) => friend.fullname.toLowerCase().contains(
                      query.toLowerCase(),
                    ),
                  )
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

  void handleCreateRoom(User friend) async {
    final userAsync = ref.read(userProvider);
    final currentUser = userAsync.value;
    if (currentUser == null) {
      return;
    }
    //log
    print("Room will be created");

    setState(() {
      isLoading = true;
    });
    final room = await RoomService.createPrivateRoom(currentUser.id, friend.id);
    if (room != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ChatRoomSection(room: room)),
      );
    } else {
      print("Failed to create room");
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final friendsAsync = ref.watch(friendsProvider(null));

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text("New message")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            GestureDetector(
              onTap:
                  () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NewTemporaryChatSection(),
                    ),
                  ),
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        AppTheme.isDark(context)
                            ? Colors.grey.shade700
                            : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  children: [
                    // Large colored icon
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.foregroundColor(
                          context,
                        ).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        TablerIcons.hash,
                        color: AppTheme.foregroundColor(context),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Title and subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Temporary chat",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "Start a short-lived chat with no saved messages and anonymous participation.",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NewGroupChatSection(),
                    ),
                  ),
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        AppTheme.isDark(context)
                            ? Colors.grey.shade700
                            : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  children: [
                    // Large colored icon
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.foregroundColor(
                          context,
                        ).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        TablerIcons.users_plus,
                        color: AppTheme.foregroundColor(context),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Title and subtitle
                    Expanded(
                      child: Text(
                        "Group chat",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    
                  ],
                ),
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
                              onTap: () {
                                handleCreateRoom(friend);
                              }, // set friend and create room
                            );
                          },
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
}
