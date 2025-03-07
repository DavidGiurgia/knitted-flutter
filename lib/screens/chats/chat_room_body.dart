import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:zic_flutter/core/models/chat_room.dart';
import 'package:zic_flutter/core/models/message.dart';
import 'package:zic_flutter/core/models/user.dart';
import 'package:zic_flutter/core/providers/chat_rooms_provider.dart';
import 'package:zic_flutter/core/providers/user_provider.dart';
import 'package:zic_flutter/core/services/socket_service.dart';
import 'package:zic_flutter/widgets/chats/message_input.dart';
import 'package:zic_flutter/widgets/chats/message_list.dart';

class ChatRoomBody extends StatefulWidget {
  final Room room;

  const ChatRoomBody({super.key, required this.room});

  @override
  State<ChatRoomBody> createState() => _ChatRoomBodyState();
}

class _ChatRoomBodyState extends State<ChatRoomBody> {
  final SocketService socketService = SocketService();
  List<Message> messages = [];
  final TextEditingController messageController = TextEditingController();
  String baseUrl = dotenv.env['BASE_URL'] ?? '';
  bool isConnected = false;
  bool showEmojiPicker = false;
  final _scrollController = ScrollController();
  final FocusNode _textFieldFocus = FocusNode();
  late User currentUser;
  late ChatRoomsProvider chatRoomsProvider;
  bool _messagesLoaded = false;

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    chatRoomsProvider = Provider.of<ChatRoomsProvider>(context, listen: false);
    currentUser = userProvider.user!;

    _loadMessages();

    if (!isConnected) {
      socketService.connect(baseUrl);
      socketService.joinRoom(widget.room.id);
      socketService.onMessageReceived = (message) {
        setState(() {
          messages.add(message);
        });
      };
      isConnected = true;
    }
  }

  Future<void> _loadMessages() async {
    await chatRoomsProvider.loadRoomMessages(widget.room.id);
    setState(() {
      messages = chatRoomsProvider.roomMessages[widget.room.id] ?? [];
      _messagesLoaded = true; // Setăm variabila la true după încărcare
    });
  }

  @override
  void dispose() {
    socketService.leaveRoom(widget.room.id);
    socketService.disconnect();
    _scrollController.dispose();
    messageController.dispose();
    _textFieldFocus.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUser = userProvider.user;

    if (currentUser != null && messageController.text.isNotEmpty) {
      final message = {
        'roomId': widget.room.id,
        'senderId': currentUser.id,
        'senderName': currentUser.fullname,
        'content': messageController.text,
        'isAnonymous': false,
      };

      socketService.sendMessage(message);
      messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (showEmojiPicker) {
          setState(() {
            showEmojiPicker = false;
          });
          return false;
        }
        return true;
      },
      child: Column(
        children: [
          Expanded(
            child:
                _messagesLoaded // Verificăm dacă mesajele sunt încărcate
                    ? MessageList(
                      messages: messages,
                      currentUserId: currentUser.id,
                      participants:
                          chatRoomsProvider.roomParticipants[widget.room.id] ??
                          [],
                    )
                    : const Center(child: CircularProgressIndicator()),
          ),
          MessageInput(
            sendMessage: _sendMessage,
            messageController: messageController,
            textFieldFocus: _textFieldFocus,
            onChanged: (text) {
              setState(() {}); // Reconstruiește widget-ul părinte
            },
            onImagePressed: () {},
          ),
        ],
      ),
    );
  }
}
