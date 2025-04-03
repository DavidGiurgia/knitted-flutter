// image_cropper_util.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zic_flutter/core/app_theme.dart';

class ImageCropperUtil {
  static Future<File?> cropImage({
    required XFile imageFile,
    double rX = 1,
    double rY = 1,
    bool lockAspectRatio = true,
    CropStyle cropStyle = CropStyle.rectangle,
    required BuildContext context,
  }) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatio: CropAspectRatio(ratioX: rX, ratioY: rY),
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 100,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop',
          toolbarColor: AppTheme.primaryColor,
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: lockAspectRatio,
          cropStyle: cropStyle, //else default
          initAspectRatio: CropAspectRatioPreset.original,
          aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio4x3,
            ],
        ),
        IOSUiSettings(
          title: 'Crop',
          aspectRatioLockEnabled: lockAspectRatio,
          cropStyle: cropStyle,
        ),
      ],
    );

    if (croppedFile != null) {
      return File(croppedFile.path);
    }
    return null;
  }

  static Future<File?> pickAndCropImage({
    double rX = 1,
    double rY = 1,
    bool lockAspectRatio = true,
    CropStyle cropStyle = CropStyle.rectangle,
    required BuildContext context,
    ImageSource source = ImageSource.gallery,
  }) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: source,
    );

    if (pickedFile != null) {
      return await cropImage(
        imageFile: pickedFile,
        rX: rX,
        rY: rY,
        lockAspectRatio: lockAspectRatio,
        cropStyle: cropStyle,
        context: context,
      );
    }
    return null;
  }
}
