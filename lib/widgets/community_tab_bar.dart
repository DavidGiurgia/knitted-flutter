import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/providers/community_provider.dart';

class CommunityTabBar extends ConsumerWidget implements PreferredSizeWidget {
  final TabController tabController;

  const CommunityTabBar({super.key, required this.tabController});

  @override
  Size get preferredSize => const Size.fromHeight(48.0);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final communities = ref.watch(communitiesProvider);

    return Column(
      children: [
        SizedBox(
          height: 48,
          child: TabBar(
            controller: tabController,
            isScrollable: true,
            tabs: communities.map((community) {
              return Tab(
                child: Text(
                  community.name,
                  style: TextStyle(
                    color: tabController.index == communities.indexOf(community)
                        ? AppTheme.foregroundColor(context)
                        : Colors.grey,
                  ),
                ),
              );
            }).toList(),
            indicatorColor: AppTheme.foregroundColor(context),
            dividerColor: AppTheme.isDark(context)
                ? AppTheme.grey800
                : AppTheme.grey200,
          ),
        ),
        Container(
          color: AppTheme.isDark(context)
              ? AppTheme.grey800
              : AppTheme.grey200,
          height: 0.5,
        ),
      ],
    );
  }
}