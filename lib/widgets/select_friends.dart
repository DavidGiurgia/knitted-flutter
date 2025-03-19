import 'package:flutter/material.dart';
import 'package:flutter_advanced_avatar/flutter_advanced_avatar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heroicons/heroicons.dart';
import 'package:zic_flutter/core/models/user.dart';
import 'package:zic_flutter/core/providers/friends_provider.dart';
import 'package:zic_flutter/widgets/user_list_tile.dart';
import 'package:zic_flutter/core/app_theme.dart';

class SelectFriends extends ConsumerStatefulWidget {
  final Function(List<String>) setSelectedFriends;

  const SelectFriends({super.key, required this.setSelectedFriends});

  @override
  ConsumerState<SelectFriends> createState() => _SelectFriendsState();
}

class _SelectFriendsState extends ConsumerState<SelectFriends> {
  final TextEditingController _searchController = TextEditingController();
  List<User> _filteredFriends = [];
  final List<User> _selectedFriends = [];

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

  void _toggleFriendSelection(User friend) {
    setState(() {
      if (_selectedFriends.contains(friend)) {
        _selectedFriends.remove(friend);
      } else {
        _selectedFriends.add(friend);
        _searchController.clear();
      }
      widget.setSelectedFriends(_selectedFriends.map((f) => f.id).toList());
    });
  }

  @override
  Widget build(BuildContext context) {
    final friendsAsync = ref.watch(friendsProvider(null));
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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

        /// Selected Friends Avatars
        if (_selectedFriends.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Selected Friends",
                style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              ),
            ),
          ),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: _selectedFriends.length,
              itemBuilder: (context, index) {
                final friend = _selectedFriends[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: GestureDetector(
                    onTap: () => _toggleFriendSelection(friend),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            AdvancedAvatar(
                              size: 50,
                              image: NetworkImage(friend.avatarUrl),
                              autoTextSize: true,
                              name: friend.fullname,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color:
                                    AppTheme.isDark(context)
                                        ? AppTheme.grey200
                                        : AppTheme.grey800,
                              ),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,

                                color:
                                    AppTheme.isDark(context)
                                        ? AppTheme.grey800
                                        : AppTheme.grey200,
                              ),
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: CircleAvatar(
                                radius: 10,
                                backgroundColor: Colors.redAccent,
                                child: Icon(
                                  Icons.close,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          friend.fullname,
                          style: TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],

        /// Suggested Friends List
        if (_searchController.text.isEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Suggested Friends",
                style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
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
                    onTap: () => _toggleFriendSelection(friend),
                    actionWidget:
                        _selectedFriends.contains(friend)
                            ? Icon(
                              Icons.check,
                              color: AppTheme.primaryColor,
                              size: 18,
                            )
                            : null,
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
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
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
