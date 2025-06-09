import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/screens/post/create_post/post_create_state.dart';
import 'package:zic_flutter/screens/shared/custom_toast.dart';

class ActionButtons extends ConsumerWidget {
  const ActionButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postCreationState = ref.watch(postCreationNotifierProvider);

    return // Action buttons
    Container(
      color: AppTheme.backgroundColor(context),
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (postCreationState.selectedPostType == 'text' ||
              postCreationState.selectedPostType == 'media')
            IntrinsicWidth(
              child: _buildActionButton(
                context: context,
                ref: ref,
                icon: TablerIcons.library_photo,
                tab: 'media',
              ),
            ),
          const SizedBox(width: 14),
          if (postCreationState.selectedPostType == 'text' ||
              postCreationState.selectedPostType == 'media')
            IntrinsicWidth(
              child: InkWell(
                splashColor: Colors.transparent, // Elimină efectul de stropire
                highlightColor: Colors.transparent,
                onTap: () {
                  CustomToast.show(context, "Live shots comming soon!");
                },
                child: Icon(TablerIcons.camera, size: 28),
              ),
            ),
          const SizedBox(width: 14),
          if (postCreationState.selectedPostType == 'text')
            IntrinsicWidth(
              child: _buildActionButton(
                context: context,
                ref: ref,
                icon: TablerIcons.link,
                tab: 'link',
              ),
            ),
          const SizedBox(width: 14),
          if (postCreationState.selectedPostType == 'text')
            IntrinsicWidth(
              child: _buildActionButton(
                context: context,
                ref: ref,
                icon: TablerIcons.list_numbers,
                tab: 'poll',
              ),
            ),
          const SizedBox(width: 14),
          if (postCreationState.selectedPostType == 'text')
            IntrinsicWidth(
              child: InkWell(
                splashColor: Colors.transparent, // Elimină efectul de stropire
                highlightColor: Colors.transparent,
                onTap: () {
                  CustomToast.show(context, "Audio posts comming soon!");
                },
                child: Icon(TablerIcons.microphone, size: 28),
              ),
            ),
          const SizedBox(width: 14),
          const Spacer(),
          IntrinsicWidth(
            child: InkWell(
              splashColor: Colors.transparent, // Elimină efectul de stropire
              highlightColor: Colors.transparent,
              onTap: () {
                CustomToast.show(context, "Tags comming soon!");
              },
              child: Icon(TablerIcons.at, size: 28),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required WidgetRef ref,
    required IconData icon,
    required String tab,
  }) {
    final notifier = ref.read(postCreationNotifierProvider.notifier);

    return InkWell(
      splashColor: Colors.transparent, // Elimină efectul de stropire
      highlightColor: Colors.transparent,
      onTap: () {
        // Handle action button tap
        notifier.updateField('selectedPostType', tab);
      },
      child: Icon(
        icon,
        size: 28,
        color: AppTheme.isDark(context) ? AppTheme.grey200 : AppTheme.grey800,
      ),
    );
  }
}
