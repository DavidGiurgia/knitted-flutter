import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import 'package:zic_flutter/core/api/friends.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/models/user.dart';
import 'package:zic_flutter/core/providers/friends_provider.dart';
import 'package:zic_flutter/core/providers/user_provider.dart';
import 'package:zic_flutter/widgets/button.dart';

class FriendshipStatusButton extends ConsumerStatefulWidget {
  final User user;
  final bool isCompact;
  const FriendshipStatusButton({
    super.key,
    required this.user,
    this.isCompact = false,
  });

  @override
  ConsumerState<FriendshipStatusButton> createState() =>
      _FriendshipStatusButtonState();
}

class _FriendshipStatusButtonState
    extends ConsumerState<FriendshipStatusButton> {
  bool isLoading = false;

  Future<void> handleFriendRequest(String action) async {
    final userId = ref.watch(userProvider).value?.id;

    if (userId == null) {
      return;
    }

    setState(() => isLoading = true);

    try {
      if (action == "add") {
        await FriendsService.request(userId, widget.user.id);
      } else if (action == "cancel") {
        await FriendsService.cancelFriendRequest(userId, widget.user.id);
      } else if (action == "accept") {
        await FriendsService.acceptFriendRequest(userId, widget.user.id);
      } else if (action == "remove") {
        await FriendsService.removeFriend(userId, widget.user.id);
      } else if (action == "block") {
        await FriendsService.blockUser(userId, widget.user.id);
      } else if (action == "unblock") {
        await FriendsService.unblockUser(userId, widget.user.id);
      }

      setState(() => isLoading = false);
      ref.invalidate(userProvider);
      ref.invalidate(friendsProvider);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  void showFriendOptions() {
    showModalBottomSheet(
      backgroundColor:
          AppTheme.isDark(context) ? AppTheme.grey900 : Colors.white,
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 5,
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 26,
                vertical: 0,
              ),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(TablerIcons.user_minus),
              ),
              title: Text(
                'Unfriend',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
              ),
              onTap: () {
                handleFriendRequest("remove");
                Navigator.pop(context);
              },
            ),

            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 26,
                vertical: 0,
              ),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(TablerIcons.forbid, color: Colors.red),
              ),
              title: Text(
                'Block',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              ),
              onTap: () {
                handleFriendRequest("block");
                Navigator.pop(context);
              },
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 26,
                vertical: 0,
              ),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(TablerIcons.alert_square_rounded, color: Colors.red),
              ),
              title: Text(
                'Report',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider).value;
    if (user == null) {
      return SizedBox.shrink();
    }
    final bool isFriend = user.friendsIds.contains(widget.user.id);
    final bool hasSentRequest = user.sentRequests.contains(widget.user.id);
    final bool hasIncomingRequest = user.friendRequests.contains(
      widget.user.id,
    );
    final bool isBlocked = user.blockedUsers.contains(widget.user.id);

    if (user.id == widget.user.id) {
      return SizedBox.shrink(); //Text("You");
    }

    return Container(
      constraints: BoxConstraints(
        maxWidth: widget.isCompact ? 110 : double.infinity,
      ),
      child: CustomButton(
        isLoading: isLoading,
        onPressed:
            isFriend
                ? showFriendOptions
                : () => handleFriendRequest(
                  hasSentRequest
                      ? "cancel"
                      : hasIncomingRequest
                      ? "accept"
                      : isBlocked
                      ? "unblock"
                      : "add",
                ),
        text:
            widget.isCompact
                ? isFriend
                    ? "Friends"
                    : hasSentRequest
                    ? "Requested"
                    : hasIncomingRequest
                    ? "Accept"
                    : isBlocked
                    ? "Unblock"
                    : "Add friend"
                : isFriend
                ? "Friends"
                : hasSentRequest
                ? "Cancel request"
                : hasIncomingRequest
                ? "Accept request"
                : isBlocked
                ? "Unblock"
                : "Add friend",
        isFullWidth: true,
        type:
            isFriend || hasSentRequest || hasIncomingRequest || isBlocked
                ? ButtonType.bordered
                : ButtonType.solid,
        size: widget.isCompact ? ButtonSize.xs : ButtonSize.small,
        icon:
            widget.isCompact
                ? null
                : isFriend
                ? TablerIcons.user_check
                : (!hasIncomingRequest && !hasSentRequest && !isBlocked)
                ? TablerIcons.user_plus
                : null,
        bgColor:
            isFriend || isBlocked
                ? AppTheme.foregroundColor(context)
                : AppTheme.primaryColor,
      ),
    );
  }
}
