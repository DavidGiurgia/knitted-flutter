import 'package:flutter/material.dart';
import 'package:flutter_advanced_avatar/flutter_advanced_avatar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/providers/user_provider.dart';
import 'package:zic_flutter/tabs/chats_screen.dart';
import 'package:zic_flutter/tabs/groups_screen.dart';
import 'package:zic_flutter/tabs/home_screen.dart';
import 'package:zic_flutter/tabs/profile_screen.dart';
import 'package:zic_flutter/tabs/search_screen.dart';
import 'package:heroicons/heroicons.dart';

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
    const ChatsScreen(),
    const GroupsScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  HeroIcon _getIcon(HeroIcons icon, int index) {
    final Color iconColor =
        _selectedIndex == index
            ? AppTheme.primaryColor
            : AppTheme.isDark(context)
            ? AppTheme.grey100
            : AppTheme.grey900;
    return HeroIcon(
      icon,
      style:
          _selectedIndex == index ? HeroIconStyle.solid : HeroIconStyle.outline,
      color: iconColor,
      size: 32,
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
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _onItemTapped(0),
                  child: Center(child: _getIcon(HeroIcons.home, 0)),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () => _onItemTapped(1),
                  child: Center(child: _getIcon(HeroIcons.magnifyingGlass, 1)),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () => _onItemTapped(2),
                  child: Center(
                    child: _getIcon(HeroIcons.chatBubbleLeftRight, 2),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () => _onItemTapped(3),
                  child: Center(child: _getIcon(HeroIcons.userGroup, 3)),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () => _onItemTapped(4),
                  child: Consumer(
                    builder: (context, ref, child) {
                      final userAsync = ref.watch(userProvider);
                      final String? avatarUrl = userAsync.value?.avatarUrl;

                      return Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (_selectedIndex == 4)
                              Container(
                                width: 35,
                                height: 35,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppTheme.primaryColor,
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
