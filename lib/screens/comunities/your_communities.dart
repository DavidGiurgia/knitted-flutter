import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/models/community.dart';
import 'package:zic_flutter/core/providers/community_provider.dart';
import 'package:zic_flutter/screens/comunities/create_community.dart';

class YourCommunities extends ConsumerStatefulWidget {
  const YourCommunities({super.key});

  @override
  ConsumerState<YourCommunities> createState() => _YourCommunitiesState();
}

class _YourCommunitiesState extends ConsumerState<YourCommunities> {
  @override
  void initState() {
    super.initState();
   // Schedule the load after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    await ref.read(CommunityNotifier.provider.notifier).loadUserCommunities();
  }

  @override
  Widget build(BuildContext context) {
    final communityState = ref.watch(CommunityNotifier.provider);

    return RefreshIndicator(
      onRefresh: _loadData,
      child: CustomScrollView(
        slivers: [
          // Header cu buton de creare
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    'Your Spaces',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(TablerIcons.plus),
                    tooltip: 'Create community',
                    onPressed: () => _createNewCommunity(context),
                  ),
                ],
              ),
            ),
          ),

          // Comunități principale
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: _buildCommunityList(communityState),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityList(CommunityState state) {
    if (state.isLoading) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.error != null) {
      return SliverToBoxAdapter(
        child: _buildErrorWidget(state.error!, onRetry: _loadData),
      );
    }

    final communities = state.joinedCommunities;
    if (communities.isEmpty) {
      return SliverToBoxAdapter(
        child: _buildEmptyState(
          'You haven\'t joined any communities yet',
          actionText: 'Explore communities',
          onAction: () => _switchToExploreTab(context),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => _buildCommunityCard(communities[index]),
        childCount: communities.length,
      ),
    );
  }

  Widget _buildCommunityCard(Community community) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _navigateToCommunity(community),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Avatar comunitate
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.grey200,
                  borderRadius: BorderRadius.circular(24),
                  image:
                      community.bannerUrl.isNotEmpty
                          ? DecorationImage(
                            image: NetworkImage(community.bannerUrl),
                            fit: BoxFit.cover,
                          )
                          : null,
                ),
                child:
                    community.bannerUrl.isEmpty
                        ? const Icon(TablerIcons.users, size: 24)
                        : null,
              ),
              const SizedBox(width: 12),

              // Detalii comunitate
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      community.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${community.members.length} members',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),

              // Indicator de acces
              const Icon(TablerIcons.chevron_right, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    String message, {
    String? actionText,
    VoidCallback? onAction,
  }) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(TablerIcons.users_group, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          if (actionText != null) ...[
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onAction, child: Text(actionText)),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String message, {VoidCallback? onRetry}) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(TablerIcons.alert_circle, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(message, style: Theme.of(context).textTheme.bodyLarge),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ],
      ),
    );
  }

  void _createNewCommunity(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateCommunity()),
    );
  }

  void _navigateToCommunity(Community community) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Opening ${community.name}')));
  }

  void _switchToExploreTab(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Switching to Explore tab')));
  }
}
