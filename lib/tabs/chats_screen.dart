import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/screens/chats/new_chat_section.dart';
import 'package:zic_flutter/screens/chats/new_temporary_chat_section.dart';
import 'package:zic_flutter/widgets/bottom_sheet.dart';
import 'package:zic_flutter/widgets/button.dart';
import 'package:zic_flutter/widgets/temporary_chats_section.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  final TextEditingController _searchController = TextEditingController();

  void _onSearchChanged(String query) async {
    // Handle search query changes
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return CustomBottomSheet(
          title: "Start a New Chat",
          options: [
            SheetOption(
              title: "Quick Chat",
              subtitle:
                  "A temporary conversation where no data is saved, and your identity remains hidden.",
              icon: HeroIcons.clock,
              iconColor: AppTheme.primaryColor,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NewTemporaryChatSection()),
                );
              },
            ),
            SheetOption(
              title: "Regular Chat",
              subtitle: "Stay connected with your friends.",
              icon: HeroIcons.chatBubbleLeftRight,
              iconColor: Colors.blue,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NewChatSection()),
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
        backgroundColor: AppTheme.backgroundColor(context),
        title: Text("Chats"),
        actions: [
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
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: TemporaryChatsSection()),
          SliverFillRemaining(
            child: Container(
              color: AppTheme.backgroundColor(context),
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color:
                            AppTheme.isDark(context)
                                ? Colors.grey.shade900
                                : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          HeroIcon(
                            HeroIcons.magnifyingGlass,
                            style: HeroIconStyle.outline,
                            color: Colors.grey.shade500,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              autofocus: false,
                              controller: _searchController,
                              onChanged: _onSearchChanged,
                              style: const TextStyle(
                                fontSize: 14,
                                decoration: TextDecoration.none,
                              ),
                              decoration: InputDecoration(
                                hintText: "Search",
                                hintStyle: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey.shade500,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
