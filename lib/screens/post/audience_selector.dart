import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/screens/post/create_post/post_create_state.dart';
import 'package:zic_flutter/screens/post/create_post/post_settings.dart';

class AudienceSelector extends ConsumerWidget {
  const AudienceSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postCreationState = ref.watch(postCreationNotifierProvider);

    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (context) => const PostSettingsBottomSheet(),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.backgroundColor(context),
          border: Border(
            top: BorderSide(
              color:
                  AppTheme.isDark(context)
                      ? AppTheme.grey800
                      : AppTheme.grey200,
              width: 1,
            ),
            bottom: BorderSide(
              color:
                  AppTheme.isDark(context)
                      ? AppTheme.grey800
                      : AppTheme.grey200,
              width: 1,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              postCreationState.selectedAudience != "friends"
                  ? TablerIcons.users_group
                  : TablerIcons.users,
            ),
            const SizedBox(width: 8),
            Text(
              postCreationState.selectedAudience == "friends"
                  ? "To your friends"
                  : postCreationState.selectedCommunity?.name ?? "Unknown community",
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
