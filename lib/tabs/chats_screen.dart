import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import 'package:zic_flutter/core/api/room_participants.dart';
import 'package:zic_flutter/core/api/room_service.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/providers/rooms_provider.dart';
import 'package:zic_flutter/core/providers/user_provider.dart';
import 'package:zic_flutter/screens/chats/chat_rooms_list.dart';
import 'package:zic_flutter/screens/chats/chats_search_section.dart';
import 'package:zic_flutter/screens/chats/new_message_section.dart';
import 'package:zic_flutter/screens/chats/temporary_chat_room.dart';
import 'package:zic_flutter/screens/shared/custom_toast.dart';
import 'package:zic_flutter/widgets/join_room_input.dart';
import 'package:zic_flutter/widgets/search_input.dart';

class ChatsScreen extends ConsumerStatefulWidget {
  const ChatsScreen({super.key});

  @override
  ConsumerState<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends ConsumerState<ChatsScreen>
    with AutomaticKeepAliveClientMixin<ChatsScreen> {
  final TextEditingController _codeController = TextEditingController();

  bool _isCodeInputVisible = false;

  @override
  bool get wantKeepAlive => true; // Păstrează starea widgetului

  void _onJoin() async {
    final userAsync = ref.watch(userProvider);
    final user = userAsync.value;

    if (user == null) {
      return;
    }
    final roomsAsync = ref.watch(roomsProvider);

    if (roomsAsync.isLoading) {
      return;
    }

    if (roomsAsync.hasError) {
      return;
    }

    final rooms = roomsAsync.value ?? [];

    final code = _codeController.text.trim();
    if (code.isEmpty) return;

    final room = await RoomService.getRoomByCode(code);
    if (room == null) {
      CustomToast.show(
        context,
        'Sorry, there is no such room active right now!',
        // bgColor: Colors.red,
      );

      return;
    }

    if (!room.allowJoinCode) {
      CustomToast.show(
        context,
        'This room is not available for joining with a code.',
      );
      return;
    }

    // Verificăm dacă camera există deja în listă.
    final existingIndex = rooms.indexWhere((r) => r.id == room.id);
    if (existingIndex == -1) {
      ref.read(roomsProvider.notifier).addRoom(room);

      await RoomParticipantsService.addParticipantToRoom(room.id, user.id);
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


  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isCodeInputVisible = !_isCodeInputVisible;
              });
            },
            icon: Icon(TablerIcons.hash),
            color:
                _isCodeInputVisible
                    ? AppTheme.primaryColor
                    : null, // Schimbă culoarea
          ),
          IconButton(
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NewMessageSection(),
                  ),
                ),
            icon: const Icon(TablerIcons.message_plus),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(userProvider);
          ref.invalidate(roomsProvider);
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
