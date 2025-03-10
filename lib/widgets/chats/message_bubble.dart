import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zic_flutter/core/models/message.dart';
import 'package:zic_flutter/core/app_theme.dart';

class MessageBubble extends StatefulWidget {
  final Message message;
  final bool isCurrentUser;
  final bool isSameSenderAsPrevious;
  final bool isGroup;
  final String? senderName;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
    required this.isSameSenderAsPrevious,
    required this.isGroup,
    this.senderName,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  bool _showTimestamp = false;

  void _toggleTimestamp() {
    setState(() {
      _showTimestamp = !_showTimestamp;
    });

    if (_showTimestamp) {
      Future.delayed(const Duration(seconds: 15), () {
        if (mounted) {
          setState(() {
            _showTimestamp = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleTimestamp,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!widget.isSameSenderAsPrevious &&
              !widget.isCurrentUser &&
              widget.isGroup &&
              widget.senderName != null)
            Text(
              widget.senderName!,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          Container(
            margin: EdgeInsets.only(
              left: widget.isCurrentUser ? 30 : 0,
              right: widget.isCurrentUser ? 0 : 30,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color:
                  widget.isCurrentUser
                      ? AppTheme.primaryColor.withValues(alpha: 0.08)
                      : AppTheme.isDark(context)
                      ? AppTheme.grey800
                      : AppTheme.grey100,
              borderRadius: BorderRadius.only(
                topLeft:
                    !widget.isCurrentUser && !widget.isSameSenderAsPrevious
                        ? const Radius.circular(0)
                        : const Radius.circular(12),
                topRight:
                    widget.isCurrentUser && !widget.isSameSenderAsPrevious
                        ? const Radius.circular(0)
                        : const Radius.circular(12),
                bottomLeft: const Radius.circular(12),
                bottomRight: const Radius.circular(12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(widget.message.content, style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
          Visibility(
            visible: _showTimestamp,
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                DateFormat.Hm().format(widget.message.createdAt),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
