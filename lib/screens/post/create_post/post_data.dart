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
  String selectedOption = 'text';

  void reset() {
    //textController.clear();
    urlController.clear();
    for (final controller in optionControllers) {
      controller.text = "";
    }
    images.clear();
    selectedOption = 'text';
  }
}
