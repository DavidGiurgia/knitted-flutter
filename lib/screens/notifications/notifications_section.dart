import 'package:flutter/material.dart';

class NotificationsSection extends StatefulWidget {
  const NotificationsSection({super.key});

  @override
  State<NotificationsSection> createState() => _NotificationsSectionState();
}

class _NotificationsSectionState extends State<NotificationsSection> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Notifications"),),
    );
  }
}