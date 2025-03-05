import 'package:flutter/material.dart';
import 'package:zic_flutter/core/models/chat_room.dart';
import 'package:zic_flutter/widgets/chat_header.dart';

class TemporaryChatRoom extends StatefulWidget {
  final Room room;

  const TemporaryChatRoom({super.key, required this.room});
  @override
  State<TemporaryChatRoom> createState() => _TemporaryChatRoomState();
}

class _TemporaryChatRoomState extends State<TemporaryChatRoom> {
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
