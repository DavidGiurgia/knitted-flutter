import 'package:flutter/material.dart';
import 'package:zic_flutter/core/models/chat_room.dart';
import 'package:zic_flutter/core/models/user.dart';

class SearchResult {
  final String type; // "room" sau "friend"
  final dynamic data; // Room sau User

  SearchResult.room(Room room) : type = 'room', data = room;
  SearchResult.friend(User friend) : type = 'friend', data = friend;
  
}

class SearchProvider with ChangeNotifier {
  final List<Room> _rooms;
  final List<User> _friends;

  SearchProvider(this._rooms, this._friends);

  List<SearchResult> _results = [];

  List<SearchResult> get results => _results;

  // Căutare doar după utilizatori
  void searchUsers(String query) {
    final friendResults = _friends
        .where(
          (friend) =>
              friend.username.toLowerCase().contains(query.toLowerCase()) ||
              friend.fullname.toLowerCase().contains(query.toLowerCase()),
        )
        .map((friend) => SearchResult.friend(friend));

    _results = [...friendResults]; // Actualizăm doar rezultatele utilizatorilor
    notifyListeners(); // notificăm ascultătorii
  }

  // Metodă pentru a obține doar rezultatele de tip User
  List<User> get userResults {
    return _results
        .where((result) => result.type == 'friend')
        .map((result) => result.data as User)
        .toList();
  }

  // Adaugă o metodă pentru a căuta atât camere, cât și utilizatori
  void search(String query) {
    // Căutăm camere care au topicul care conține query-ul
    final roomResults = _rooms
        .where((room) => room.topic.toLowerCase().contains(query.toLowerCase()))
        .map((room) => SearchResult.room(room));

    // Căutăm utilizatori care au numele complet care conține query-ul
    final friendResults = _friends
        .where(
          (friend) =>
              friend.fullname.toLowerCase().contains(query.toLowerCase()),
        )
        .map((friend) => SearchResult.friend(friend));

    _results = [...roomResults, ...friendResults];

    notifyListeners(); // notificăm ascultătorii când rezultatele se actualizează
  }
}
