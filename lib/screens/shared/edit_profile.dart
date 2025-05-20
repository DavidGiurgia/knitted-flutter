import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_avatar/flutter_advanced_avatar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:zic_flutter/core/api/user.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/providers/user_provider.dart';
import 'package:zic_flutter/core/services/cloudinaryService.dart';
import 'package:zic_flutter/screens/shared/cropp_image.dart';
import 'package:zic_flutter/widgets/button.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _fullnameController = TextEditingController();
  File? _avatar;
  bool _isLoading = false;
  String? avatarUrl, avatarPublicId;

  @override
  void initState() {
    super.initState();
    final userAsync = ref.read(userProvider);
    final user = userAsync.value;

    if (user == null) {
      return;
    }

    _bioController.text = user.bio;
    _fullnameController.text = user.fullname;
    avatarUrl = user.avatarUrl.isNotEmpty == true ? user.avatarUrl : null;
    avatarPublicId =
        user.avatarPublicId.isNotEmpty == true ? user.avatarPublicId : null;
  }

  Future<void> _pickImage(bool isAvatar) async {
    final croppedFile = await ImageCropperUtil.pickAndCropImage(
      rX: 1,
      rY: 1,
      cropStyle: CropStyle.circle,
      context: context,
    );

    if (croppedFile != null) {
      setState(() {
        _avatar = File(croppedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    final userAsync = ref.read(userProvider);
    final user = userAsync.value;

    if (user == null) {
      return;
    }

    try {
      // Upload or replace avatar if there's a new one
      if (_avatar != null) {
        var response =
            avatarPublicId != null && avatarPublicId!.isNotEmpty
                ? await CloudinaryService.replaceFile(_avatar!, avatarPublicId!)
                : await CloudinaryService.uploadFile(_avatar!);
        if (response != null) {
          avatarUrl = response['fileUrl'];
          avatarPublicId = response['publicId'];
        } else {
          throw Exception("Failed to upload new avatar");
        }
      } else if (avatarUrl == null && avatarPublicId != null) {
        // Delete avatar if it was removed
        bool deleted = await CloudinaryService.deleteFile(avatarPublicId!);
        if (!deleted) {
          throw Exception("Failed to delete previous avatar");
        }
        avatarPublicId = null;
      }

      // Update user profile
      await UserService.updateUser(
        user.id,
        _fullnameController.text.trim(),
        _bioController.text.trim(),
        avatarUrl ?? '',
        avatarPublicId ?? ''
      );
      Navigator.pop(context);
    } catch (error) {
      print("Error saving profile: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $error')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProvider);
    final user = userAsync.value;
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        actionsPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 8),
        actions: [
          CustomButton(
            onPressed: _saveProfile,
            text: 'Save',
            type: ButtonType.light,
            size: ButtonSize.small,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Profile Photo',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      (_avatar != null || avatarUrl != null)
                          ? Row(
                              children: [
                                TextButton(
                                  onPressed: () => _pickImage(true),
                                  child: Text(
                                    "Edit",
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _avatar = null;
                                      avatarUrl = null;
                                    });
                                  },
                                  child: Text(
                                    "Remove",
                                    style: TextStyle(
                                      color: Colors.red.shade300,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : TextButton(
                              onPressed: () => _pickImage(true),
                              child: Text(
                                "Add",
                                style: TextStyle(color: Colors.blue),
                              ),
                            ),
                    ],
                  ),
                  Center(
                    child: GestureDetector(
                      onTap: () => _pickImage(true),
                      child: AdvancedAvatar(
                        size: 96,
                        image: _avatar != null
                            ? FileImage(_avatar!)
                            : (avatarUrl != null
                                ? NetworkImage(avatarUrl!)
                                : null),
                        autoTextSize: true,
                        name: user?.fullname ?? '?',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.isDark(context)
                              ? AppTheme.grey200
                              : AppTheme.grey800,
                        ),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.isDark(context)
                              ? AppTheme.grey800
                              : AppTheme.grey200,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Name',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _fullnameController,
                    decoration: InputDecoration(
                      hintText: 'Enter your full name...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: Colors.grey.shade700),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Bio',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _bioController,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: 'Describe yourself...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide(color: Colors.grey.shade700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}