import 'package:flutter/material.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/models/media_post.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:zic_flutter/core/models/post.dart';

class PostMedia extends StatelessWidget {
  final Post post;

  const PostMedia({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    if (post is! MediaPost) {
      debugPrint("Post claims to be MediaPost but isn't");
      return const SizedBox.shrink();
    }

    final mediaPost = post as MediaPost;

    return Column(
      children: [
        const SizedBox(height: 2),
        if (mediaPost.media.length == 1)
          _buildSingleMedia(mediaPost.media.first)
        else
          _buildMediaList(mediaPost.media),
      ],
    );
  }

  Widget _buildSingleMedia(MediaItem media) {
    return Padding(
      padding: const EdgeInsets.only(left: 64.0, right: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: CachedNetworkImage(
          imageUrl: media.url,
          fit: BoxFit.cover, // Changed to BoxFit.cover
          width: double.infinity,
          height: null, // Added height to match the list view
          placeholder: (context, url) => Container(
            color: AppTheme.isDark(context)
                ? Colors.grey[800]
                : Colors.grey[200],
            height: 250, // Added height to match the list view
          ),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
      ),
    );
  }

  Widget _buildMediaList(List<MediaItem> media) {
    return SizedBox(
      height: 250, // Set a fixed height for the image display area
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: media.length + 1, // Adaugă 1 pentru spațiul inițial
        itemBuilder: (context, index) {
          if (index == 0) {
            return const SizedBox(width: 60); // Spațiul inițial
          }
          return _buildMediaItem(media[index - 1]);
        },
      ),
    );
  }

  Widget _buildMediaItem(MediaItem media) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0), // Removed conditional left padding
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 250,  // Added fixed width
          height: 250, // Added fixed height
          child: CachedNetworkImage(
            imageUrl: media.url,
            width: 250,  // Added fixed width, redundant but kept for clarity
            height: 250, // Added fixed height, redundant but kept for clarity
            fit: BoxFit.cover, // Use BoxFit.cover
            placeholder: (context, url) => Container(
              color: AppTheme.isDark(context)
                  ? Colors.grey[800]
                  : Colors.grey[200],
            ),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
        ),
      ),
    );
  }
}

