import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zic_flutter/core/api/friends.dart';
import 'package:zic_flutter/core/models/user.dart';
import 'package:zic_flutter/core/providers/user_provider.dart';

class FriendsProvider with ChangeNotifier {
  List<User> _friends = [];

  List<User> get friends => _friends;

  Future<void> loadFriends(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.user == null) return;
    _friends = await FriendsService.getUserFriends(userProvider.user!.id);
    notifyListeners();
  }
}
