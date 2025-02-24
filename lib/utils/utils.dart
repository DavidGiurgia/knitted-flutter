import 'dart:math';
import 'package:intl/intl.dart';

// Function to generate a unique join code
Future<String> generateUniqueJoinCode() async {
  bool isUnique = false;
  String joinCode = "";

  while (!isUnique) {
    // Generate a 7-digit code
    joinCode = (1000000 + Random().nextInt(9000000)).toString();
    // Implement your logic to check if the code is unique
    isUnique = await checkCode(joinCode);
  }
  return joinCode;
}

// Function to check if the code is unique (Placeholder implementation)
Future<bool> checkCode(String joinCode) async {
  // Implement your logic to check if the code is unique
  // For now, we'll return true to simulate uniqueness
  return Future.value(true);
}

// Function to format the date string
String multiFormatDateString(String timestamp) {
  int timestampNum = (DateTime.parse(timestamp).millisecondsSinceEpoch / 1000).round();
  DateTime date = DateTime.fromMillisecondsSinceEpoch(timestampNum * 1000);
  DateTime now = DateTime.now();

  Duration diff = now.difference(date);
  double diffInSeconds = diff.inSeconds.toDouble();
  double diffInMinutes = diffInSeconds / 60;
  double diffInHours = diffInMinutes / 60;
  double diffInDays = diffInHours / 24;

  if (diffInDays >= 30) {
    return formatDateString(timestamp);
  } else if (diffInDays >= 1 && diffInDays < 2) {
    return '${diffInDays.floor()} day ago';
  } else if (diffInDays >= 2 && diffInDays < 30) {
    return '${diffInDays.floor()} days ago';
  } else if (diffInHours >= 1) {
    return '${diffInHours.floor()} hours ago';
  } else if (diffInMinutes >= 1) {
    return '${diffInMinutes.floor()} minutes ago';
  } else {
    return 'Just now';
  }
}

// Function to format the date string (Placeholder implementation)
String formatDateString(String timestamp) {
  DateTime date = DateTime.parse(timestamp);
  final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
  return formatter.format(date);
}

// Function to format the date string with custom options
String formatDateStringWithOptions(String dateString) {
  DateTime date = DateTime.parse(dateString);
  final DateFormat dateFormatter = DateFormat('MMM d, yyyy');
  final DateFormat timeFormatter = DateFormat('h:mm a');

  String formattedDate = dateFormatter.format(date);
  String time = timeFormatter.format(date);

  return '$formattedDate at $time';
}