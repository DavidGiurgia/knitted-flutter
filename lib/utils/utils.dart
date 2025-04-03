import 'dart:math';
import 'package:intl/intl.dart';
import 'package:zic_flutter/core/api/room_service.dart';

Future<String> generateUniqueJoinCode() async {
  bool isUnique = false;
  String joinCode = "";
  int maxAttempts = 10; // Limităm numărul de încercări
  int attempts = 0;

  while (!isUnique && attempts < maxAttempts) {
    joinCode = (1000000 + Random().nextInt(9000000)).toString();
    isUnique = await RoomService.checkCode(joinCode);
    attempts++;
  }

  if (!isUnique) {
    throw Exception(
      "Failed to generate a unique join code after $maxAttempts attempts.",
    );
  }

  return joinCode;
}

// Function to format the date string
String multiFormatDateString(DateTime date, {bool short = false}) {
  // Change to DateTime
  DateTime now = DateTime.now();

  Duration diff = now.difference(date);
  double diffInSeconds = diff.inSeconds.toDouble();
  double diffInMinutes = diffInSeconds / 60;
  double diffInHours = diffInMinutes / 60;
  double diffInDays = diffInHours / 24;

  if (diffInDays >= 30) {
    return formatDateString(date); // Pass DateTime
  } else if (diffInDays >= 1 && diffInDays < 2) {
    return '${diffInDays.floor()} ${short ? 'd' : 'day ago'}';
  } else if (diffInDays >= 2 && diffInDays < 30) {
    return '${diffInDays.floor()} ${short ? 'd' : 'days ago'}';
  } else if (diffInHours >= 1) {
    return '${diffInHours.floor()} ${short ? 'h' : 'hours ago'}';
  } else if (diffInMinutes >= 1) {
    return '${diffInMinutes.floor()} ${short ? 'm' : 'minutes ago'}';
  } else {
    return 'Just now';
  }
}

// Function to format the date string (Placeholder implementation)
String formatDateString(DateTime date) {
  // Change to DateTime
  final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
  return formatter.format(date);
}

// Function to format the date string with custom options
String formatDateStringWithOptions(DateTime date) {
  // Change to DateTime
  final DateFormat dateFormatter = DateFormat('MMM d, yyyy');
  final DateFormat timeFormatter = DateFormat('h:mm a');

  String formattedDate = dateFormatter.format(date);
  String time = timeFormatter.format(date);

  return '$formattedDate at $time';
}

String formatTimestampCompact(DateTime timestamp) {
  final now = DateTime.now();
  final difference = now.difference(timestamp);

  if (difference.inDays > 0) {
    return DateFormat('MM/dd/yy').format(timestamp);
  } else if (difference.inHours > 0) {
    return '${difference.inHours}h';
  } else if (difference.inMinutes > 0) {
    return '${difference.inMinutes}m';
  } else {
    return 'now';
  }
}
