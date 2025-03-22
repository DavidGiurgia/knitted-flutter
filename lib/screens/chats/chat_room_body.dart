import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:zic_flutter/core/api/message_service.dart';
import 'package:zic_flutter/core/api/room_service.dart';
import 'package:zic_flutter/core/models/chat_room.dart';
import 'package:zic_flutter/core/models/message.dart';
import 'package:zic_flutter/core/models/user.dart';
import 'package:zic_flutter/core/providers/rooms_provider.dart';
import 'package:zic_flutter/core/providers/user_provider.dart';
import 'package:zic_flutter/core/services/chat_socket_service.dart';
import 'package:zic_flutter/widgets/chats/message_input.dart';
import 'package:zic_flutter/widgets/chats/message_list.dart';

class ChatRoomBody extends ConsumerStatefulWidget {
  final Room room;

  const ChatRoomBody({super.key, required this.room});

  @override
  ConsumerState<ChatRoomBody> createState() => _ChatRoomBodyState();
}

class _ChatRoomBodyState extends ConsumerState<ChatRoomBody> {
  late ChatSocketService _socketService;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Message> _messages = [];
  bool _messagesLoaded = false;
  late Future<List<User>> _participantsFuture;

  @override
  void initState() {
    super.initState();
    _socketService = ChatSocketService();
    _participantsFuture = ref
        .read(roomsProvider.notifier)
        .getRoomParticipants(widget.room.id);
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    await _loadMessages();
    _socketService.joinRoom(widget.room.id);
    _socketService.onMessageReceived = _handleNewMessage;
  }

  Future<void> _loadMessages() async {
    try {
      final messages = await MessageService.getMessagesForRoom(widget.room.id);
      setState(() {
        _messages = messages;
        _messagesLoaded = true;
      });
      _markMessagesAsRead();
    } catch (e) {
      print("Error loading messages: $e");
    }
  }

  void _handleNewMessage(Message message) {
    setState(() {
      _messages.add(message);
    });
    _markMessagesAsRead();
  }

  Future<void> _sendMessage() async {
    final currentUser = ref.read(userProvider).value;
    if (currentUser == null || _messageController.text.isEmpty) return;

    if (!widget.room.isActive) {
      await RoomService.activateRoom(widget.room.id);
      ref.invalidate(roomsProvider);
    }

    final message = {
      'roomId': widget.room.id,
      'senderId': currentUser.id,
      'senderName': currentUser.fullname,
      'content': _messageController.text,
      'isAnonymous': false,
    };

    _socketService.sendMessage(message);
    _messageController.clear();
  }

  void _markMessagesAsRead() {
    final currentUser = ref.read(userProvider).value;
    if (currentUser == null) return;

    print("messages: ${_messages.length};");

    final unreadMessages = _messages
      .where((m) => !m.readBy.contains(currentUser.id) && m.senderId != currentUser.id)
      .toList();

    for (final message in unreadMessages) {
      _socketService.markMessageAsRead(
        message.id,
        widget.room.id,
        currentUser.id,
      );
    }
    ref.invalidate(roomsProvider);
  }

  @override
  void dispose() {
    _socketService.leaveRoom(widget.room.id);
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(userProvider).value;
    if (currentUser == null) return const SizedBox.shrink();

    return Column(
      children: [
        Expanded(
          child:
              _messagesLoaded
                  ? FutureBuilder<List<User>>(
                    future: _participantsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text('No participants found'),
                        );
                      } else {
                        final participants = snapshot.data!;
                        return MessageList(
                          messages: _messages,
                          currentUserId: currentUser.id,
                          participants: participants,
                        );
                      }
                    },
                  )
                  : const Center(child: CircularProgressIndicator()),
        ),
        MessageInput(
          sendMessage: _sendMessage,
          messageController: _messageController,
          onChanged: (text) {
            setState(() {}); // Reconstruiește widget-ul părinte
          },
          onImagePressed: () {},
        ),
      ],
    );
  }
}
