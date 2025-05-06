import 'package:flutter/material.dart';
import 'package:zic_flutter/core/api/room_service.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/screens/chats/temporary_chat_room.dart';
import 'package:zic_flutter/screens/shared/custom_toast.dart';
import 'package:zic_flutter/widgets/button.dart';

class JoinRoomScreen extends StatefulWidget {
  const JoinRoomScreen({super.key});

  @override
  State<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;

  void _joinGroup() async {
    setState(() => _isLoading = true);

    final code = _codeController.text.trim();
    if (code.length != 7) {
      CustomToast.show(
        context,
        "Code must be exactly 7 characters",
        color: Colors.red,
      );
      setState(() => _isLoading = false);
      return;
    }

    try {
      final room = await RoomService.getRoomByCode(code);

      if (room == null) {
        CustomToast.show(
          context,
          "No active room found with this code",
          color: Colors.red,
        );
        return;
      }

      _codeController.clear();

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TemporaryChatRoomSection(room: room),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = AppTheme.isDark(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: theme.colorScheme.onSurface.withOpacity(0.7),
            size: 28,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Join a private chat",
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Enter the 7-digit code to join an existing room",
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(
                              0.7,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        Container(
                          decoration: BoxDecoration(
                            color:
                                isDark
                                    ? theme.colorScheme.surface
                                    : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              TextField(
                                controller: _codeController,
                                maxLength: 7,
                                style: theme.textTheme.headlineSmall
                                    ?.copyWith(
                                      letterSpacing: 4,
                                      fontWeight: FontWeight.w600,
                                    ),
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  counterText: "",
                                  hintText: "0000000",
                                  hintStyle: theme.textTheme.headlineSmall
                                      ?.copyWith(
                                        letterSpacing: 4,
                                        color: theme.colorScheme.onSurface
                                            .withOpacity(0.3),
                                        fontWeight: FontWeight.w600,
                                      ),
                                  border: InputBorder.none,
                                  contentPadding:
                                      const EdgeInsets.symmetric(
                                        vertical: 16,
                                        horizontal: 24,
                                      ),
                                ),
                                onSubmitted: (_) => _joinGroup(),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Enter the 7-character room code",
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: Column(
              children: [
                CustomButton(
                  onPressed: _joinGroup,
                  text: 'Join Room',
                  isFullWidth: true,
                  bgColor: AppTheme.primaryColor,
                  isLoading: _isLoading,
                  borderRadius: 12,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
