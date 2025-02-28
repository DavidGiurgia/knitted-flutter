import 'package:flutter/material.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/widgets/button.dart';
import 'package:zic_flutter/widgets/select_friends.dart';


class InviteFriendsSection extends StatefulWidget {
  const InviteFriendsSection({super.key});

  @override
  State<InviteFriendsSection> createState() => _InviteFriendsSectionState();
}

class _InviteFriendsSectionState extends State<InviteFriendsSection> {
  bool isLoading = false;
  final TextEditingController nameController = TextEditingController();
  final List<String> participants = [];

  void handleCreateRoom() async {
    setState(() => isLoading = true);
    try {
      // Logica pentru creare cameră
    } catch (error) {
      print("Error creating room: $error");
    }
    setState(() => isLoading = false);
  }

  void setSelectedFriends(List<String> selectedFriends) {
    setState(() {
      participants
        ..clear()
        ..addAll(selectedFriends);
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Quick chat"),
            Text(
              "Invite your friends",
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            
            // Indiciu pentru invitație
            Padding(
              padding: const EdgeInsets.all( 16),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue,
                    size: 23,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      "Invite your friends – they will receive an instant notification.",
                      style: TextStyle(
                        fontSize: 14,
                        color:
                            AppTheme.isDark(context)
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
             // Selectorul de prieteni
            SizedBox(
              height: MediaQuery.of(context).size.height , // Adjust as needed
              child: SelectFriends(setSelectedFriends: setSelectedFriends),
            ),
          ],
        ),
      ),
    );
  }
}