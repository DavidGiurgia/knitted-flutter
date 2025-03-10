import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zic_flutter/core/api/room_participants.dart';
import 'package:zic_flutter/core/api/room_service.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/models/chat_room.dart';
import 'package:zic_flutter/core/providers/chat_rooms_provider.dart';
import 'package:zic_flutter/core/providers/user_provider.dart';
import 'package:zic_flutter/screens/chats/chat_room.dart';
import 'package:zic_flutter/widgets/button.dart';
import 'package:zic_flutter/widgets/select_friends.dart';

class NewGroupChatSection extends StatefulWidget {
  const NewGroupChatSection({super.key});

  @override
  State<NewGroupChatSection> createState() => _NewGroupChatSectionState();
}

class _NewGroupChatSectionState extends State<NewGroupChatSection> {
  bool isLoading = false;
  final List<String> participants = [];
  final TextEditingController nameController = TextEditingController();

  void handleCreateRoom() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUser = userProvider.user;
    if (currentUser == null) {
      return;
    }
    if (participants.isEmpty) {
      print("No participants selected");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {

      final topic = nameController.text.isNotEmpty ? nameController.text : '';

      // Creare camera
      final room = await RoomService.createGroupRoom(currentUser.id, topic);
      if (room == null) {
        print("Failed to create room");
        setState(() {
          isLoading = false;
        });
        return;
      }

      // Adaugare participanti
      final success = await RoomParticipantsService.addParticipantsToRoom(
        room.id,
        participants,
      );
      if (!success) {
        print("Failed to add participants");
        setState(() {
          isLoading = false;
        });
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ChatRoomSection(room: room)),
      );

      Provider.of<ChatRoomsProvider>(context, listen: false).loadRooms(context);
    } catch (error) {
      print("Error creating room: $error");
    }

    setState(() {
      isLoading = false;
    });
  }

  void setSelectedFriends(List<String> selectedFriends) {
    setState(() {
      participants.clear();
      participants.addAll(selectedFriends);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("New group"),
            Text(
              "Add participants",
              style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: CustomButton(
              onPressed: handleCreateRoom,
              text: "Create",
              isLoading: isLoading,
              bgColor: AppTheme.primaryColor,
              size: ButtonSize.small,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Condiție pentru afișarea input-ului
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: nameController,
              maxLength: 100,
              decoration: const InputDecoration(
                hintText: "Group name (optional)",
                hintStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
              ),
            ),
          ),
          Expanded(
            child: SelectFriends(setSelectedFriends: setSelectedFriends),
          ),
        ],
      ),
    );
  }
}
