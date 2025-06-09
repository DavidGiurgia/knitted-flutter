import 'dart:io';

import 'package:flutter/material.dart';
import 'package:zic_flutter/core/models/community.dart';

class PostData {
  final TextEditingController textController = TextEditingController();
  final TextEditingController urlController = TextEditingController();
  final List<TextEditingController> optionControllers = [
    TextEditingController(text: "Yes"),
    TextEditingController(text: "No"),
  ];
  final List<File> images = [];
  String selectedOption = 'text';
  String commentControl = 'everyone'; // Valoarea implicită
  String selectedAudience = 'friends';
  Community? selectedCommunity;

  VoidCallback? onMediaTap;

  void reset() {
    urlController.clear();
    for (final controller in optionControllers) {
      controller.text = "";
    }
    images.clear();
    selectedOption = 'text';
  }

  // Funcție care trigger-uieste callback-ul
  void triggerMediaChanged() {
    if (onMediaTap != null) {
      onMediaTap!();
    }
  }
}
