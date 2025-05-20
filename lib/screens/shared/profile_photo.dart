import 'package:flutter/material.dart';
import 'dart:io';

import 'package:zic_flutter/core/app_theme.dart';

class ProfilePhoto extends StatelessWidget {
  final String imagePath;

  const ProfilePhoto({
    super.key,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.grey900,
      appBar: AppBar(
        backgroundColor: AppTheme.grey900,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: AppTheme.grey900,
        child: Center(
          child: InteractiveViewer(
            clipBehavior: Clip.none,
            child: SizedBox( // Added SizedBox to control initial size
              width: 300,  // Adjust these values to change the initial size of the circle
              height: 300,
              child: ClipOval(
                child: ImageWidget(imagePath: imagePath),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ImageWidget extends StatelessWidget {
  final String imagePath;
  final BoxFit fit;

  const ImageWidget({
    super.key,
    required this.imagePath,
    this.fit = BoxFit.scaleDown,
  });

  @override
  Widget build(BuildContext context) {
    Widget image;
    if (imagePath.startsWith("http")) {
      image = Image.network(imagePath, fit: fit);
    } else {
      image = Image.file(File(imagePath), fit: fit);
    }
    return image;
  }
}
