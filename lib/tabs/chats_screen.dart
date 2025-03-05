import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:provider/provider.dart';
import 'package:zic_flutter/core/api/room_participants.dart';
import 'package:zic_flutter/core/api/room_service.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/models/chat_room.dart';
import 'package:zic_flutter/core/providers/user_provider.dart';
import 'package:zic_flutter/screens/chats/chats_section.dart';
import 'package:zic_flutter/screens/chats/new_chat_section.dart';
import 'package:zic_flutter/screens/chats/new_message_section.dart';
import 'package:zic_flutter/screens/chats/new_temporary_chat_section.dart';
import 'package:zic_flutter/screens/chats/temporary_chat_room.dart';
import 'package:zic_flutter/widgets/bottom_sheet.dart';
import 'package:zic_flutter/widgets/button.dart';
import 'package:zic_flutter/widgets/join_room_input.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  List<Room> rooms = [];
  bool _isCodeInputVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRooms();
    });
  }

  Future<void> _loadRooms() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;

    if (user == null) {
      print("User is null - skipping room loading");
      return;
    }
    try {
      final roomParticipants = await RoomParticipantsService.findByUserId(
        user.id,
      );
      List<Room> loadedRooms = [];
      for (var participant in roomParticipants) {
        final room = await RoomService.getRoomById(participant.roomId);
        if (room != null) {
          loadedRooms.add(room);
        }
      }
      if (mounted) {
        setState(() {
          rooms = loadedRooms;
        });
      }
    } catch (e) {
      print("Error loading rooms: $e");
    }
  }

  void _onJoin() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      return;
    }
    Room? temporaryRoom = await RoomService.getRoomByCode(code);
    if (temporaryRoom == null || userProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sorry, there is no such room active right now!'),
        ),
      );
      return;
    }
    if (!rooms.any((room) => room.id == temporaryRoom.id) &&
        userProvider.user != null) {
      final success = await RoomParticipantsService.create(
        userProvider.user!.id,
        temporaryRoom.id,
      );
      if (success != null) {
        setState(() {
          rooms.add(temporaryRoom);
        });
      }
    }
    _codeController.clear();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TemporaryChatRoom(room: temporaryRoom),
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
        onRefresh: _loadRooms,
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
              child: ChatsSection(
                rooms: rooms,
                searchController: _searchController,
                onSearchChanged: (query) {},
                onCreatePressed: () => _showBottomSheet(context),
                onJoinPressed: () {
                  setState(() {
                    _isCodeInputVisible = true;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
