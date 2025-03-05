// import 'package:flutter/material.dart';
// import 'package:heroicons/heroicons.dart';
// import 'package:provider/provider.dart';
// import 'package:zic_flutter/core/api/temporary_room.dart';
// import 'package:zic_flutter/core/api/user_temporary_room.dart';
// import 'package:zic_flutter/core/app_theme.dart';
// import 'package:zic_flutter/core/models/temporary_chat_room.dart';
// import 'package:flutter/services.dart';
// import 'package:zic_flutter/core/providers/user_provider.dart';
// import 'package:zic_flutter/screens/chats/new_temporary_chat_section.dart';
// import 'package:zic_flutter/screens/chats/temporary_chat_room.dart';
// import 'package:zic_flutter/widgets/button.dart';
// import 'package:zic_flutter/widgets/join_room_input.dart';

// class TemporaryChatsSection extends StatefulWidget {
//   const TemporaryChatsSection({super.key});

//   @override
//   State<TemporaryChatsSection> createState() => _TemporaryChatsSectionState();
// }

// class _TemporaryChatsSectionState extends State<TemporaryChatsSection> {
//   final TextEditingController _codeController = TextEditingController();
//   List<TemporaryChatRoom> temporaryRooms = [];

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _loadRooms();
//     });
//   }

//   Future<void> _loadRooms() async {
//     final userProvider = Provider.of<UserProvider>(context, listen: false);
//     final user = userProvider.user;

//     if (user == null) {
//       print("User is null - skipping room loading");
//       return;
//     }

//     await _loadRecentRooms(user.id);
//   }

//   Future<void> _loadRecentRooms(String userId) async {
//     final roomIds = await UserTemporaryRoomService.fetchUserRoomsIds(userId);
//     if (roomIds != null && roomIds.isNotEmpty) {
//       List<TemporaryChatRoom> rooms = [];
//       for (var roomId in roomIds) {
//         if (roomId == null) {
//           continue;
//         }
//         final room = await TemporaryRoomService.getRoomById(roomId);
//         if (room != null) {
//           rooms.add(room);
//         }
//       }
//       if (mounted) {
//         setState(() {
//           temporaryRooms = rooms;
//         });
//       }
//     }
//   }

//   void _onJoin() async {
//     final userProvider = Provider.of<UserProvider>(context, listen: false);
//     final code = _codeController.text.trim();
//     if (code.isEmpty) {
//       return;
//     }
//     TemporaryChatRoom? temporaryRoom = await TemporaryRoomService.getRoomByCode(
//       code,
//     );
//     if (temporaryRoom == null || userProvider.user == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Sorry, there is no such room active right now!'),
//         ),
//       );
//       return;
//     }
//     if (!temporaryRooms.contains(temporaryRoom) && userProvider.user != null) {
//       await UserTemporaryRoomService.pair(
//         userProvider.user!.id,
//         temporaryRoom.id,
//       );
//     } else {
//       temporaryRooms.add(temporaryRoom);
//     }
//     _codeController.clear();
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => TemporaryChatRoomSection(room: temporaryRoom),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Temporary Chats'),

//         actions: [
//           CustomButton(
//             onPressed:
//                 () => Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => const NewTemporaryChatSection(),
//                   ),
//                 ),
//             isIconOnly: true,
//             heroIcon: HeroIcons.plus,
//             iconStyle: HeroIconStyle.mini,
//             type: ButtonType.light,
//             size: ButtonSize.large,
//           ),
//         ],
//       ),
//       body: RefreshIndicator(
//         onRefresh: _loadRooms,
//         child: Expanded(
//           child: SingleChildScrollView(
//             physics: AlwaysScrollableScrollPhysics(),

//             child: Column(
//               children: [
//                 Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 24,
//                     vertical: 24,
//                   ),
//                   color: AppTheme.primaryColor,
//                   child: JoinTemporaryRoomInput(
//                     controller: _codeController,
//                     onJoin: _onJoin,
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 ...temporaryRooms.take(6).map((room) => _buildRoomCard(room)),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildRoomCard(TemporaryChatRoom room) {
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//       decoration: BoxDecoration(
//         color: AppTheme.backgroundColor(context),
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color:
//                 AppTheme.isDark(context)
//                     ? Colors.black12.withValues(
//                       alpha: 2,
//                     ) // Mai subtil, aproape invizibil
//                     : Colors.black.withValues(alpha: 0.06),
//             spreadRadius: 0.1, // Aproape fără extindere
//             blurRadius: 4, // Mai puțin difuz
//             offset: const Offset(
//               0,
//               2,
//             ), // Umbră mai apropiată, fără efect plutitor
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           InkWell(
//             onTap:
//                 () => Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => TemporaryChatRoomSection(room: room),
//                   ),
//                 ),
//             child: Container(
//               width: double.infinity,
//               padding: const EdgeInsets.fromLTRB(0, 10, 0, 2),
//               decoration: const BoxDecoration(),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     room.topic,
//                     maxLines: 3,
//                     overflow: TextOverflow.ellipsis,
//                     style: const TextStyle(fontSize: 20),
//                   ),
//                   const SizedBox(height: 1),
//                   Text(
//                     "(#${room.joinCode})",
//                     overflow: TextOverflow.ellipsis,
//                     style: TextStyle(
//                       fontSize: 16,
//                       color:
//                           AppTheme.isDark(context)
//                               ? AppTheme.grey400
//                               : AppTheme.grey800,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           const SizedBox(height: 4),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               _buildCountdown(room.expiresAt),
//               Row(
//                 children: [
//                   IconButton(
//                     onPressed: () {
//                       Clipboard.setData(
//                         ClipboardData(text: room.joinCode ?? ''),
//                       );
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text('Code copied to clipboard'),
//                         ),
//                       );
//                     },
//                     icon: const Icon(
//                       Icons.copy_rounded,
//                       color: Colors.grey,
//                       size: 24,
//                     ),
//                   ),
//                   IconButton(
//                     onPressed: () async {
//                       setState(() {
//                         temporaryRooms.remove(room);
//                       });
//                       await UserTemporaryRoomService.deleteRoomDependencies(
//                         room.id,
//                       );
//                       await TemporaryRoomService.deleteRoom(room.id);
//                     },
//                     icon: const HeroIcon(
//                       HeroIcons.trash,
//                       style: HeroIconStyle.outline,
//                       color: Colors.grey,
//                       size: 24,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCountdown(DateTime expiresAt) {
//     final now = DateTime.now().toUtc();
//     final expiresAtUtc = expiresAt.toUtc();
//     final difference = expiresAtUtc.difference(now);

//     String timeText;
//     Color textColor = Colors.grey;

//     if (difference.inDays > 1) {
//       timeText = "${difference.inDays} days left";
//     } else if (difference.inHours >= 1) {
//       timeText = "${difference.inHours} hours left";
//       textColor = Colors.orange;
//     } else if (difference.inMinutes >= 1) {
//       timeText = "${difference.inMinutes} minutes left";
//       textColor = Colors.red;
//     } else {
//       timeText = "Expiring soon!";
//       textColor = Colors.red.shade700;
//     }

//     return Text(timeText, style: TextStyle(fontSize: 18, color: textColor));
//   }
// }
