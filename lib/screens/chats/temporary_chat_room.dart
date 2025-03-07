import 'package:flutter/material.dart';
import 'package:zic_flutter/core/models/chat_room.dart';
import 'package:zic_flutter/screens/chats/chat_room_body.dart';
import 'package:zic_flutter/widgets/chats/chat_header.dart';

class TemporaryChatRoomSection extends StatelessWidget {
  final Room room;

  const TemporaryChatRoomSection({super.key, required this.room});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        actionsPadding: const EdgeInsets.all(0),
        title: Row(children: [ChatHeader(room: room)]),
      ),
      body: ChatRoomBody(room: room),
    );
  }
}
