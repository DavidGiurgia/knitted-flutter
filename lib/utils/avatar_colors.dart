import 'package:flutter/material.dart';

class AvatarColors {
  static const List<Color> backgroundColors = [
    Color(0xFFeeedfd), // Blue Gem/Surface
    Color(0xFFe0e6eb), // Oxford Blue/Surface
    Color(0xFFeaefe6), // Willow Grove/Surface
    Color(0xFFe4e2f3), // Persian Indigo/Surface
    Color(0xFFfdefe2), // Meteor/Surface
    Color(0xFFfff7e0), // Korma/Surface
    Color(0xFFe6ebef), // Honey Flower/Surface
    Color(0xFFf2ffd1), // Green Leaf/Surface
    Color(0xFFe6dfec), // Martinique/Surface
    Color(0xFFd8e8f3), // Cloud Burst/Surface
    Color(0xFFedeefd), // Ultramarine/Surface
    Color(0xFFebe6ef), // Whisper/Surface
    Color(0xFFecfafe), // Eastern Blue/Surface
    Color(0xFFe2f4e8), // Tuna/Surface
    Color(0xFFebe0fe), // Bunting/Surface
    Color(0xFFe7f9f3), // Green Pea/Surface
    Color(0xFFe8def6), // Kingfisher Daisy/Surface
    Color(0xFFffebee), // Shiraz/Surface
    Color(0xFFfdf1f7), // Rouge/Surface
    // Add the other 20 background colors here
  ];

  static const List<Color> textColors = [
    Color(0xFF4409b9), // Blue Gem/Text & Icon
    Color(0xFF2d3a46), // Oxford Blue/Text & Icon
    Color(0xFF69785e), // Willow Grove/Text & Icon
    Color(0xFF280f6d), // Persian Indigo/Text & Icon
    Color(0xFFc56511), // Meteor/Text & Icon
    Color(0xFF935f10), // Korma/Text & Icon
    Color(0xFF4d176e), // Honey Flower/Text & Icon
    Color(0xFF526e0c), // Green Leaf/Text & Icon
    Color(0xFF37364f), // Martinique/Text & Icon
    Color(0xFF222a54), // Cloud Burst/Text & Icon
    Color(0xFF05128a), // Ultramarine/Text & Icon
    Color(0xFFab133e), // Whisper/Text & Icon
    Color(0xFF1f84a3), // Eastern Blue/Text & Icon
    Color(0xFF363548), // Tuna/Text & Icon
    Color(0xFF192251), // Bunting/Text & Icon
    Color(0xFF216e55), // Green Pea/Text & Icon
    Color(0xFF420790), // Kingfisher Daisy/Text & Icon
    Color(0xFFbd0f2c), // Shiraz/Text & Icon
    Color(0xFF973562), // Rouge/Text & Icon
    // Add the other 20 text colors here
  ];

  static Color getBackgroundColor(String name) {
    final int index = name.hashCode % backgroundColors.length;
    return backgroundColors[index];
  }

  static Color getTextColor(String name) {
    final int index = name.hashCode % textColors.length;
    return textColors[index];
  }
}