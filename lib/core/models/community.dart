import 'dart:convert';

class Community {
  final String id;
  final String name;
  final String description;
  final String creatorId;
  final List<String> members;
  final List<String> admins;
  final List<String> pendingRequests;
  final List<CommunityInvitation> invitations;
  final bool onlyAdminsCanPost;
  final bool allowAnonymousPosts;
  final List<String> rules;
  final String bannerUrl;
  final String bannerPublicId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Community({
    required this.id,
    required this.name,
    required this.description,
    required this.creatorId,
    this.members = const [],
    this.admins = const [],
    this.pendingRequests = const [],
    this.invitations = const [],
    this.onlyAdminsCanPost = false,
    this.allowAnonymousPosts = false,
    this.rules = const ['Respectați ceilalți membri', 'Fără conținut ilegal'],
    this.bannerUrl = '',
    this.bannerPublicId = '',
    this.createdAt,
    this.updatedAt,
  });

  // Metoda copyWith
  Community copyWith({
    String? id,
    String? name,
    String? description,
    String? creatorId,
    List<String>? members,
    List<String>? admins,
    List<String>? pendingRequests,
    List<CommunityInvitation>? invitations,
    bool? onlyAdminsCanPost,
    bool? allowAnonymousPosts,
    List<String>? rules,
    String? bannerUrl,
    String? bannerPublicId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Community(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      creatorId: creatorId ?? this.creatorId,
      members: members ?? this.members,
      admins: admins ?? this.admins,
      pendingRequests: pendingRequests ?? this.pendingRequests,
      invitations: invitations ?? this.invitations,
      onlyAdminsCanPost: onlyAdminsCanPost ?? this.onlyAdminsCanPost,
      allowAnonymousPosts: allowAnonymousPosts ?? this.allowAnonymousPosts,
      rules: rules ?? this.rules,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      bannerPublicId: bannerPublicId ?? this.bannerPublicId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper method to add a member
  Community addMember(String userId) {
    return copyWith(
      members: [...members, userId],
      pendingRequests: pendingRequests.where((id) => id != userId).toList(),
    );
  }

  // Helper method to remove a member
  Community removeMember(String userId) {
    return copyWith(
      members: members.where((id) => id != userId).toList(),
      admins: admins.where((id) => id != userId).toList(),
    );
  }

  // Helper method to add admin
  Community addAdmin(String userId) {
    return copyWith(admins: [...admins, userId]);
  }

  // Helper method to add pending request
  Community addPendingRequest(String userId) {
    return copyWith(pendingRequests: [...pendingRequests, userId]);
  }

  // Helper method to remove pending request
  Community removePendingRequest(String userId) {
    return copyWith(
      pendingRequests: pendingRequests.where((id) => id != userId).toList(),
    );
  }

  // Helper method to add invitation
  Community addInvitation(CommunityInvitation invitation) {
    return copyWith(invitations: [...invitations, invitation]);
  }

  // Helper method to remove invitation
  Community removeInvitation(String userId) {
    return copyWith(
      invitations: invitations.where((i) => i.user != userId).toList(),
    );
  }

  // Check if user is admin
  bool isAdmin(String userId) {
    return admins.contains(userId) || creatorId == userId;
  }

  // Check if user is member
  bool isMember(String userId) {
    return members.contains(userId) || isAdmin(userId);
  }

  // Check if user has pending request
  bool hasPendingRequest(String userId) {
    return pendingRequests.contains(userId);
  }

  factory Community.fromJson(Map<String, dynamic> json) {
    return Community(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      creatorId: json['creatorId'] ?? '',
      members: List<String>.from(
        json['members']?.map((x) => x.toString()) ?? [],
      ),
      admins: List<String>.from(json['admins']?.map((x) => x.toString()) ?? []),
      pendingRequests: List<String>.from(
        json['pendingRequests']?.map((x) => x.toString()) ?? [],
      ),
      invitations: List<CommunityInvitation>.from(
        json['invitations']?.map((x) => CommunityInvitation.fromJson(x)) ?? [],
      ),
      onlyAdminsCanPost: json['onlyAdminsCanPost'] ?? false,
      allowAnonymousPosts: json['allowAnonymousPosts'] ?? false,
      rules: List<String>.from(json['rules'] ?? []),
      bannerUrl: json['bannerUrl'] ?? '',
      bannerPublicId: json['bannerPublicId'] ?? '',
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'creatorId': creatorId,
      'members': members,
      'admins': admins,
      'pendingRequests': pendingRequests,
      'invitations': invitations.map((x) => x.toJson()).toList(),
      'onlyAdminsCanPost': onlyAdminsCanPost,
      'allowAnonymousPosts': allowAnonymousPosts,
      'rules': rules,
      'bannerUrl': bannerUrl,
      'bannerPublicId': bannerPublicId,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  String toJsonString() => json.encode(toJson());

  factory Community.fromJsonString(String source) =>
      Community.fromJson(json.decode(source));

  @override
  String toString() {
    return 'Community(id: $id, name: $name, members: ${members.length}, admins: ${admins.length})';
  }
}

class CommunityInvitation {
  final String user;
  final String invitedBy;
  final DateTime createdAt;

  CommunityInvitation({
    required this.user,
    required this.invitedBy,
    required this.createdAt,
  });

  CommunityInvitation copyWith({
    String? user,
    String? invitedBy,
    DateTime? createdAt,
  }) {
    return CommunityInvitation(
      user: user ?? this.user,
      invitedBy: invitedBy ?? this.invitedBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory CommunityInvitation.fromJson(Map<String, dynamic> json) {
    return CommunityInvitation(
      user: json['user']?.toString() ?? '',
      invitedBy: json['invitedBy']?.toString() ?? '',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user,
      'invitedBy': invitedBy,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Invitation(user: $user, invitedBy: $invitedBy)';
  }
}
