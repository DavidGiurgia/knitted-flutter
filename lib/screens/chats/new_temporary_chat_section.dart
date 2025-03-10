import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zic_flutter/core/api/room_service.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/providers/chat_rooms_provider.dart';
import 'package:zic_flutter/core/providers/user_provider.dart';
import 'package:zic_flutter/screens/chats/invite_friends_section.dart';
import 'package:zic_flutter/screens/shared/custom_toast.dart';
import 'package:zic_flutter/utils/utils.dart';
import 'package:zic_flutter/widgets/button.dart';
import 'package:zic_flutter/widgets/switch.dart';

class NewTemporaryChatSection extends StatefulWidget {
  const NewTemporaryChatSection({super.key});

  @override
  State<NewTemporaryChatSection> createState() =>
      _NewTemporaryChatSectionState();
}

class _NewTemporaryChatSectionState extends State<NewTemporaryChatSection> {
  bool allowJoinCode = true;
  int chatDuration = 3; // Default: 3 days
  final TextEditingController topicController = TextEditingController(
    text: "",
  ); // add default

  bool isLoading = false;

  Future<void> goToNextStep() async {
    if (topicController.text.isEmpty) {
      CustomToast.show(
        context,
        "You must provide a topic to continue",
        color: Colors.red,
      );
      return;
    }

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (userProvider.user == null) {
      CustomToast.show(
        context,
        "User not found. Please log in again.",
        color: Colors.red,
      );
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      final String joinCode = await generateUniqueJoinCode();
      final DateTime expiresAt = DateTime.now().add(
        Duration(days: chatDuration),
      );

      if (userProvider.user == null) {
        CustomToast.show(context, "User not found. Please log in again!");
        return;
      }

      final creatorId = userProvider.user!.id;

      // Creare camera
      final room = await RoomService.createTemporaryRoom(
        creatorId,
        topicController.text,
        expiresAt,
        joinCode,
        allowJoinCode,
      );

      if (room != null && userProvider.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => InviteFriendsSection(room: room),
          ),
        );
        Provider.of<ChatRoomsProvider>(
          context,
          listen: false,
        ).loadRooms(context);
      } else {
        CustomToast.show(context, "Failed to create temporary room.");
      }
    } catch (e) {
      CustomToast.show(
        context,
        "An error occurred while creating the temporary room. Please try again. $e",
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Temporary chat"),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: CustomButton(
              onPressed: goToNextStep,
              text: "Create",
              bgColor: AppTheme.primaryColor,
              size: ButtonSize.small,
              isLoading: isLoading,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Element informativ
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    AppTheme.isDark(context)
                        ? Colors.grey.shade900
                        : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Private & Secure",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "This chat is temporary and encrypted. Messages won’t be saved, you can send messages anonymously, and even users without an account can join via a unique code.",
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          AppTheme.isDark(context)
                              ? Colors.grey.shade400
                              : Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Allow join code
            CustomSwitchTile(
              title: "Allow Join Code",
              value: allowJoinCode,
              activeColor: AppTheme.primaryColor,
              onChanged: (value) => setState(() => allowJoinCode = value),
              description:
                  allowJoinCode
                      ? "Anyone with the invite link or code can join the chat."
                      : "Only the friends you invite will be able to join.",
            ),
            const SizedBox(height: 20),

            // Chat duration
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    AppTheme.isDark(context)
                        ? Colors.grey.shade900
                        : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Chat Duration",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  Slider(
                    value: chatDuration.toDouble(),
                    min: 1,
                    max: 7,
                    divisions: 6,
                    label: "$chatDuration days",
                    onChanged:
                        (value) => setState(() => chatDuration = value.toInt()),
                    activeColor: AppTheme.primaryColor,
                    inactiveColor: Colors.transparent,
                  ),
                  Text(
                    "This chat will expire in $chatDuration days. You can adjust the duration later if needed.",
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Topic & Description
            TextField(
              controller: topicController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                label: Text("Chat Topic"),
                hintText: "Give your chat a topic...",
              ),
              maxLines: null,
              maxLength: 100,
            ),

            const SizedBox(height: 20),

            // // Accept terms
            // Row(
            //   children: [
            //     Checkbox(
            //       value: acceptedTerms,
            //       onChanged: (value) => setState(() => acceptedTerms = value!),
            //       activeColor: AppTheme.primaryColor,
            //     ),
            //     Expanded(
            //       child: Text(
            //         "I have read and agree to the Terms & Conditions.",
            //         style: TextStyle(fontSize: 14),
            //       ),
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }
}
