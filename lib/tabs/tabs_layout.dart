import 'package:flutter/material.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/tabs/chats_screen.dart';
import 'package:zic_flutter/tabs/groups_screen.dart';
import 'package:zic_flutter/tabs/home_screen.dart';
import 'package:zic_flutter/tabs/profile_screen.dart';
import 'package:zic_flutter/tabs/search_screen.dart';
import 'package:heroicons/heroicons.dart';
import 'package:zic_flutter/widgets/avvvatar.dart';

class TabsLayout extends StatefulWidget {
  const TabsLayout({super.key});

  @override
  State<TabsLayout> createState() => _TabsLayoutState();
}

class _TabsLayoutState extends State<TabsLayout> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    SearchScreen(),
    ChatsScreen(),
    GroupsScreen(),
    ProfileScreen(),
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
        body: _screens[_selectedIndex],
        bottomNavigationBar: Container(
          height: 64, // Înălțimea fixă a barei de navigație
          color: AppTheme.isDark(context) ? Colors.black : Colors.white,
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
                    child: CustomAvatar(
                      name: 'Giurgia David',
                      size: 32.0,
                      textColor: Colors.white,
                      borderColor: AppTheme.primaryColor,
                      borderWidth: 1.0,
                      withRing: _selectedIndex == 4,
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
