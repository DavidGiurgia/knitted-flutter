import 'package:flutter/material.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/widgets/button.dart';
import 'package:zic_flutter/widgets/select_friends.dart';

class NewChatSection extends StatefulWidget {
  const NewChatSection({super.key});

  @override
  State<NewChatSection> createState() => _NewChatSectionState();
}

class _NewChatSectionState extends State<NewChatSection> {
  bool isLoading = false;
  
  final List<String> participants = [];

  void handleCreateRoom() async {
    if (participants.isEmpty) {
      print("No participants selected");
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Add logic to create a room using the `nameController.text` and `participants`
      // For example:
      // final room = await createRoom(nameController.text, participants);

      // After successfully creating a room, you can navigate to the chat room
      // Navigator.pushNamed(context, '/chatRoom', arguments: room);
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
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("New chat"),
            Text(
              "Add participants",
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: CustomButton(
                onPressed: handleCreateRoom,
                text: "Chat",
                isLoading: isLoading,
                bgColor: AppTheme.primaryColor,
                size: ButtonSize.small,
              ),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0),
        child: Column(
          children: [
            

            //const SizedBox(height: 20),
            Expanded(
              child: SelectFriends(setSelectedFriends: setSelectedFriends),
            ),

            // Padding(
            //   padding: const EdgeInsets.all(12),
            //   child: CustomButton(
            //     onPressed: handleCreateRoom,
            //     isFullWidth: true,
            //     text: "Chat",
            //     isLoading: isLoading,
            //     bgColor: AppTheme.primaryColor,
            //     size: ButtonSize.small,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
