import 'package:flutter/material.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/screens/chats/invite_friends_section.dart';
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
  int chatDuration = 1; // Default: 1 day
  bool acceptedTerms = false;
  final TextEditingController topicController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  void goToNextStep() {
    if (!acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("You must accept the terms to continue."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => InviteFriendsSection()),
    );
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
              "Set your prefferences ",
              style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: CustomButton(
              onPressed: goToNextStep,
              text: "Next",
              bgColor: AppTheme.primaryColor,
              size: ButtonSize.small,
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
                        : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Private & Secure",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.foregroundColor(context),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "This is a temporary encrypted chat. Messages are not saved, "
                    "you can send anonymous messages, and users without an account "
                    "can join using a generated code.",
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
                  "Users without an account can join via a unique generated code.",
            ),
            const SizedBox(height: 12),

            // Chat duration
            Text(
              "Chat Duration",
              style: TextStyle(fontWeight: FontWeight.bold),
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
            ),
            Text(
              "The chat will automatically expire after the selected duration.",
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),

            // Topic & Description
            TextField(
              controller: topicController,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                label: Text("Chat Topic"),
                hintText: "Give your chat a name...",
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                label: Text("Description (Optional)"),
                hintText: "Briefly describe the purpose of this chat...",
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Accept terms
            Row(
              children: [
                Checkbox(
                  value: acceptedTerms,
                  onChanged: (value) => setState(() => acceptedTerms = value!),
                  activeColor: AppTheme.primaryColor,
                ),
                Expanded(
                  child: Text(
                    "I accept the Terms & Conditions.",
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
