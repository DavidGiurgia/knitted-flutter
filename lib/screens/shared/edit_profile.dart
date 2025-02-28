import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_avatar/flutter_advanced_avatar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:provider/provider.dart';
import 'package:zic_flutter/core/api/user.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/providers/user_provider.dart';
import 'package:zic_flutter/core/services/cloudinaryService.dart';
import 'package:zic_flutter/widgets/button.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _bioController = TextEditingController();
  File? _avatar;
  File? _cover;
  bool _isLoading = false;
  String? avatarUrl, avatarPublicId, coverUrl, coverPublicId;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false).user;
    _bioController.text = user?.bio ?? '';
    avatarUrl = user?.avatarUrl.isNotEmpty == true ? user?.avatarUrl : null;
    avatarPublicId = user?.avatarPublicId.isNotEmpty == true ? user?.avatarPublicId : null;
    coverUrl = user?.coverUrl.isNotEmpty == true ? user?.coverUrl : null;
    coverPublicId = user?.coverPublicId.isNotEmpty == true ? user?.coverPublicId : null;
  }

  Future<void> _pickImage(bool isAvatar) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio:
            isAvatar
                ? const CropAspectRatio(ratioX: 1, ratioY: 1)
                : const CropAspectRatio(ratioX: 4, ratioY: 2),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop',
            toolbarColor: AppTheme.primaryColor,
            toolbarWidgetColor: Colors.white,
            lockAspectRatio: true,
            cropStyle: isAvatar ? CropStyle.circle : CropStyle.rectangle,
            initAspectRatio: CropAspectRatioPreset.original,
          ),
          IOSUiSettings(
            title: 'Crop',
            aspectRatioLockEnabled: true,
            cropStyle: isAvatar ? CropStyle.circle : CropStyle.rectangle,
          ),
        ],
      );

      if (croppedFile != null) {
        setState(() {
          if (isAvatar) {
            _avatar = File(croppedFile.path);
          } else {
            _cover = File(croppedFile.path);
          }
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;

    try {
      // Înlocuiește avatarul dacă există unul nou
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
        // Șterge avatarul dacă a fost eliminat
        bool deleted = await CloudinaryService.deleteFile(avatarPublicId!);
        if (!deleted) {
          throw Exception("Failed to delete previous avatar");
        }
        avatarPublicId = null;
      }

      // Înlocuiește cover-ul dacă există unul nou
      if (_cover != null) {
        var response =
            coverPublicId != null && coverPublicId!.isNotEmpty
                ? await CloudinaryService.replaceFile(_cover!, coverPublicId!)
                : await CloudinaryService.uploadFile(_cover!);
        if (response != null) {
          coverUrl = response['fileUrl'];
          coverPublicId = response['publicId'];
        } else {
          throw Exception("Failed to upload new cover");
        }
      } else if (coverUrl == null && coverPublicId != null) {
        // Șterge cover-ul dacă a fost eliminat
        bool deleted = await CloudinaryService.deleteFile(coverPublicId!);
        if (!deleted) {
          throw Exception("Failed to delete previous cover");
        }
        coverPublicId = null;
      }

      // Actualizează profilul utilizatorului
      await UserService.updateUser(
        user!.id,
        _bioController.text.trim(),
        avatarUrl ?? '',
        avatarPublicId ?? '',
        coverUrl ?? '',
        coverPublicId ?? '',
      );

      await userProvider.loadUser();
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
    final user = Provider.of<UserProvider>(context).user;
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
      body:
          _isLoading
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
                          image:
                              _avatar != null
                                  ? FileImage(_avatar!)
                                  : (avatarUrl != null
                                      ? NetworkImage(avatarUrl!)
                                      : null),
                          autoTextSize: true,
                          name: user?.fullname ?? '?',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color:
                                AppTheme.isDark(context)
                                    ? AppTheme.grey200
                                    : AppTheme.grey800,
                          ),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                AppTheme.isDark(context)
                                    ? AppTheme.grey800
                                    : AppTheme.grey200, // Background fallback
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Cover Photo',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        (_cover != null || coverUrl != null)
                            ? Row(
                              children: [
                                TextButton(
                                  onPressed: () => _pickImage(false),
                                  child: Text(
                                    "Edit",
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _cover = null;
                                      coverUrl = null;
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
                              onPressed: () => _pickImage(false),
                              child: Text(
                                "Add",
                                style: TextStyle(color: Colors.blue),
                              ),
                            ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => _pickImage(false),
                      child: Container(
                        height: 160,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color:
                              AppTheme.isDark(context)
                                  ? Colors.grey[900]
                                  : Colors.grey[100],
                          image: DecorationImage(
                            image:
                                _cover != null
                                    ? FileImage(_cover!)
                                    : (coverUrl != null
                                        ? NetworkImage(coverUrl!)
                                        : AssetImage('')),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child:
                            _cover == null && coverUrl == null
                                ? Icon(
                                  Icons.image,
                                  size: 50,
                                  color:
                                      AppTheme.isDark(context)
                                          ? Colors.grey[700]
                                          : Colors.grey[300],
                                )
                                : null,
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
                      //expands: true,
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
