import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/widgets/button.dart';
import 'package:zic_flutter/widgets/join_group_input.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  void _onSearchChanged(String query) async {
    // Handle search query changes
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              color: AppTheme.primaryColor,
              child: Column(
                children: [
                  JoinGroupInput(controller: _codeController, onJoin: () {}),
                  SizedBox(height: 8),
                  // Container(
                  //   height: 60,
                  //   decoration: BoxDecoration(
                  //     // Add your desired decoration here
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
          SliverAppBar(
            automaticallyImplyLeading: false,
            pinned: true,
            backgroundColor: AppTheme.backgroundColor(context),
            title:
                _isSearching
                    ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color:
                            AppTheme.isDark(context)
                                ? Colors.grey.shade900
                                : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          HeroIcon(
                            HeroIcons.magnifyingGlass,
                            style: HeroIconStyle.outline,
                            color: Colors.grey.shade500,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              //autofocus: true,
                              controller: _searchController,
                              onChanged: _onSearchChanged,
                              style: const TextStyle(
                                fontSize: 14,
                                decoration: TextDecoration.none,
                              ),
                              decoration: InputDecoration(
                                hintText: "Search",
                                hintStyle: TextStyle(
                                  fontSize: 14,
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
                    )
                    : Text("Chats"),
            leading:
                _isSearching
                    ? IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: _toggleSearch,
                    )
                    : null,
            actions:
                _isSearching
                    ? []
                    : [
                      CustomButton(
                        onPressed: () => print("add post pressed!"),
                        isIconOnly: true,
                        heroIcon: HeroIcons.pencilSquare,
                        iconStyle: HeroIconStyle.mini,
                        type: ButtonType.light,
                        size: ButtonSize.large,
                      ),
                      CustomButton(
                        onPressed: _toggleSearch,
                        isIconOnly: true,
                        heroIcon: HeroIcons.magnifyingGlass,
                        iconStyle: HeroIconStyle.mini,
                        type: ButtonType.light,
                        size: ButtonSize.large,
                      ),
                    ],
          ),
          SliverFillRemaining(
            child: Container(
              color: AppTheme.backgroundColor(context),
              child: Column(
                children: [
                  // Your chat content goes here
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
