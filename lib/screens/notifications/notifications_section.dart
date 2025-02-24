import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zic_flutter/core/api/notifications.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/providers/user_provider.dart';
import 'package:zic_flutter/widgets/notifincations/notification.dart';

class NotificationsSection extends StatefulWidget {
  const NotificationsSection({super.key});

  @override
  _NotificationsSectionState createState() => _NotificationsSectionState();
}

class _NotificationsSectionState extends State<NotificationsSection> {
  List<dynamic> notifications = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    setState(() => isLoading = true);
    try {
      List<dynamic> fetchedNotifications =
          await NotificationService.fetchNotifications(userProvider.user!.id);
      setState(() => notifications = fetchedNotifications);
    } catch (e) {
      print("Error fetching notifications: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _handleNotificationAction(Map<String, dynamic> notification) {
    print("Action clicked for ${notification['type']}");
    // Poți implementa acțiuni specifice pentru fiecare notificare (Accept, Join, etc.)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor(context),
      appBar: AppBar(
        title: Text("Notifications"),
        backgroundColor: AppTheme.backgroundColor(context),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchNotifications,
        child:
            isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return NotificationItem(
                      notification: notification,
                      onAction: () => _handleNotificationAction(notification),
                    );
                  },
                ),
      ),
    );
  }
}
