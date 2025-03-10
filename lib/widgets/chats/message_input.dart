import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:zic_flutter/core/app_theme.dart';

class MessageInput extends StatefulWidget {
  final VoidCallback _sendMessage;
  final TextEditingController _messageController;
  final FocusNode? _textFieldFocus;
  final Function(String) onChanged;
  final VoidCallback onImagePressed;

  const MessageInput({
    super.key,
    required VoidCallback sendMessage,
    required TextEditingController messageController,
    FocusNode? textFieldFocus,
    required this.onChanged,
    required this.onImagePressed,
  }) : _sendMessage = sendMessage,
        _messageController = messageController,
        _textFieldFocus = textFieldFocus;

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.isDark(context)
              ? AppTheme.grey800
              : AppTheme.grey100,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  maxLines: null,
                  focusNode: widget._textFieldFocus,
                  controller: widget._messageController,
                  onChanged: widget.onChanged,
                  decoration: InputDecoration(
                    hintText: "Message",
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            if (widget._messageController.text.isNotEmpty)
              IconButton(
                icon: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(6),
                  child: HeroIcon(
                    HeroIcons.paperAirplane,
                    color: AppTheme.backgroundColor(context),
                    style: HeroIconStyle.micro,
                  ),
                ),
                onPressed: widget._sendMessage,
              ),
            if (widget._messageController.text.isEmpty)
              IconButton(
                icon: Container(
                  decoration: BoxDecoration(
                    //color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(6),
                  child: HeroIcon(
                    HeroIcons.photo,
                    color: AppTheme.primaryColor,
                    style: HeroIconStyle.micro,
                  ),
                ),
                onPressed: widget.onImagePressed,
              ),
          ],
        ),
      ),
    );
  }
}