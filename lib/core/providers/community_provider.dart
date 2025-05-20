import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zic_flutter/core/api/community_service.dart';
import 'package:zic_flutter/core/models/community.dart';
import 'package:zic_flutter/core/providers/user_provider.dart';

class CommunityState {
  final List<Community> allCommunities;
  final List<Community> createdCommunities;
  final List<Community> joinedCommunities;
  final List<Community> pendingCommunities;
  final bool isLoading;
  final String? error;

  const CommunityState({
    this.allCommunities = const [],
    this.createdCommunities = const [],
    this.joinedCommunities = const [],
    this.pendingCommunities = const [],
    this.isLoading = false,
    this.error,
  });

  CommunityState copyWith({
    List<Community>? allCommunities,
    List<Community>? createdCommunities,
    List<Community>? joinedCommunities,
    List<Community>? pendingCommunities,
    bool? isLoading,
    String? error,
  }) {
    return CommunityState(
      allCommunities: allCommunities ?? this.allCommunities,
      createdCommunities: createdCommunities ?? this.createdCommunities,
      joinedCommunities: joinedCommunities ?? this.joinedCommunities,
      pendingCommunities: pendingCommunities ?? this.pendingCommunities,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class CommunityNotifier extends StateNotifier<CommunityState> {
  final Ref ref;

  CommunityNotifier(this.ref) : super(const CommunityState());

  String get _userId {
    final user = ref.read(userProvider).value;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    return user.id;
  }

  Future<void> loadUserCommunities() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final communities = await CommunityService.getUserCommunities();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Categorize communities
        final created =
            communities.where((c) => c.creatorId == _userId).toList();
        final joined =
            communities.where((c) => c.members.contains(_userId)).toList();
        final pending =
            communities
                .where((c) => c.pendingRequests.contains(_userId))
                .toList();

        state = state.copyWith(
          allCommunities: communities,
          createdCommunities: created,
          joinedCommunities: joined,
          pendingCommunities: pending,
          isLoading: false,
        );
      });
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load communities: ${e.toString()}',
      );
      rethrow;
    }
  }

  Future<void> createCommunity(
    String name,
    String description, {
    bool onlyAdminsCanPost = false,
    bool allowAnonymousPosts = false,
    List<String> rules = const [],
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final newCommunity = await CommunityService.createCommunity(
        name: name, // Named parameter
        description: description, // Named parameter
        onlyAdminsCanPost: onlyAdminsCanPost,
        allowAnonymousPosts: allowAnonymousPosts,
        rules: rules,
      );

      // Handle null response (shouldn't happen with proper error handling)
      if (newCommunity == null) {
        throw Exception('Community creation returned null');
      }

      // Update state
      state = state.copyWith(
        isLoading: false,
        allCommunities: [...state.allCommunities, newCommunity],
        createdCommunities: [...state.createdCommunities, newCommunity],
      );
    } on HttpException catch (e) {
      // Handle specific HTTP errors
      state = state.copyWith(
        isLoading: false,
        error: 'Network error: ${e.message}',
      );
      rethrow;
    } on Exception catch (e) {
      // Handle other exceptions
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to create community: ${e.toString()}',
      );
      rethrow;
    }
  }

  Future<void> joinCommunity(String communityId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final success = await CommunityService.joinCommunity(communityId);

      if (success) {
        final updatedCommunities =
            state.allCommunities.map((community) {
              if (community.id == communityId) {
                return community.copyWith(
                  pendingRequests: [...community.pendingRequests, _userId],
                );
              }
              return community;
            }).toList();

        final updatedCommunity = updatedCommunities.firstWhere(
          (c) => c.id == communityId,
          orElse: () => throw Exception('Community not found'),
        );

        state = state.copyWith(
          allCommunities: updatedCommunities,
          pendingCommunities: [...state.pendingCommunities, updatedCommunity],
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to join community: ${e.toString()}',
      );
      rethrow;
    }
  }

  // Provider definition
  static final provider =
      StateNotifierProvider<CommunityNotifier, CommunityState>((ref) {
        return CommunityNotifier(ref);
      });
}
