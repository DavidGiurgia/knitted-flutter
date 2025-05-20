import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/screens/comunities/your_communities.dart';

class CommunitiesScreen extends StatefulWidget {
  const CommunitiesScreen({super.key});

  @override
  State<CommunitiesScreen> createState() => _CommunitiesScreenState();
}

class _CommunitiesScreenState extends State<CommunitiesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose(); // Dispose the scroll controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              automaticallyImplyLeading: false,
              title: Text(
                'Communities',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(TablerIcons.search),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(TablerIcons.dots_vertical),
                ),
              ],
              floating: true,
              scrolledUnderElevation: 0.0,
              pinned: true, 
              bottom: TabBar(
                controller: _tabController,
                dividerColor: AppTheme.isDark(context)
                    ? AppTheme.grey800
                    : AppTheme.grey200,
                indicatorColor: AppTheme.foregroundColor(context),
                labelColor: AppTheme.foregroundColor(context),
                unselectedLabelColor: Colors.grey,
                tabs: const [
                  Tab(text: "Home"),
                  Tab(text: "Explore"),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: const [
            YourCommunities(),
            Center(
              child: Text("Explore Communities (Coming Soon!)"),
            ),
          ],
        ),
      ),
    );
  }
}
