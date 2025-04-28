import 'package:flutter/material.dart';
import 'package:flutter_advanced_avatar/flutter_advanced_avatar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/providers/user_provider.dart';
import 'package:zic_flutter/screens/post/create_post/create_post.dart';
import 'package:zic_flutter/tabs/communities_screen.dart';
import 'package:zic_flutter/tabs/home_screen.dart';
import 'package:zic_flutter/tabs/profile_screen.dart';
import 'package:zic_flutter/tabs/search_screen.dart';

class TabsLayout extends StatefulWidget {
  const TabsLayout({super.key});

  @override
  State<TabsLayout> createState() => _TabsLayoutState();
}

class _TabsLayoutState extends State<TabsLayout> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const SearchScreen(withLeading: false),
    const CommunitiesScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getIcon(IconData icon, int index) {
    return SizedBox(
      // Changed to SizedBox
      width: 36, // Keep the fixed width
      height: 36, // Add a fixed height
      child: Center(
        // Center the icon within the SizedBox
        child: Icon(
          icon,
          color:
              _selectedIndex == index
                  ? AppTheme.foregroundColor(context)
                  : Colors.grey,
          size: 32,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: IndexedStack(index: _selectedIndex, children: _screens),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor(context),
            border: Border(
              top: BorderSide(
                width: 0.5,
                color:
                    AppTheme.isDark(context)
                        ? Colors.grey.shade900
                        : Colors.grey.shade100,
              ),
            ),
          ),
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _onItemTapped(0),
                  child: Center(child: _getIcon(TablerIcons.home, 0)),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () => _onItemTapped(1),
                  child: Center(child: _getIcon(TablerIcons.search, 1)),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CreatePost()),
                    );
                  },
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30.0),
                        border: Border.all(
                          color:
                              AppTheme.isDark(context)
                                  ? AppTheme.grey800
                                  : AppTheme.grey200,
                        ),
                      ),
                      child: Icon(
                        TablerIcons.plus,
                        color: Colors.grey[500],
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () => _onItemTapped(2),
                  child: Center(child: _getIcon(TablerIcons.users_group, 2)),
                ),
              ),
              // Expanded(
              //   child: InkWell(
              //     onTap: () => _onItemTapped(3),
              //     child: Center(
              //       child: _getIcon( TablerIcons.user,
              //         3,
              //       ),
              //     ),
              //   ),
              // ),
              Expanded(
                child: InkWell(
                  onTap: () => _onItemTapped(3),
                  child: Consumer(
                    builder: (context, ref, child) {
                      final userAsync = ref.watch(userProvider);
                      final String? avatarUrl = userAsync.value?.avatarUrl;

                      return Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (_selectedIndex == 3)
                              Container(
                                width: 35,
                                height: 35,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppTheme.foregroundColor(context),
                                    width: 3,
                                  ),
                                ),
                              ),
                            AdvancedAvatar(
                              size: 32,
                              image:
                                  avatarUrl != null
                                      ? NetworkImage(avatarUrl)
                                      : null,
                              autoTextSize: true,
                              name: userAsync.value?.fullname ?? "!",
                              style: TextStyle(
                                color:
                                    AppTheme.isDark(context)
                                        ? Colors.white
                                        : Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    AppTheme.isDark(context)
                                        ? AppTheme.grey800
                                        : AppTheme.grey200,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
