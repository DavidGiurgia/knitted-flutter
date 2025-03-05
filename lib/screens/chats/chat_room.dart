import 'package:flutter/material.dart';
import 'package:zic_flutter/core/models/chat_room.dart';
import 'package:zic_flutter/widgets/chat_header.dart';

class ChatRoomSection extends StatefulWidget {
  final Room room;

  const ChatRoomSection({super.key, required this.room});

  @override
  State<ChatRoomSection> createState() => _ChatRoomSectionState();
}

class _ChatRoomSectionState extends State<ChatRoomSection> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actionsPadding: EdgeInsets.all(0),
        title: Row(children: [ChatHeader(room: widget.room)]),
      ),
    );
  }
}
