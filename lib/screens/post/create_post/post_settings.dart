import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/models/community.dart';
import 'package:zic_flutter/core/providers/community_provider.dart';
import 'package:zic_flutter/screens/post/create_post/post_create_state.dart';

class PostSettingsBottomSheet extends ConsumerWidget {
  const PostSettingsBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final communitiesState = ref.watch(CommunityNotifier.provider);
    final joinedCommunities = communitiesState.joinedCommunities;

    final notifier = ref.read(postCreationNotifierProvider.notifier);
    final postCreationState = ref.watch(postCreationNotifierProvider);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                "Post audience",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.foregroundColor(context),
                ),
              ),
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: Colors.grey.withValues(alpha: 0.1),
          ),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildAudienceOption(
                    context,
                    title: 'Friends',
                    description: 'Your friends on Troop',
                    icon: TablerIcons.users,
                    isSelected: postCreationState.selectedAudience == 'friends',
                    onTap: () {
                      notifier.selectFriendsAudience();
                      Navigator.pop(context);
                    },
                  ),
                  ...joinedCommunities.map(
                    (community) => _buildCommunityOption(
                      context,
                      community: community,
                      isSelected:
                          postCreationState.selectedAudience != 'friends' &&
                          postCreationState.selectedCommunity?.id ==
                              community.id,
                      onTap: () {
                        notifier.selectCommunityAudience(community);
                        Navigator.pop(context);
                      },
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

  Widget _buildAudienceOption(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppTheme.primaryColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
              ),
            ),
            if (isSelected) Icon(Icons.check, color: AppTheme.primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunityOption(
    BuildContext context, {
    required Community community,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.foregroundColor(context).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                TablerIcons.users_group,
                color: AppTheme.foregroundColor(context),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    community.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    "${community.members.length} members",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
              ),
            ),
            if (isSelected) Icon(Icons.check, color: AppTheme.primaryColor),
          ],
        ),
      ),
    );
  }
}
