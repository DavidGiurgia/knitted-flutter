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
          fit: BoxFit.contain,
          width: double.infinity,
          placeholder:
              (context, url) => Container(
                color:
                    AppTheme.isDark(context)
                        ? Colors.grey[800]
                        : Colors.grey[200],
                height: 200,
              ),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
      ),
    );
  }

  Widget _buildMediaList(List<MediaItem> media) {
    return SizedBox(
      height: 300,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: media.length + 1, // +1 for the SizedBox
        itemBuilder: (context, index) {
          if (index == 0) {
            return const SizedBox(width: 64.0); // Initial spacing
          }
          return _buildMediaItem(media[index - 1], media.length > 1);
        },
      ),
    );
  }

  Widget _buildMediaItem(MediaItem media, bool isList) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: CachedNetworkImage(
            width: isList ? null : double.infinity,
            imageUrl: media.url,
            fit: isList ? BoxFit.cover : BoxFit.contain,
            placeholder:
                (context, url) => Container(
                  color:
                      AppTheme.isDark(context)
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
