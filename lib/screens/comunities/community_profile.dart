import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:zic_flutter/core/models/community.dart';
import 'package:zic_flutter/core/app_theme.dart';

class CommunityProfileScreen extends StatelessWidget {
  final Community community;

  const CommunityProfileScreen({super.key, required this.community});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header cu banner și titlu
          SliverAppBar(
            expandedHeight: 200,
            flexibleSpace: FlexibleSpaceBar(
              background: community.bannerUrl.isNotEmpty
                  ? Image.network(
                      community.bannerUrl,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: AppTheme.isDark(context)
                          ? AppTheme.grey800
                          : AppTheme.grey200,
                      child: const Icon(
                        TablerIcons.users_group,
                        size: 64,
                        color: Colors.white,
                      ),
                    ),
            ),
            pinned: true,
            actions: [
              IconButton(
                icon: const Icon(TablerIcons.share),
                onPressed: () {
                  // TODO: Implement share functionality
                },
              ),
              PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'invite',
                    child: Text('Invite friends'),
                  ),
                  const PopupMenuItem(
                    value: 'settings',
                    child: Text('Community settings'),
                  ),
                ],
              ),
            ],
          ),

          // Conținut principal
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  // Titlu și descriere
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        community.name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        community.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),

                  // Statistici comunitate
                  _buildStatsRow(context),
                  const SizedBox(height: 24),

                  // Butoane principale
                  _buildActionButtons(context),
                  const SizedBox(height: 24),

                  // Reguli comunitate
                  if (community.rules.isNotEmpty) ...[
                    _buildSectionTitle('Community Rules'),
                    ...community.rules.map(
                      (rule) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 4, right: 8),
                              child: Icon(
                                TablerIcons.point,
                                size: 16,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                rule,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Administratori
                  _buildSectionTitle('Admins'),
                  SizedBox(
                    height: 80,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        if (community.admins.isEmpty)
                          const Text('No admins')
                        else
                          ...community.admins.take(10).map(
                                (admin) => Padding(
                                  padding: const EdgeInsets.only(right: 16),
                                  child: Column(
                                    children: [
                                      CircleAvatar(
                                        radius: 24,
                                        backgroundColor: AppTheme.isDark(context)
                                            ? AppTheme.grey800
                                            : AppTheme.grey200,
                                        child: const Icon(TablerIcons.user),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        admin.split('@').first,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(
          context,
          TablerIcons.users,
          '${community.members.length}',
          'Members',
        ),
        _buildStatItem(
          context,
          TablerIcons.calendar,
          community.createdAt != null
              ? '${DateTime.now().difference(community.createdAt!).inDays}d'
              : 'N/A',
          'Age',
        ),
        _buildStatItem(
          context,
          TablerIcons.settings,
          community.onlyAdminsCanPost ? 'Admin posts' : 'All posts',
          'Posting',
        ),
      ],
    );
  }

  Widget _buildStatItem(
      BuildContext context, IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final isMember = community.members.any((m) => m == 'current_user_id');
    final isAdmin = community.admins.any((a) => a == 'current_user_id');

    return Row(
      children: [
        Expanded(
          child: FilledButton(
            onPressed: () {
              // TODO: Handle join/leave action
            },
            child: Text(isMember ? 'Joined' : 'Join Community'),
          ),
        ),
        const SizedBox(width: 8),
        if (isMember || isAdmin)
          IconButton.filled(
            onPressed: () {
              // TODO: Handle create post
            },
            icon: const Icon(TablerIcons.plus),
          ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}