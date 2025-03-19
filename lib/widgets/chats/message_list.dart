import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:zic_flutter/core/models/message.dart';
import 'package:zic_flutter/core/models/user.dart';
import 'package:zic_flutter/widgets/chats/message_bubble.dart';
import 'package:zic_flutter/widgets/chats/avatar__for_message_bubble.dart';

class MessageList extends StatefulWidget {
  final List<Message> messages;
  final String currentUserId;
  final List<User> participants;

  const MessageList({
    super.key,
    required this.messages,
    required this.currentUserId,
    required this.participants,
  });

  @override
  State<MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void didUpdateWidget(covariant MessageList oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: widget.messages.length,
      itemBuilder: (context, index) {
        final message = widget.messages[index];
        final isCurrentUser = message.senderId == widget.currentUserId;
        final isGroup = widget.participants.length > 2;

        User? sender = widget.participants.firstWhereOrNull(
          (p) => p.id == message.senderId,
        );

        final isSameSenderAsPrevious =
            index > 0 &&
            widget.messages[index - 1].senderId == message.senderId;
        final showAvatar = isGroup && !isSameSenderAsPrevious && !isCurrentUser;

        return Container(
          padding: EdgeInsets.only(
            left: 8,
            right: 8,
            top: isSameSenderAsPrevious ? 2 : 10,
            bottom: 2,
          ),
          alignment:
              isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Row(
            mainAxisAlignment:
                isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AvatarWidget(
                avatarUrl: sender?.avatarUrl,
                fullName: sender?.fullname,
                showAvatar: showAvatar,
                shouldHaveSpace:
                    isSameSenderAsPrevious && isGroup && !isCurrentUser,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: MessageBubble(
                  message: message,
                  isCurrentUser: isCurrentUser,
                  isSameSenderAsPrevious: isSameSenderAsPrevious,
                  isGroup: isGroup,
                  senderName: sender?.fullname,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
