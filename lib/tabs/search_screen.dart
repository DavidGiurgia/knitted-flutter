import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:heroicons/heroicons.dart';

import 'package:zic_flutter/core/api/recent_search.dart';
import 'package:zic_flutter/core/api/user.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/models/user.dart';
import 'package:zic_flutter/core/providers/search_provider.dart';
import 'package:zic_flutter/core/providers/user_provider.dart';
import 'package:zic_flutter/screens/shared/user_profile_screen.dart';
import 'package:zic_flutter/widgets/button.dart';
import 'package:zic_flutter/widgets/user_list_tile.dart';

class SearchScreen extends ConsumerStatefulWidget {
  final bool withLeading;

  const SearchScreen({super.key, this.withLeading = true});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
   final FocusNode _searchFocusNode = FocusNode();
  List<User> _recentSearches = [];
  bool _loadingRecent = true;
  late String userId;

  @override
  void initState() {
    super.initState();
    final userAsync = ref.read(userProvider);
    userId = userAsync.value!.id;
    _fetchRecentSearches();
    _searchController.addListener(_onSearchTextChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchTextChanged);
    _searchController.dispose();
    _searchFocusNode.dispose(); 
    super.dispose();
  }

  void _onSearchTextChanged() {
    if (_searchController.text.isEmpty) {
      setState(() {});
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
      return;
    }
    ref.read(searchProvider.notifier).searchUsers(query);
  }

  void _addToRecent(User user) async {
    await RecentSearchService.addRecentSearch(userId, user.id);
    setState(() {
      _recentSearches.add(user);
      _moveToTop(user);
    });
  }

  void _moveToTop(User user) async {
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
    final searchAsync = ref.watch(searchProvider);
    return Scaffold(
      // backgroundColor:
      //     AppTheme.isDark(context) ? AppTheme.grey950 : Colors.white,
      appBar: AppBar(
        titleSpacing: 0,
        automaticallyImplyLeading: widget.withLeading,

        title: Padding(
          padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color:
                  AppTheme.isDark(context)
                      ? Colors.grey.shade900
                      : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Icon(TablerIcons.search, color: Colors.grey.shade500, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
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
            child: searchAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (error, stackTrace) => Center(child: Text("Error: $error")),
              data:
                  (results) =>
                      _searchController.text.isEmpty
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
                                    padding: const EdgeInsets.fromLTRB(
                                      16,
                                      20,
                                      16,
                                      8,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Recent",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: _clearRecent,
                                          child: Text(
                                            "Clear",
                                           style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
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
                                            onPressed:
                                                () => _removeRecent(user),
                                            isIconOnly: true,
                                            size: ButtonSize.small,
                                          ),
                                          onTap:
                                              () => {
                                                _moveToTop(user),
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (
                                                      BuildContext context,
                                                    ) {
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
                          : results.isEmpty
                          ? Center(
                            child: Text(
                              "No result found for \"${_searchController.text}\"",
                              style: TextStyle(fontSize: 16),
                            ),
                          )
                          : ListView.builder(
                            itemCount: results.length,
                            itemBuilder: (context, index) {
                              final result = results[index];
                              if (result.type == 'friend') {
                                final user = result.data as User;
                                return UserListTile(
                                  user: user,
                                  onTap:
                                      () => {
                                        _addToRecent(user),
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => UserProfileScreen(
                                                  user: user,
                                                ),
                                          ),
                                        ),
                                      },
                                );
                              } else {
                                return ListTile(
                                  title: Text('Room: ${result.data.topic}'),
                                );
                              }
                            },
                          ),
            ),
          ),
        ],
      ),
    );
  }
}
