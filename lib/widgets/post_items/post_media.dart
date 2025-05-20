import 'package:flutter/material.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/models/media_post.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:zic_flutter/core/models/post.dart';
import 'package:zic_flutter/widgets/post_items/fullscreen_carousel.dart';

class PostMedia extends StatelessWidget {
  final Post post;

  const PostMedia({super.key, required this.post});

  void _openFullScreenCarousel(BuildContext context, int initialIndex) {
    if (post is! MediaPost) return;

    final mediaPost = post as MediaPost;
    final imageUrls = mediaPost.media.map((m) => m.url).toList();

    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder:
            (_, __, ___) =>
                ImageCarousel(imageUrls: imageUrls, initialIndex: initialIndex),
        transitionsBuilder: (context, animation, _, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutQuad,
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 200),
      ),
    );
  }

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
          _buildSingleMedia(mediaPost.media.first, context)
        else
          _buildMediaList(mediaPost.media, context),
      ],
    );
  }

  Widget _buildSingleMedia(MediaItem media, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 64.0, right: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 400),
          child: GestureDetector(
            onTap: () => _openFullScreenCarousel(context, 0),
            child: Hero(
              tag: 'image_${media.url}',
              child: CachedNetworkImage(
                imageUrl: media.url,
                fit: BoxFit.cover,
                width: null,
                height: null,
                memCacheWidth: (MediaQuery.of(context).size.width * 2).round(),
                placeholder: (context, url) => _buildPlaceholder(context),
                errorWidget: (context, url, error) => _buildErrorWidget(),
                fadeInDuration: const Duration(milliseconds: 150),
                fadeInCurve: Curves.easeOut,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMediaList(List<MediaItem> media, BuildContext context) {
    return SizedBox(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: media.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return const SizedBox(width: 60);
          }
          return _buildMediaItem(media[index - 1], context);
        },
      ),
    );
  }

  Widget _buildMediaItem(MediaItem media, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 280, minWidth: 180),
          child: SizedBox(
            width: null,
            height: 250,
            child: GestureDetector(
              onTap: () {
                final mediaPost = post as MediaPost;
                final index = mediaPost.media.indexOf(media);
                _openFullScreenCarousel(context, index);
              },
              child: Hero(
                tag: 'image_${media.url}',
                child: CachedNetworkImage(
                  imageUrl: media.url,
                  width: null,
                  height: 250,
                  fit: BoxFit.cover,
                  memCacheWidth: 800,
                  placeholder: (context, url) => _buildPlaceholder(context),
                  errorWidget: (context, url, error) => _buildErrorWidget(),
                  fadeInDuration: const Duration(milliseconds: 150),
                  fadeInCurve: Curves.easeOut,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      color: AppTheme.isDark(context) ? Colors.grey[800] : Colors.grey[200],
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppTheme.isDark(context) ? Colors.grey[600] : Colors.grey[400],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return const Center(child: Icon(Icons.error, color: Colors.grey));
  }
}
