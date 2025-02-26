import 'dart:ui';

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
      backgroundColor: AppTheme.backgroundColor(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Blur background
          Positioned.fill(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX:2, sigmaY: 2),
              child: Opacity(
                opacity: 0.1,
                child: ImageWidget(
                  imagePath: imagePath,
                  size: double.infinity,
                  aspectRatio: isAvatar ? 1 : 2,
                ),
              ),
            ),
          ),

          // Main image with zoom and pan
          Center(
            child: InteractiveViewer(
              // maxScale: 3.0,
              // minScale: 1.0,
              child: isAvatar
                  ? ClipOval(
                      child: ImageWidget(imagePath: imagePath, size: 300, aspectRatio: 1,),
                    )
                  : ClipRRect(
                      //borderRadius: BorderRadius.circular(10),
                      child: ImageWidget(imagePath: imagePath, size: 800, aspectRatio: 2,),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class ImageWidget extends StatelessWidget {
  final String imagePath;
  final double size;
  final double? aspectRatio;

  const ImageWidget({
    super.key,
    required this.imagePath,
    required this.size,
    this.aspectRatio,
  });

  @override
  Widget build(BuildContext context) {
    Widget image = imagePath.startsWith("http")
        ? Image.network(imagePath, fit: BoxFit.cover)
        : Image.file(File(imagePath), fit: BoxFit.cover);

    return aspectRatio != null
        ? AspectRatio(
            aspectRatio: aspectRatio!,
            child: SizedBox(width: size, child: image),
          )
        : SizedBox(width: size, height: size, child: image);
  }
}
