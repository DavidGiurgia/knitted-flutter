import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:provider/provider.dart';
import 'package:zic_flutter/core/api/recent_search.dart';
import 'package:zic_flutter/core/api/user.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/models/user.dart';
import 'package:zic_flutter/core/providers/user_provider.dart';
import 'package:zic_flutter/screens/shared/user_profile_screen.dart';
import 'package:zic_flutter/widgets/button.dart';
import 'package:zic_flutter/widgets/user_list_tile.dart';

class SearchScreen extends StatefulWidget {
  final bool withLeading;

  const SearchScreen({super.key, this.withLeading = true});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<User> _searchResults = [];
  List<User> _recentSearches = [];
  bool _loading = false;
  bool _loadingRecent = true;
  late String userId;

  @override
  void initState() {
    super.initState();
    userId = Provider.of<UserProvider>(context, listen: false).user!.id;
    _fetchRecentSearches();
    _searchController.addListener(_onSearchTextChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchTextChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchTextChanged() {
    if (_searchController.text.isEmpty) {
      setState(() => _searchResults = []);
    } else {
      _onSearchChanged(_searchController.text);
    }
  }

  void _fetchRecentSearches() async {
    setState(() => _loadingRecent = true);
    List<String> recentIds = await RecentSearchService.fetchRecentSearches(
      userId,
    );
    List<User> recentUsers = [];
    for (String id in recentIds) {
      User? user = await UserService.fetchUserById(id);
      if (user != null) {
        recentUsers.add(user);
      }
    }
    setState(() {
      _recentSearches = recentUsers;
      _loadingRecent = false;
    });
  }

  void _onSearchChanged(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _loading = true);
    List<User> results = await UserService.searchUser(query, userId);
    setState(() {
      _searchResults = results;
      _loading = false;
    });
  }

  void _addToRecent(User user) async {
    await RecentSearchService.addRecentSearch(userId, user.id);
    setState(() {
      _recentSearches.add(user);
      _moveToTop(user);
    });
  }

  void _moveToTop(User user) async {
    //await RecentSearchService.moveRecentSearchToTop(userId, user.id);
    setState(() {
      _recentSearches = [
        user,
        ..._recentSearches.where((u) => u.id != user.id),
      ];
    });
  }

  void _clearRecent() async {
    await RecentSearchService.clearRecentSearches(userId);
    setState(() => _recentSearches = []);
  }

  void _removeRecent(User user) async {
    await RecentSearchService.removeRecentSearch(userId, user.id);
    setState(() {
      _recentSearches.remove(user);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppTheme.isDark(context) ? AppTheme.grey950 : Colors.white,
      appBar: AppBar(
        titleSpacing: 0,
        automaticallyImplyLeading: widget.withLeading,

        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                      hintText: "Search ",
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
      ),

      body: Column(
        children: [
          Expanded(
            child:
                _loading
                    ? Center(child: CircularProgressIndicator())
                    : _searchController.text.isEmpty
                    ? _loadingRecent
                        ? Center(child: CircularProgressIndicator())
                        : _recentSearches.isEmpty
                        ? Center(
                          child: Text(
                            "No recent searches",
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                        : Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Recent",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: _clearRecent,
                                    child: Text(
                                      "Clear all",
                                      style: TextStyle(
                                        color: Colors.blueAccent,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                itemCount: _recentSearches.length,
                                itemBuilder: (context, index) {
                                  User user = _recentSearches[index];
                                  return UserListTile(
                                    user: user,
                                    actionWidget: CustomButton(
                                      heroIcon: HeroIcons.xMark,
                                      onPressed: () => _removeRecent(user),
                                      isIconOnly: true,
                                      size: ButtonSize.small,
                                    ),
                                    onTap:
                                        () => {
                                          _moveToTop(user),
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (BuildContext context) {
                                                return UserProfileScreen(
                                                  user: user,
                                                );
                                              },
                                            ),
                                          ),
                                        },
                                  );
                                },
                              ),
                            ),
                          ],
                        )
                    : _searchResults.isEmpty
                    ? Center(
                      child: Text(
                        "No results found",
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                    : ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        User user = _searchResults[index];
                        return UserListTile(
                          user: user,
                          onTap:
                              () => {
                                _addToRecent(user),
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            UserProfileScreen(user: user),
                                  ),
                                ),
                              },
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
