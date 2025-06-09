import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/providers/post_creation_notifier.dart.dart';
import 'package:zic_flutter/screens/post/create_post/post_create_state.dart';
import 'package:zic_flutter/screens/shared/custom_toast.dart';

class PostMediaContent extends ConsumerStatefulWidget {
  const PostMediaContent({super.key});

  @override
  ConsumerState<PostMediaContent> createState() => _PostMediaContentState();
}


class _PostMediaContentState extends ConsumerState<PostMediaContent> {
  @override
  void initState() {
    super.initState();
    // Trigger image picker automatically when the widget is built.
    // Ensure it runs after the first frame to avoid build context issues.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pickImages(context, ref);
    });
  }

  Future<void> _pickImages(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(postCreationNotifierProvider.notifier);
    final currentImages = ref.read(postCreationNotifierProvider).images;

    // Calculate the number of images that can still be picked.
    // Assuming a maximum of 4 images allowed.
    final int maxImagesAllowed = 4;
    final int imagesToPick = maxImagesAllowed - currentImages.length;

     // If no more images can be picked, show a toast and return.
    if (imagesToPick <= 0) {
      if (context.mounted) {
        CustomToast.show(context, 'Maximum $maxImagesAllowed images allowed.');
      }
      return;
    }


    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage(
      imageQuality: 70, // Adjust image quality
      maxHeight: 800,
      maxWidth: 800,
      limit: imagesToPick, // Limit based on remaining slots
    );

    if (pickedFiles.isNotEmpty) {
      final List<File> newImages =
          pickedFiles.map((pickedFile) => File(pickedFile.path)).toList();

      // Call the notifier method to add images
      notifier.addImages(newImages);
    } 
  }

  // Method to remove an image, now directly calling notifier method
  void _removeImage(int index, WidgetRef ref) {
    // Call the notifier method to remove the image
    ref.read(postCreationNotifierProvider.notifier).removeImage(index);

    // After removing, check if the images list is now empty.
    final currentImages = ref.read(postCreationNotifierProvider).images;
    if (currentImages.isEmpty) {
      _removeMediaContent(ref.read(postCreationNotifierProvider.notifier));
    }
  }

  void _removeMediaContent(PostCreationNotifier notifier) {
    notifier.updateField('images', []);
    notifier.updateField('selectedPostType', 'text'); // Or your default type
  }

  @override
  Widget build(BuildContext context) {
    final postCreationState = ref.watch(postCreationNotifierProvider);
    final images = postCreationState.images;

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 8),
          if (images.isNotEmpty)
            SizedBox(
              height: images.length > 1 ? 300 : null,
              child:
                  images.length > 1
                      ? ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: images.length + 1, // +1 pentru SizedBox
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return const SizedBox(
                              width: 50.0,
                            ); // Spațiul inițial
                          }
                          return _buildImageItem(
                            context,
                            ref,
                            index - 1,
                          ); // index - 1 ???
                        },
                      )
                      : _buildImageItem(context, ref, 0),
            ),
          if (images.isEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 50.0),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => _pickImages(context, ref),
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color:
                          AppTheme.isDark(context)
                              ? AppTheme.grey800
                              : AppTheme.grey100,
                    ),
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
          const SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => _removeMediaContent(ref.read(postCreationNotifierProvider.notifier)),
                child: const Text(
                  "Remove media",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageItem(BuildContext context, WidgetRef ref, int index) {
    final postCreationState = ref.watch(
      postCreationNotifierProvider,
    ); // Watch here for images
    final images = postCreationState.images; // Access images from state

    final isMultipleImages = images.length > 1;
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () {},
      child: Padding(
        padding: EdgeInsets.only(right: 8.0, left: isMultipleImages ? 0 : 50),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            children: [
              Image.file(
                images[index],
                width: isMultipleImages ? 250 : null,
                height: isMultipleImages ? 300 : null,
                fit: isMultipleImages ? BoxFit.cover : BoxFit.contain,
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
                    onPressed: () => _removeImage(index, ref),
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
