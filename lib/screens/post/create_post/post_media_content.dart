import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/screens/post/create_post/post_data.dart';
import 'package:zic_flutter/screens/shared/custom_toast.dart';

class PostMediaContent extends StatefulWidget {
  final VoidCallback resetPost;
  final PostData postData;
  final VoidCallback validatePost;

  const PostMediaContent({
    super.key,
    required this.resetPost,
    required this.postData,
    required this.validatePost,
  });

  @override
  State<PostMediaContent> createState() => _PostMediaContentState();
}

class _PostMediaContentState extends State<PostMediaContent> {
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    widget.postData.textController.addListener(_validateForm);
    widget.postData.onMediaTap = getImages;
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
    } else if (pickedFiles.isNotEmpty) {
      CustomToast.show(context, 'Maximum 4 images allowed.');
    }
    _validateForm();
  }

  void removeImage(int index) {
    setState(() {
      widget.postData.images.removeAt(index);
      _validateForm();
      if (widget.postData.images.isEmpty) {
        widget.resetPost();
      }
    });
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
      child: Column(
        children: [
          const SizedBox(height: 8),
          if (widget.postData.images.isNotEmpty)
            SizedBox(
              height: widget.postData.images.length > 1 ? 300 : null,
              child:
                  widget.postData.images.length > 1
                      ? ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount:
                            widget.postData.images.length +
                            1, // +1 pentru SizedBox
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return const SizedBox(
                              width: 50.0,
                            ); // Spațiul inițial
                          }
                          return _buildImageItem(
                            index - 1,
                          ); // -1 pentru a corecta indexul
                        },
                      )
                      : _buildImageItem(0),
            ),
          if (widget.postData.images.isEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 50.0),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: getImages,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.isDark(context) ? AppTheme.grey800 : AppTheme.grey100),
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
                          "Tap to add images",
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImageItem(int index) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () {},
      child: Padding(
        padding: EdgeInsets.only(
          right: 8.0,
          left: widget.postData.images.length > 1 ? 0 : 50
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            children: [
              Image.file(
                widget.postData.images[index],
                width:
                    widget.postData.images.length > 1 ? null : double.infinity,
                fit:
                    widget.postData.images.length > 1
                        ? BoxFit.cover
                        : BoxFit.contain,
              ),
              Positioned(
                top: 8,
                right: 8,
                child: CircleAvatar(
                  backgroundColor: Colors.black54,
                  radius: 16,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 16,
                    ),
                    onPressed: () => removeImage(index),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
