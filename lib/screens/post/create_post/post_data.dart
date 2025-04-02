import 'dart:io';

import 'package:flutter/material.dart';

class PostData {
  final TextEditingController textController = TextEditingController();
  final TextEditingController urlController = TextEditingController();
  final List<TextEditingController> optionControllers = [
    TextEditingController(text: "Yes"),
    TextEditingController(text: "No"),
  ];
  final List<File> images = [];
  final List<File> videos = [];
  String selectedOption = 'text';
  String commentControl = 'everyone'; // Valoarea implicită
  String selectedAudience = 'friends';
  List<String> audienceList = [];

  VoidCallback? onMediaTap;

  void reset() {
    urlController.clear();
    for (final controller in optionControllers) {
      controller.text = "";
    }
    images.clear();
    videos.clear();
    selectedOption = 'text';
  }

  // Funcție care trigger-uieste callback-ul
  void triggerMediaChanged() {
    if (onMediaTap != null) {
      onMediaTap!();
    }
  }
}
