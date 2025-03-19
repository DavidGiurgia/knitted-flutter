import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zic_flutter/core/api/notifications.dart';
import 'package:zic_flutter/core/models/notification.dart';
import 'package:zic_flutter/core/providers/user_provider.dart';

class NotificationNotifier extends AsyncNotifier<List<NotificationModel>> {
  //late SocketService _socketService;

  @override
  Future<List<NotificationModel>> build() async {
    final userAsync = ref.watch(userProvider);
    //_socketService = SocketService(); // Inițializare serviciu socket
    //_socketService.connect(); // Conectare la socket

    // _socketService.onNotification((notification) {
    //   // Ascultare evenimente
    //   _addNotification(notification);
    // });

    return userAsync.when(
      data: (user) async {
        if (user == null) {
          return []; // Returnează o listă goală dacă userul nu este autentificat
        }

        try {
          return await NotificationService.fetchNotifications(user.id);
        } catch (e) {
          state = AsyncValue.error(e, StackTrace.current);
          return [];
        }
      },
      loading: () => Future.value([]),
      error: (error, stackTrace) => Future.value([]),
    );
  }

  // void _addNotification(NotificationModel notification) {
  //   state = AsyncValue.data([...state.value ?? [], notification]);
  // }

  // @override
  // void dispose() {
  //   _socketService.disconnect(); // Deconectare la dispose
  //   super.dispose();
  // }
}

final notificationsProvider =
    AsyncNotifierProvider<NotificationNotifier, List<NotificationModel>>(
      () => NotificationNotifier(),
    );
