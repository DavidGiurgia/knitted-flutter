import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:provider/provider.dart';
import 'package:zic_flutter/core/api/room_service.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/providers/chat_rooms_provider.dart';
import 'package:zic_flutter/core/providers/friends_provider.dart';
import 'package:zic_flutter/core/providers/user_provider.dart';
import 'package:zic_flutter/screens/chats/chat_rooms_list.dart';
import 'package:zic_flutter/screens/chats/chats_search_section.dart';
import 'package:zic_flutter/screens/chats/new_chat_section.dart';
import 'package:zic_flutter/screens/chats/new_message_section.dart';
import 'package:zic_flutter/screens/chats/new_temporary_chat_section.dart';
import 'package:zic_flutter/screens/chats/temporary_chat_room.dart';
import 'package:zic_flutter/widgets/bottom_sheet.dart';
import 'package:zic_flutter/widgets/button.dart';
import 'package:zic_flutter/widgets/join_room_input.dart';
import 'package:zic_flutter/widgets/search_input.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen>
    with AutomaticKeepAliveClientMixin<ChatsScreen> {
  final TextEditingController _codeController = TextEditingController();

  bool _isCodeInputVisible = false;

  @override
  bool get wantKeepAlive => true; // Păstrează starea widgetului

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final roomsProvider = Provider.of<ChatRoomsProvider>(
        context,
        listen: false,
      );
      roomsProvider.loadRooms(context);
    });
  }

  void _onJoin() async {
    final roomsProvider = Provider.of<ChatRoomsProvider>(
      context,
      listen: false,
    );
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    final code = _codeController.text.trim();
    if (code.isEmpty) return;

    final room = await RoomService.getRoomByCode(code);
    if (room == null || userProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sorry, there is no such room active right now!'),
        ),
      );
      return;
    }

    // Verificăm dacă camera există deja în listă.
    final existingIndex = roomsProvider.rooms.indexWhere(
      (r) => r.id == room.id,
    );
    if (existingIndex == -1) {
      roomsProvider.addRoom(room);
    }

    // Curățăm input-ul după join.
    _codeController.clear();

    // Navighează către camera respectivă.
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TemporaryChatRoomSection(room: room),
      ),
    );
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return CustomBottomSheet(
          title: "Start a New Chat",
          options: [
            SheetOption(
              title: "Temporary Room",
              subtitle:
                  "Start a short-lived chat with no saved messages and anonymous participation.",
              icon: HeroIcons.hashtag,
              iconColor: AppTheme.foregroundColor(context),
              iconStyle: HeroIconStyle.micro,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NewTemporaryChatSection(),
                  ),
                );
              },
            ),
            SheetOption(
              title: "Group chat",
              subtitle: "Create a group chat with your friends.",
              icon: HeroIcons.users,
              iconColor: AppTheme.foregroundColor(context),
              iconStyle: HeroIconStyle.micro,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NewChatSection(),
                  ),
                );
              },
            ),
            SheetOption(
              title: "New message",
              subtitle: "Stay connected with your friends.",
              icon: HeroIcons.chatBubbleLeftRight,
              iconColor: AppTheme.foregroundColor(context),
              iconStyle: HeroIconStyle.solid,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NewMessageSection(),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Chats'),
        actions: [
          CustomButton(
            onPressed: () {
              setState(() {
                _isCodeInputVisible = !_isCodeInputVisible;
              });
            },
            isIconOnly: true,
            heroIcon: HeroIcons.hashtag,
            iconStyle: HeroIconStyle.micro,
            type: ButtonType.light,
            size: ButtonSize.large,
            bgColor:
                _isCodeInputVisible
                    ? AppTheme.primaryColor
                    : null, // Schimbă culoarea
          ),
          CustomButton(
            onPressed: () => _showBottomSheet(context),
            isIconOnly: true,
            heroIcon: HeroIcons.pencilSquare,
            iconStyle: HeroIconStyle.mini,
            type: ButtonType.light,
            size: ButtonSize.large,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh:
            () async => {
              Provider.of<ChatRoomsProvider>(
                context,
                listen: false,
              ).loadRooms(context),
              Provider.of<FriendsProvider>(
                context,
                listen: false,
              ).loadFriends(context),
            },
        child: CustomScrollView(
          slivers: [
            if (_isCodeInputVisible) // Afișează input-ul doar dacă este vizibil
              SliverToBoxAdapter(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 24,
                  ),
                  color: AppTheme.primaryColor,
                  child: JoinTemporaryRoomInput(
                    controller: _codeController,
                    onJoin: _onJoin,
                  ),
                ),
              ),
            SliverFillRemaining(
              child: Column(
                children: [
                  SearchInput(
                    readOnly: true,
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ChatsSearchSection(),
                          ),
                        ),
                  ),
                  Expanded(child: const ChatRoomsList()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
