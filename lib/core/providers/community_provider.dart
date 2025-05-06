import 'package:flutter_riverpod/flutter_riverpod.dart';

class Community {
  final String id;
  final String name;
  final String? imageUrl;

  Community({required this.id, required this.name, this.imageUrl});
}

final communitiesProvider = StateNotifierProvider<CommunitiesNotifier, List<Community>>((ref) {
  return CommunitiesNotifier();
});

class CommunitiesNotifier extends StateNotifier<List<Community>> {
  CommunitiesNotifier() : super([
    Community(id: '1', name: 'Newest'),
    Community(id: '2', name: 'Friends'),
    // Alte comunități vor fi adăugate dinamic
  ]);

  void addCommunity(Community community) {
    state = [...state, community];
  }

  void reorderCommunities(int oldIndex, int newIndex) {
    if (oldIndex < 2) return; // Nu permitem mutarea tab-urilor implicite
    final List<Community> reordered = List.from(state);
    final Community item = reordered.removeAt(oldIndex);
    reordered.insert(newIndex, item);
    state = reordered;
  }
}