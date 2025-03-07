import 'package:flutter/material.dart';
import 'package:flutter_advanced_avatar/flutter_advanced_avatar.dart';
import 'package:zic_flutter/core/models/message.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:zic_flutter/core/models/user.dart';

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

  String _formatTime(DateTime dateTime) {
    return DateFormat.Hm().format(dateTime);
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

        User? sender;
        try {
          sender = widget.participants.firstWhere(
            (p) => p.id == message.senderId,
          );
        } catch (e) {
          print("Sender not found for message: ${message.senderId}");
          sender = null; // Set sender to null if not found
        }
        final isSameSenderAsPrevious =
            index > 0 &&
            widget.messages[index - 1].senderId == message.senderId;
        final showAvatar = isGroup && !isSameSenderAsPrevious && !isCurrentUser;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          alignment:
              isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Row(
            mainAxisAlignment:
                isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showAvatar && sender != null)
                AdvancedAvatar(
                  size: 32,
                  image: NetworkImage(sender.avatarUrl),
                  autoTextSize: true,
                  name: sender.fullname,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color:
                        AppTheme.isDark(context)
                            ? AppTheme.grey200
                            : AppTheme.grey800,
                  ),
                  decoration: BoxDecoration(
                    color:
                        AppTheme.isDark(context)
                            ? AppTheme.grey800
                            : AppTheme.grey200,
                    shape: BoxShape.circle,
                  ),
                ),
              if (!showAvatar && !isCurrentUser && isGroup)
                const SizedBox(width: 32),
              const SizedBox(width: 8),
              Flexible(
                child: IntrinsicWidth(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.8,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isCurrentUser
                              ? AppTheme.primaryColor.withValues(alpha: 0.04)
                              : AppTheme.isDark(context)
                              ? AppTheme.grey800
                              : AppTheme.grey100,
                      borderRadius: BorderRadius.only(
                        topLeft:
                            !isCurrentUser && !isSameSenderAsPrevious
                                ? const Radius.circular(0)
                                : const Radius.circular(16),
                        topRight:
                            isCurrentUser && !isSameSenderAsPrevious
                                ? const Radius.circular(0)
                                : const Radius.circular(16),
                        bottomLeft: const Radius.circular(16),
                        bottomRight: const Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isSameSenderAsPrevious &&
                            !isCurrentUser &&
                            isGroup)
                          Text(
                            sender!.fullname,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        Text(message.content),
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            _formatTime(message.createdAt),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
