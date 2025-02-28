import 'package:flutter/material.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/widgets/join_group_input.dart';

class TemporaryChatsSection extends StatefulWidget {
  const TemporaryChatsSection({super.key});

  @override
  State<TemporaryChatsSection> createState() => _TemporaryChatsSectionState();
}

class _TemporaryChatsSectionState extends State<TemporaryChatsSection> {
  @override
  Widget build(BuildContext context) {
    final TextEditingController _codeController = TextEditingController();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      color: AppTheme.primaryColor,
      child: Column(
        children: [
          // Text(
          //   "Joining a private chat?",
          //   style: TextStyle(
          //     fontSize: 28,
          //     fontWeight: FontWeight.w700,
          //     color: AppTheme.backgroundColor(context),
          //   ),
          // ),
          // const SizedBox(height: 8),

          // const SizedBox(height: 20),
          JoinGroupInput(controller: _codeController, onJoin: () {}),
          SizedBox(height: 8),
          // Container(
          //   height: 60,
          //   decoration: BoxDecoration(
          //     //
          //   ),
          // ),
        ],
      ),
    );
  }
}
