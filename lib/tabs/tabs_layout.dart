import 'package:flutter/material.dart';
import 'package:flutter_advanced_avatar/flutter_advanced_avatar.dart';
import 'package:provider/provider.dart';
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
  final PageController _pageController = PageController();

  final List<Widget> _screens = [
    HomeScreen(),
    SearchScreen(withLeading: false),
    ChatsScreen(),
    GroupsScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  void _onPageChanged(int index) {
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
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final String? avatarUrl = userProvider.user?.avatarUrl;

    return SafeArea(
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          children: _screens,
        ),
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
          height: 64, // Înălțimea fixă a barei de navigație
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
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (_selectedIndex ==
                            4) // Inelul apare doar când e pe tab-ul profile
                          Container(
                            width: 35, // Dimensiunea inelului
                            height: 35,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color:
                                    AppTheme.primaryColor, // Culoarea inelului
                                width: 3,
                              ),
                            ),
                          ),

                        // Avatarul real
                        AdvancedAvatar(
                          size: 32, // Dimensiune avatar
                          image:
                              avatarUrl != null
                                  ? NetworkImage(avatarUrl)
                                  : null,
                          autoTextSize: true,
                          name:
                              userProvider.user?.fullname ??
                              "uk", // Inițiale fallback
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
