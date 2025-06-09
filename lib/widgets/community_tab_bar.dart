import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/models/community.dart';

class CommunityTabBar extends ConsumerWidget implements PreferredSizeWidget {
  final TabController tabController;
  final List<Community> communities;

  const CommunityTabBar({
    super.key,
    required this.tabController,
    required this.communities,
  });

  @override
  Size get preferredSize => const Size.fromHeight(48.0);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TabBar(
      controller: tabController,
      //indicatorSize: TabBarIndicatorSize.tab,
      isScrollable:
          communities.length >
          3, // Devine scrollable doar dacă sunt multe tab-uri
      tabAlignment:
          communities.length > 3
              ? TabAlignment.center
              : TabAlignment.fill,
      tabs:
          communities.map((community) {
            return Tab(child: Text(community.name));
          }).toList(),
      labelColor: AppTheme.foregroundColor(context),
      indicatorColor: AppTheme.foregroundColor(context),
      dividerColor: Colors.grey.withValues(alpha: 0.1),
      unselectedLabelColor: AppTheme.isDark(context) ? Colors.grey.shade800 : Colors.grey.shade400,
    );
  }
}
