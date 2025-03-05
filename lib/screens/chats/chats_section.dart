import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/models/chat_room.dart';
import 'package:zic_flutter/widgets/chat_list_tile.dart';

class ChatsSection extends StatefulWidget {
  final List<Room> rooms;
  final TextEditingController searchController;
  final Function(String) onSearchChanged;
  final VoidCallback onCreatePressed; // Adaugă acest callback
  final VoidCallback onJoinPressed; // Adaugă acest callback

  const ChatsSection({
    super.key,
    required this.rooms,
    required this.searchController,
    required this.onSearchChanged,
    required this.onCreatePressed, // Constructor actualizat
    required this.onJoinPressed, // Constructor actualizat
  });

  @override
  State<ChatsSection> createState() => _ChatsSectionState();
}

class _ChatsSectionState extends State<ChatsSection> {
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 14),
      child: Column(
        children: [
          _buildSearchBar(context),
          const SizedBox(height: 10),
          Expanded(
            child:
                widget.rooms.isEmpty
                    ? _buildEmptyState(context)
                    : ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: widget.rooms.length,
                      itemBuilder: (context, index) {
                        final room = widget.rooms[index];
                        return ChatListTile(room: room);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
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
              controller: widget.searchController,
              onChanged: widget.onSearchChanged,
              style: const TextStyle(
                fontSize: 14,
                decoration: TextDecoration.none,
              ),
              decoration: InputDecoration(
                hintText: "Search",
                hintStyle: TextStyle(fontSize: 15, color: Colors.grey.shade500),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          HeroIcon(
            HeroIcons.chatBubbleLeftRight,
            style: HeroIconStyle.solid,
            color:
                AppTheme.isDark(context)
                    ? Colors.grey.shade800
                    : Colors.grey.shade300,
            size: 60,
          ),
          const SizedBox(height: 16),
          Text(
            "No chats found",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color:
                  AppTheme.isDark(context)
                      ? Colors.grey.shade600
                      : Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 6),
          Text.rich(
            TextSpan(
              text: "You can ",
              style: TextStyle(
                fontSize: 16,
                color:
                    AppTheme.isDark(context)
                        ? Colors.grey.shade600
                        : Colors.grey.shade500,
              ),
              children: [
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: GestureDetector(
                    onTap: widget.onCreatePressed,
                    child: Text(
                      "create",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ),
                const TextSpan(text: " or "),

                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: GestureDetector(
                    onTap: widget.onJoinPressed,
                    child: Text(
                      "join",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ),
                const TextSpan(text: " a new chat."),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
