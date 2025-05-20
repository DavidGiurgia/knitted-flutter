import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ImageCarousel extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;
  final Axis scrollDirection;
  final bool allowSwipeToDismiss;
  final Color? backgroundColor;

  const ImageCarousel({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
    this.scrollDirection = Axis.horizontal,
    this.allowSwipeToDismiss = true,
    this.backgroundColor,
  });

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  late final PageController _pageController;
  late int _currentIndex;
  double _opacity = 1.0;
  double _verticalOffset = 0;
  bool _isClosing = false;
  bool _isScaling = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _handleDismiss() async {
    if (_isClosing) return;
    _isClosing = true;

    setState(() {
      _opacity = 0.0;
      _verticalOffset = 40;
    });
    
    if (mounted) Navigator.of(context).pop();
  }

  Widget _buildImage(String url, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Hero(
      tag: 'image_$url',
      child: CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.contain,
        memCacheWidth: (screenWidth * 3).round(),
        progressIndicatorBuilder: (_, __, progress) => Center(
          child: SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(
              value: progress.progress,
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(Colors.white.withOpacity(0.8)),
            ),
          ),
        ),
        errorWidget: (_, __, ___) => Center(
          child: Icon(
            Icons.broken_image,
            color: Colors.white.withOpacity(0.5),
            size: 40,
          ),
        ),
        fadeInDuration: const Duration(milliseconds: 150),
        fadeInCurve: Curves.easeOut,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = widget.backgroundColor ?? Colors.black;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) await _handleDismiss();
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.fastOutSlowIn,
          transform: Matrix4.identity()..translate(0.0, _verticalOffset),
          child: AnimatedOpacity(
            opacity: _opacity,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            child: Stack(
              children: [
                // Main Gallery with optimized gestures
                GestureDetector(
                  onVerticalDragUpdate: widget.allowSwipeToDismiss && !_isScaling
                      ? (details) {
                          final delta = details.primaryDelta!;
                          setState(() {
                            _verticalOffset = delta;
                            _opacity = 1.0 - (delta.abs() / 300).clamp(0.0, 0.8);
                          });
                        }
                      : null,
                  onVerticalDragEnd: widget.allowSwipeToDismiss && !_isScaling
                      ? (details) {
                          if (_opacity < 0.7 || details.primaryVelocity! > 800) {
                            _handleDismiss();
                          } else {
                            setState(() {
                              _verticalOffset = 0;
                              _opacity = 1.0;
                            });
                          }
                        }
                      : null,
                  child: PhotoViewGallery.builder(
                    pageController: _pageController,
                    itemCount: widget.imageUrls.length,
                    onPageChanged: (index) => setState(() => _currentIndex = index),
                    scrollPhysics: const BouncingScrollPhysics(),
                    backgroundDecoration: BoxDecoration(color: backgroundColor),
                    scrollDirection: widget.scrollDirection,
                    builder: (context, index) {
                      return PhotoViewGalleryPageOptions.customChild(
                        child: _buildImage(widget.imageUrls[index], context),
                        minScale: PhotoViewComputedScale.contained,
                        maxScale: PhotoViewComputedScale.covered * 2.5,
                        initialScale: PhotoViewComputedScale.contained,
                        
                        onScaleEnd: (_, __, ___) => setState(() => _isScaling = false),
                      );
                    },
                    loadingBuilder: (context, event) => Center(
                      child: SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(
                            Colors.white.withOpacity(0.8)),
                          value: event?.cumulativeBytesLoaded.toDouble() ?? 0 / 
                                (event?.expectedTotalBytes?.toDouble() ?? 1),
                        ),
                      ),
                    ),
                  ),
                ),

                // Top close button
                Positioned(
                  top: MediaQuery.of(context).padding.top + 12,
                  left: 12,
                  child: SafeArea(
                    child: GestureDetector(
                      onTap: _handleDismiss,
                      child: AnimatedOpacity(
                        opacity: _verticalOffset.abs() < 50 ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 100),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Bottom indicator with improved visuals
                if (widget.imageUrls.length > 1)
                  Positioned(
                    bottom: MediaQuery.of(context).padding.bottom + 20,
                    left: 0,
                    right: 0,
                    child: SafeArea(
                      child: AnimatedOpacity(
                        opacity: _verticalOffset.abs() < 50 ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 100),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(widget.imageUrls.length, (index) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: _currentIndex == index ? 24 : 8,
                              height: 4,
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                color: _currentIndex == index
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.4),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}