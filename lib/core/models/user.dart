class User {
  final String id;
  final String username;
  final String fullname;
  final String email;
  final String bio;
  final String role;
  final List<String> friendsIds;
  final List<String> friendRequests;
  final List<String> sentRequests;
  final List<String> blockedUsers;
  final String avatarUrl;
  final String avatarPublicId;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.username,
    required this.fullname,
    required this.email,
    required this.bio,
    required this.role,
    required this.friendsIds,
    required this.friendRequests,
    required this.sentRequests,
    required this.blockedUsers,
    required this.avatarUrl,
    required this.avatarPublicId,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convertim JSON -> User
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      username: json['username'] ?? '',
      fullname: json['fullname'] ?? '',
      email: json['email'] ?? '',
      bio: json['bio'] ?? '',
      role: json['role'] ?? 'user',
      friendsIds: List<String>.from(json['friendsIds'] ?? []),
      friendRequests: List<String>.from(json['friendRequests'] ?? []),
      sentRequests: List<String>.from(json['sentRequests'] ?? []),
      blockedUsers: List<String>.from(json['blockedUsers'] ?? []),
      avatarUrl: json['avatarUrl'] ?? '',
      avatarPublicId: json['avatarPublicId'] ?? '',

      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  // Convertim User -> JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'username': username,
      'fullname': fullname,
      'email': email,
      'bio': bio,
      'role': role,
      'friendsIds': friendsIds,
      'friendRequests': friendRequests,
      'sentRequests': sentRequests,
      'blockedUsers': blockedUsers,
      'avatarUrl': avatarUrl,
      'avatarPublicId': avatarPublicId,

      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static User defaultUser() {
    return User(
      id: '',
      username: '',
      fullname: 'Unknown',
      email: '',
      bio: '',
      role: 'user',
      friendsIds: [],
      friendRequests: [],
      sentRequests: [],
      blockedUsers: [],
      avatarUrl: '',
      avatarPublicId: '',

      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
