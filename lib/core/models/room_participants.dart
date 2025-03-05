class RoomParticipant {
  final String userId;
  final String roomId;

  RoomParticipant({
    required this.userId,
    required this.roomId,
  });

  factory RoomParticipant.fromJson(Map<String, dynamic> json) {
    return RoomParticipant(
      userId: json['userId'],
      roomId: json['roomId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'roomId': roomId,
    };
  }
}