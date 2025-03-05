import 'package:flutter/material.dart';
import 'package:flutter_advanced_avatar/flutter_advanced_avatar.dart';
import 'package:heroicons/heroicons.dart';
import 'package:provider/provider.dart';
import 'package:zic_flutter/core/api/friends.dart';
import 'package:zic_flutter/core/models/user.dart';
import 'package:zic_flutter/core/providers/user_provider.dart';
import 'package:zic_flutter/widgets/user_list_tile.dart';
import 'package:zic_flutter/core/app_theme.dart';

class SelectFriends extends StatefulWidget {
  final Function(List<String>) setSelectedFriends;

  const SelectFriends({super.key, required this.setSelectedFriends});

  @override
  State<SelectFriends> createState() => _SelectFriendsState();
}

class _SelectFriendsState extends State<SelectFriends> {
  final TextEditingController _searchController = TextEditingController();
  List<User> friends = [];
  List<User> filteredFriends = [];
  List<User> selectedFriends = [];
  bool isLoading = false;

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
        _searchController.clear();
      }
      widget.setSelectedFriends(selectedFriends.map((f) => f.id).toList());
    });
  }

  @override
  Widget build(BuildContext context) {
    return  Column(
      children: [
        /// Search Input
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
        if (selectedFriends.isNotEmpty) ...[
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
              itemCount: selectedFriends.length,
              itemBuilder: (context, index) {
                final friend = selectedFriends[index];
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
                        onTap: () => _toggleFriendSelection(friend),
                        actionWidget:
                            selectedFriends.contains(friend)
                                ? Icon(
                                  Icons.check,
                                  color: AppTheme.primaryColor,
                                  size: 18,
                                )
                                : null,
                      );
                    },
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
