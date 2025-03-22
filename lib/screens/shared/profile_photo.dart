import 'package:flutter/material.dart';
import 'dart:io';

import 'package:zic_flutter/core/app_theme.dart';

class ProfilePhoto extends StatelessWidget {
  final String imagePath;
  final bool isAvatar;

  const ProfilePhoto({
    super.key,
    required this.imagePath,
    required this.isAvatar,
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
        // Modificarea este aici
        color: AppTheme.grey900, // Setează culoarea fundalului direct
        child: Center(
          child: InteractiveViewer(
            child:
                isAvatar
                    ? ImageWidget(
                      imagePath: imagePath,
                      size: 300,
                      fit: BoxFit.cover,
                      isAvatar: isAvatar,
                    )
                    : ImageWidget(
                      imagePath: imagePath,
                      size: double.infinity,
                      fit: BoxFit.contain,
                      isAvatar: isAvatar,
                    ),
          ),
        ),
      ),
    );
  }
}

class ImageWidget extends StatelessWidget {
  final String imagePath;
  final double size;
  final BoxFit fit;
  final bool isAvatar;

  const ImageWidget({
    super.key,
    required this.imagePath,
    required this.size,
    this.fit = BoxFit.cover,
    required this.isAvatar,
  });

  @override
  Widget build(BuildContext context) {
    Widget image;
    if (imagePath.startsWith("http")) {
      image = Image.network(imagePath, fit: fit);
    } else {
      image = Image.file(File(imagePath), fit: fit);
    }

    return isAvatar
        ? ClipOval(child: SizedBox(width: size, height: size, child: image))
        : SizedBox(width: size, height: size, child: image);
  }
}
