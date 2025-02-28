import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zic_flutter/core/api/friends.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/models/user.dart';
import 'package:zic_flutter/core/providers/user_provider.dart';
import 'package:zic_flutter/widgets/button.dart';

class FriendshipStatusButton extends StatefulWidget {
  final User user;
  final bool isCompact;
  const FriendshipStatusButton({
    super.key,
    required this.user,
    this.isCompact = false,
  });

  @override
  State<FriendshipStatusButton> createState() => _FriendshipStatusButtonState();
}

class _FriendshipStatusButtonState extends State<FriendshipStatusButton> {
  bool isLoading = false;

  Future<void> handleFriendRequest(String action) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    setState(() => isLoading = true);

    try {
      if (action == "add") {
        await FriendsService.request(userProvider.user!.id, widget.user.id);
      } else if (action == "cancel") {
        await FriendsService.cancelFriendRequest(
          userProvider.user!.id,
          widget.user.id,
        );
      } else if (action == "accept") {
        await FriendsService.acceptFriendRequest(
          userProvider.user!.id,
          widget.user.id,
        );
      } else if (action == "remove") {
        await FriendsService.removeFriend(
          userProvider.user!.id,
          widget.user.id,
        );
      } else if (action == "block") {
        await FriendsService.blockUser(userProvider.user!.id, widget.user.id);
      } else if (action == "unblock") {
        await FriendsService.unblockUser(userProvider.user!.id, widget.user.id);
      }

      setState(() => isLoading = false);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      await userProvider.loadUser();
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
            // cum sa fac un handler in centru sus pentru 'tragere sheet'
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
                child: Icon(Icons.person_remove_rounded),
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
                child: Icon(Icons.block, color: Colors.red),
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
                child: Icon(Icons.report, color: Colors.red),
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
    final userProvider = Provider.of<UserProvider>(context);
    final bool isFriend = userProvider.user!.friendsIds.contains(
      widget.user.id,
    );
    final bool hasSentRequest = userProvider.user!.sentRequests.contains(
      widget.user.id,
    );
    final bool hasIncomingRequest = userProvider.user!.friendRequests.contains(
      widget.user.id,
    );
    final bool isBlocked = userProvider.user!.blockedUsers.contains(
      widget.user.id,
    );

    if (userProvider.user?.id == widget.user.id) {
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
                    : "Add"
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
                ? Icons.how_to_reg_rounded
                : (!hasIncomingRequest && !hasSentRequest && !isBlocked)
                ? Icons.person_add
                : null,
        bgColor:
            isFriend || isBlocked
                ? AppTheme.foregroundColor(context)
                : AppTheme.primaryColor,
      ),
    );
  }
}
