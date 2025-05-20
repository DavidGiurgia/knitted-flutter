import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:zic_flutter/core/api/friends.dart';
import 'package:zic_flutter/core/api/room_participants.dart';
import 'package:zic_flutter/core/api/room_service.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/models/notification.dart';
import 'package:zic_flutter/core/providers/notifications_provider.dart';
import 'package:zic_flutter/core/providers/rooms_provider.dart';
import 'package:zic_flutter/core/providers/user_provider.dart';
import 'package:zic_flutter/screens/chats/temporary_chat_room.dart';
import 'package:zic_flutter/screens/shared/custom_toast.dart';
import 'package:zic_flutter/widgets/notifincations/notification.dart';

enum NotificationTab { all, requests, replies, mentions }

final currentNotificationTabProvider = StateProvider<NotificationTab>(
  (ref) => NotificationTab.all,
);

class ActivityScreen extends ConsumerWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor(context),
        appBar: AppBar(
          title: const Text("Activity"),
          backgroundColor: AppTheme.backgroundColor(context),
          bottom: TabBar(
            isScrollable: true,
            //indicatorSize: TabBarIndicatorSize.tab,
            tabAlignment: TabAlignment.center,
            dividerColor: Colors.grey.withValues(alpha: 0.1),
            onTap: (index) {
              ref.read(currentNotificationTabProvider.notifier).state =
                  NotificationTab.values[index];
            },
            tabs: const [
              Tab(text: 'All'),
              Tab(text: 'Requests'),
              Tab(text: 'Replies'),
              Tab(text: 'Mentions'),
            ],
            indicatorColor: AppTheme.foregroundColor(context),
            labelColor: AppTheme.foregroundColor(context),
            unselectedLabelColor: Colors.grey,
          ),
        ),
        body: const TabBarView(
          children: [
            _AllNotificationsTab(),
            _RequestsTab(),
            _RepliesTab(),
            _MentionsTab(),
          ],
        ),
      ),
    );
  }
}

class _AllNotificationsTab extends ConsumerWidget {
  const _AllNotificationsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(notificationsProvider),
      child: notificationsAsync.when(
        data:
            (notifications) =>
                notifications.isEmpty
                    ? const _EmptyState(tab: NotificationTab.all)
                    : ListView.builder(
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        return NotificationItem(
                          notification: notifications[index],
                          onAction:
                              () => _handleAction(
                                context,
                                ref,
                                notifications[index],
                              ),
                        );
                      },
                    ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    WidgetRef ref,
    NotificationModel notification,
  ) async {
    final userId = ref.read(userProvider).value?.id;
    if (userId == null) return;

    switch (notification.type) {
      case NotificationType.friendRequest:
        await FriendsService.acceptFriendRequest(userId, notification.senderId);
        ref.invalidate(userProvider);
        break;
      case NotificationType.chatInvitation:
        await _handleChatInvitation(context, ref, notification);
        break;
      case NotificationType.friendRequestAccepted:
      case NotificationType.reply:
      case NotificationType.mention:
        // Handle other cases as needed
        break;
    }
  }

  Future<void> _handleChatInvitation(
    BuildContext context,
    WidgetRef ref,
    NotificationModel notification,
  ) async {
    final room = await RoomService.getRoomById(notification.data['chatRoomId']);
    if (room == null) {
      CustomToast.show(context, 'Sorry, this room does not exist.');
      return;
    }

    final user = ref.read(userProvider).value;
    if (user == null) return;

    final roomsAsync = ref.read(roomsProvider);
    if (roomsAsync.isLoading || roomsAsync.hasError) return;

    final rooms = roomsAsync.value ?? [];
    if (rooms.indexWhere((r) => r.id == room.id) == -1) {
      ref.read(roomsProvider.notifier).addRoom(room);
      await RoomParticipantsService.addParticipantToRoom(room.id, user.id);
    }

    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TemporaryChatRoomSection(room: room),
        ),
      );
    }
  }
}

class _RequestsTab extends ConsumerWidget {
  const _RequestsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);
    final notificationsAsync = ref.watch(notificationsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(userProvider);
        ref.invalidate(notificationsProvider);
      },
      child: userAsync.when(
        data: (user) {
          if (user == null) return const SizedBox.shrink();

          return notificationsAsync.when(
            data: (notifications) {
              final requests =
                  notifications
                      .where(
                        (n) =>
                            n.type == NotificationType.friendRequest ||
                            n.type == NotificationType.chatInvitation,
                      )
                      .toList();

              return requests.isEmpty
                  ? const _EmptyState(tab: NotificationTab.requests)
                  : ListView.builder(
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      return NotificationItem(
                        notification: requests[index],
                        onAction:
                            () => _handleAction(context, ref, requests[index]),
                      );
                    },
                  );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('Error: $error')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    WidgetRef ref,
    NotificationModel notification,
  ) async {
    // Same handling as in _AllNotificationsTab
    final userId = ref.read(userProvider).value?.id;
    if (userId == null) return;

    switch (notification.type) {
      case NotificationType.friendRequest:
        await FriendsService.acceptFriendRequest(userId, notification.senderId);
        ref.invalidate(userProvider);
        break;
      case NotificationType.chatInvitation:
        final room = await RoomService.getRoomById(
          notification.data['chatRoomId'],
        );
        if (room == null) {
          CustomToast.show(context, 'Sorry, this room does not exist.');
          return;
        }

        final user = ref.read(userProvider).value;
        if (user == null) return;

        final rooms = ref.read(roomsProvider).value ?? [];
        if (rooms.indexWhere((r) => r.id == room.id) == -1) {
          ref.read(roomsProvider.notifier).addRoom(room);
          await RoomParticipantsService.addParticipantToRoom(room.id, user.id);
        }

        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TemporaryChatRoomSection(room: room),
            ),
          );
        }
        break;
      default:
        break;
    }
  }
}

class _RepliesTab extends ConsumerWidget {
  const _RepliesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(notificationsProvider),
      child: notificationsAsync.when(
        data: (notifications) {
          final replies =
              notifications
                  .where((n) => n.type == NotificationType.reply)
                  .toList();

          return replies.isEmpty
              ? const _EmptyState(tab: NotificationTab.replies)
              : ListView.builder(
                itemCount: replies.length,
                itemBuilder: (context, index) {
                  return NotificationItem(
                    notification: replies[index],
                    onAction: () {}, // Handle reply action if needed
                  );
                },
              );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _MentionsTab extends ConsumerWidget {
  const _MentionsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(notificationsProvider),
      child: notificationsAsync.when(
        data: (notifications) {
          final mentions =
              notifications
                  .where((n) => n.type == NotificationType.mention)
                  .toList();

          return mentions.isEmpty
              ? const _EmptyState(tab: NotificationTab.mentions)
              : ListView.builder(
                itemCount: mentions.length,
                itemBuilder: (context, index) {
                  return NotificationItem(
                    notification: mentions[index],
                    onAction: () {}, // Handle mention action if needed
                  );
                },
              );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final NotificationTab tab;

  const _EmptyState({required this.tab});

  @override
  Widget build(BuildContext context) {
    final (emptyMessage, emptyIcon) = switch (tab) {
      NotificationTab.all => ("No notifications yet", TablerIcons.bell),
      NotificationTab.requests => (
        "No pending requests",
        TablerIcons.user_plus,
      ),
      NotificationTab.replies => ("No replies yet", TablerIcons.arrow_back_up),
      NotificationTab.mentions => ("No mentions yet", TablerIcons.at),
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(emptyIcon, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
