import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zic_flutter/core/providers/friends_provider.dart';
import 'package:zic_flutter/core/providers/user_provider.dart';
import 'package:zic_flutter/widgets/user_list_tile.dart';

class SelectFriendsList extends ConsumerStatefulWidget {
  final bool isExceptionList;
  final List<String> initialSelectedIds;

  const SelectFriendsList({
    super.key,
    required this.isExceptionList,
    required this.initialSelectedIds,
  });

  @override
  ConsumerState<SelectFriendsList> createState() => _SelectFriendsListState();
}

class _SelectFriendsListState extends ConsumerState<SelectFriendsList> {
  late List<String> _selectedIds = []; // Lista internă cu ID-uri selectate.

  @override
  void initState() {
    super.initState();

    final user = ref.read(userProvider).value;
    if (user == null) return;

    final userFriends = ref.read(friendsProvider(null)).value;
    if (userFriends == null) return;

    if (widget.isExceptionList) {
      final allFriendIds = userFriends.map((friend) => friend.id).toList();
      _selectedIds =
          allFriendIds
              .where(
                (friendId) => widget.initialSelectedIds.contains(friendId),
              )
              .toList();
    } else {
      // Pentru lista specifică, inițializăm direct cu initialSelectedIds.
      _selectedIds = List.from(widget.initialSelectedIds);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider).value;
    if (user == null) {
      return const Center(child: Text("Please log in again!"));
    }
    final friendsAsync = ref.watch(friendsProvider(user.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isExceptionList ? 'Friends except...' : 'Specific friends',
        ),
      ),
      body: friendsAsync.when(
        data: (friends) {
          if (friends.isEmpty) {
            return const Center(child: Text("You don't have any friends yet."));
          }

          return ListView.builder(
            itemCount: friends.length,
            itemBuilder: (context, index) {
              final friend = friends[index];
              final isSelected = _selectedIds.contains(friend.id);
              return UserListTile(
                user: friend,
                actionWidget: Icon(
                  isSelected
                      ? (widget.isExceptionList
                          ? Icons.do_not_disturb_on_rounded
                          : Icons.check_circle_rounded)
                      : (widget.isExceptionList
                          ? Icons.radio_button_unchecked_rounded
                          : Icons.radio_button_unchecked_rounded),
                  size: 24.0,
                  color:
                      isSelected
                          ? (widget.isExceptionList ? Colors.red : Colors.green)
                          : Colors.grey,
                ),
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedIds.remove(friend.id);
                    } else {
                      _selectedIds.add(friend.id);
                    }
                  });
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          List<String> resultIds;
          if (widget.isExceptionList) {
            // Pentru lista de excepții, calculăm lista cu prietenii care *vor* vedea postarea.
            final allFriendIds =
                friendsAsync.value!.map((friend) => friend.id).toList();
            resultIds =
                allFriendIds
                    .where((friendId) => !_selectedIds.contains(friendId))
                    .toList();
          } else {
            // Pentru lista specifică, returnăm lista selectată.
            resultIds = _selectedIds;
          }
          Navigator.pop(context, resultIds);
        },
        child: const Icon(Icons.done),
      ),
    );
  }
}
