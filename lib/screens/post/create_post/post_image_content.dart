import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/screens/post/create_post/post_data.dart';
import 'package:zic_flutter/screens/shared/cropp_image.dart';
import 'package:zic_flutter/screens/shared/custom_toast.dart';

class PostImageContent extends StatefulWidget {
  final VoidCallback resetPost;
  final PostData postData;
  final VoidCallback validatePost;

  const PostImageContent({
    super.key,
    required this.resetPost,
    required this.postData,
    required this.validatePost,
  });

  @override
  State<PostImageContent> createState() => _PostImageContentState();
}

class _PostImageContentState extends State<PostImageContent> {
  final PageController _pageController = PageController(viewportFraction: 1.0);
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    widget.postData.textController.addListener(_validateForm);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getImages();
    });
  }

  Future getImages() async {
    final pickedFiles = await picker.pickMultiImage(
      maxHeight: 800,
      maxWidth: 800,
      limit: 4,
    );

    if (pickedFiles.isNotEmpty &&
        widget.postData.images.length + pickedFiles.length <= 4) {
      List<File> newImages =
          pickedFiles.map((pickedFile) => File(pickedFile.path)).toList();

      setState(() {
        widget.postData.images.addAll(newImages);
      });
    } else {
      if (pickedFiles.isNotEmpty) {
        CustomToast.show(context, 'Maximum 4 images allowed.');
      }
      print('No images selected or limit exceeded.');
    }
  }

  void removeImage(int index) {
    setState(() {
      widget.postData.images.removeAt(index);
      if (widget.postData.images.isEmpty) {
        widget.resetPost();
      }
    });
  }

  Future<void> _cropImage(int index) async {
    final croppedFile = await ImageCropperUtil.cropImage(
      context: context,
      imageFile: XFile(widget.postData.images[index].path),
    );

    if (croppedFile != null) {
      setState(() {
        widget.postData.images[index] = File(croppedFile.path);
      });
    }
  }

  @override
  void dispose() {
    widget.postData.textController.removeListener(_validateForm);
    super.dispose();
  }

  void _validateForm() {
    widget.validatePost();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: widget.postData.textController,
              onChanged: (value) {
                widget.validatePost(); // Adaugă această linie
              },
              decoration: const InputDecoration(
                hintText: "Add a comment...",
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
              ),
              maxLines: null,
              keyboardType: TextInputType.multiline,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    AppTheme.isDark(context)
                        ? const Color.fromARGB(92, 33, 33, 33)
                        : Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.postData.images.isNotEmpty)
                    SizedBox(
                      height: 300,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: widget.postData.images.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            // Add padding between pages
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4.0,
                            ),
                            child: Stack(
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 300,
                                  margin: const EdgeInsets.only(bottom: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    image: DecorationImage(
                                      image: FileImage(
                                        widget.postData.images[index],
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: CircleAvatar(
                                    backgroundColor: Colors.black54,
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                      ),
                                      onPressed: () => removeImage(index),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  if (widget.postData.images.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (widget.postData.images.length < 4)
                            IconButton(
                              icon: Icon(Icons.add_photo_alternate_rounded),
                              onPressed: getImages,
                            ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: Icon(Icons.crop_rounded),
                            onPressed:
                                () => _cropImage(
                                  _pageController.page?.toInt() ?? 0,
                                ),
                          ),
                        ],
                      ),
                    ),
                  if (widget.postData.images.isEmpty)
                    const SizedBox(height: 16),
                  if (widget.postData.images.isEmpty)
                    GestureDetector(
                      onTap: getImages,
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color:
                              AppTheme.isDark(context)
                                  ? const Color.fromARGB(92, 33, 33, 33)
                                  : Colors.grey[50],
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.grey300),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.photo_library_rounded,
                                size: 40,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Add Images",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
