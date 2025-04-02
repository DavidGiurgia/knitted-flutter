import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/screens/post/create_post/post_data.dart';
import 'package:zic_flutter/screens/shared/custom_toast.dart';

class ActionButtons extends StatelessWidget {
  final PostData postData;
  final Function(String) updateSelectedOption;

  const ActionButtons({
    super.key,
    required this.postData,
    required this.updateSelectedOption,
  });

  @override
  Widget build(BuildContext context) {
  

    return // Action buttons
    Container(
      color: AppTheme.backgroundColor(context),
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (postData.selectedOption == 'text' ||
              postData.selectedOption == 'media')
            IntrinsicWidth(
              child: _buildActionButton(
                icon: TablerIcons.library_photo,
                tab: 'media',
                context: context,
              ),
            ),
          const SizedBox(width: 14),
          if (postData.selectedOption == 'text' ||
              postData.selectedOption == 'media')
            IntrinsicWidth(
              child: _buildActionButton(
                icon: TablerIcons.camera,
                tab: 'media',
                context: context,
              ),
            ),
          const SizedBox(width: 14),
          if (postData.selectedOption == 'text')
            IntrinsicWidth(
              child: _buildActionButton(
                icon: TablerIcons.link,
                tab: 'link',
                context: context,
              ),
            ),
          const SizedBox(width: 14),
          if (postData.selectedOption == 'text')
            IntrinsicWidth(
              child: _buildActionButton(
                icon: TablerIcons.list_numbers,
                tab: 'poll',
                context: context,
              ),
            ),
          const Spacer(),
          IntrinsicWidth(
            child: InkWell(
              splashColor: Colors.transparent, // Elimină efectul de stropire
              highlightColor: Colors.transparent,
              onTap: () {
                CustomToast.show(context, "Tags comming soon!");
              },
              child: Icon(TablerIcons.at, size: 28,),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildActionButton({required IconData icon, required String tab, required BuildContext context,}) {
    return InkWell(
      splashColor: Colors.transparent, // Elimină efectul de stropire
      highlightColor: Colors.transparent,
      onTap: () {
        updateSelectedOption(tab);
        if (tab == 'media') {
           postData.onMediaTap?.call();
        }
      },
      child: Icon(
        icon,
        size: 28,
        color: AppTheme.isDark(context) ? AppTheme.grey200 : AppTheme.grey800,
      ),
    );
  }
}
