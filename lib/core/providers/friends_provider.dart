import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zic_flutter/core/api/friends.dart';
import 'package:zic_flutter/core/models/user.dart';
import 'package:zic_flutter/core/providers/user_provider.dart';

class FriendsNotifier extends FamilyAsyncNotifier<List<User>, String?> {
  @override
  Future<List<User>> build(String? userId) async {
    final userAsync = ref.watch(userProvider);

    return userAsync.when(
      data: (user) async {
        final targetUserId = userId ?? user?.id;

        if (targetUserId == null) {
          return [];
        }

        try {
          return await FriendsService.getUserFriends(targetUserId);
        } catch (e) {
          state = AsyncValue.error(e, StackTrace.current);
          return [];
        }
      },
      loading: () => Future.value([]),
      error: (error, stackTrace) => Future.value([]),
    );
  }
}

final friendsProvider = AsyncNotifierProvider.family<FriendsNotifier, List<User>, String?>(
  FriendsNotifier.new,
);

// Mutual Friends Provider
class MutualFriendsNotifier extends FamilyAsyncNotifier<List<User>, (String, String)> {
  @override
  Future<List<User>> build((String, String) arg) async {
    final userId = arg.$1;
    final friendId = arg.$2;

    try {
      return await FriendsService.fetchMutualFriends(userId, friendId);
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
      return [];
    }
  }
}

final mutualFriendsProvider = AsyncNotifierProvider.family<MutualFriendsNotifier, List<User>, (String, String)>(
  MutualFriendsNotifier.new,
);

// Suggested Users Provider
class SuggestedUsersNotifier extends FamilyAsyncNotifier<List<User>, String> {
  @override
  Future<List<User>> build(String userId) async {
    try {
      return await FriendsService.getRecommendedUsers(userId);
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
      return [];
    }
  }
}

final suggestedUsersProvider = AsyncNotifierProvider.family<SuggestedUsersNotifier, List<User>, String>(
  SuggestedUsersNotifier.new,
);

// Example usage:
// ref.watch(friendsProvider(someUserId)); // For a specific user
// ref.watch(friendsProvider(null)); // For the current user

// Example usage of MutualFriendsProvider:
// ref.watch(mutualFriendsProvider((userId, friendId)));

// Example usage of suggestedUsersProvider:
// ref.watch(suggestedUsersProvider(userId));