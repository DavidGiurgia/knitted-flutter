import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
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

  void _showPopupMenu(BuildContext context) {   ///////se poate simplifica cu un bottom sheet                      !!!!!!! 
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    final List<PopupMenuEntry<String>> menuItems = [];

    if (widget.isCurrentUser) {
      menuItems.addAll([
        const PopupMenuItem(
          value: 'details',
          child: Row(
            children: [
              HeroIcon(HeroIcons.informationCircle, size: 16, color: Colors.grey), // Iconiță pentru Reply
              SizedBox(width: 8),
              Text('Details'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'reply',
          child: Row(
            children: [
              HeroIcon(HeroIcons.arrowUturnLeft, size: 16, color: Colors.grey), // Iconiță pentru Reply
              SizedBox(width: 8),
              Text('Reply'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              HeroIcon(HeroIcons.pencil, size: 16, color: Colors.grey), // Iconiță pentru Edit
              SizedBox(width: 8),
              Text('Edit'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'unsend',
          child: Row(
            children: [
              HeroIcon(HeroIcons.trash, size: 16, color: Colors.grey), // Iconiță pentru Unsend
              SizedBox(width: 8),
              Text('Unsend'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'copy',
          child: Row(
            children: [
              HeroIcon(HeroIcons.documentDuplicate, size: 16, color: Colors.grey), // Iconiță pentru Copy
              SizedBox(width: 8),
              Text('Copy'),
            ],
          ),
        ),
      ]);
    } else {
      menuItems.addAll([
        const PopupMenuItem(
          value: 'details',
          child: Row(
            children: [
              HeroIcon(HeroIcons.informationCircle, size: 16, color: Colors.grey), // Iconiță pentru Reply
              SizedBox(width: 8),
              Text('Details'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'reply',
          child: Row(
            children: [
              HeroIcon(HeroIcons.arrowUturnLeft, size: 16, color: Colors.grey),
              SizedBox(width: 8),
              Text('Reply'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'copy',
          child: Row(
            children: [
              HeroIcon(HeroIcons.documentDuplicate, size: 16, color: Colors.grey),
              SizedBox(width: 8),
              Text('Copy'),
            ],
          ),
        ),
      ]);
    }

    showMenu(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromPoints(
          offset,
          offset + size.bottomRight(Offset.zero),
        ),
        Offset.zero & MediaQuery.of(context).size,
      ),
      shape: RoundedRectangleBorder( // Stilizează popup-ul
        borderRadius: BorderRadius.circular(12),
      ),
      color: AppTheme.isDark(context) ? AppTheme.grey800 : Colors.white, // Fundalul popup-ului
      items: menuItems,
    ).then((value) {
      if (value != null) {
        // Handle the selected menu item
        switch (value) {
          case 'details':
            // Implement details functionality
          case 'reply':
            // Implement reply functionality
            break;
          case 'edit':
            // Implement edit functionality
            break;
          case 'unsend':
            // Implement unsend functionality
            break;
          case 'copy':
            // Implement copy functionality
            break;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleTimestamp,
      onLongPress: () => _showPopupMenu(context), // Show popup menu on long press
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
              color: widget.isCurrentUser
                  ? AppTheme.primaryColor.withValues(alpha: 0.08)
                  : AppTheme.isDark(context)
                      ? AppTheme.grey800
                      : AppTheme.grey100,
              borderRadius: BorderRadius.only(
                topLeft: !widget.isCurrentUser && !widget.isSameSenderAsPrevious
                    ? const Radius.circular(0)
                    : const Radius.circular(12),
                topRight: widget.isCurrentUser && !widget.isSameSenderAsPrevious
                    ? const Radius.circular(0)
                    : const Radius.circular(12),
                bottomLeft: const Radius.circular(12),
                bottomRight: const Radius.circular(12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(widget.message.content, style: const TextStyle(fontSize: 16)),
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
          ),
        ],
      ),
    );
  }
}

