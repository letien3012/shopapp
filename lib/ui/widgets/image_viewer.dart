import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ImageViewer extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const ImageViewer({
    Key? key,
    required this.imageUrls,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  State<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer>
    with SingleTickerProviderStateMixin {
  late int currentIndex;
  late PageController pageController;
  double _dragOffset = 0;
  final double _dragThreshold = 150;
  Offset? _startPosition;
  late AnimationController _animationController;
  late Animation<double> _animation;
  late PhotoViewController _photoViewController;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    pageController = PageController(initialPage: widget.initialIndex);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _photoViewController = PhotoViewController();
  }

  @override
  void dispose() {
    pageController.dispose();
    _animationController.dispose();
    _photoViewController.dispose();
    super.dispose();
  }

  void _handleDragStart(DragStartDetails details) {
    _startPosition = details.globalPosition;
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (_startPosition == null) return;

    setState(() {
      _dragOffset += details.delta.dy;
      _dragOffset = _dragOffset.clamp(0.0, MediaQuery.of(context).size.height);
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_dragOffset >= _dragThreshold) {
      _animateAndPop();
    } else {
      setState(() {
        _dragOffset = 0;
        _startPosition = null;
      });
    }
  }

  void _animateAndPop() {
    _animationController.forward().then((_) {
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final progress = (_dragOffset / size.height).clamp(0.0, 1.0);
    final scale = 1 - (progress * 0.6);
    final opacity = 1 - progress;

    // Tính toán vị trí thu nhỏ về góc trái
    final translateX = -(progress * size.width * 0.5);
    final translateY = progress * size.height * 0.3;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final animProgress = _animation.value;
        final finalScale = scale * (1 - animProgress * 0.5);
        final finalTranslateX = translateX - (animProgress * size.width * 0.3);
        final finalTranslateY = translateY + (animProgress * size.height * 0.2);
        final finalOpacity = opacity * (1 - animProgress);

        return Scaffold(
          backgroundColor: Colors.black.withOpacity(finalOpacity),
          body: GestureDetector(
            onVerticalDragStart: _handleDragStart,
            onVerticalDragUpdate: _handleDragUpdate,
            onVerticalDragEnd: _handleDragEnd,
            child: Transform(
              transform: Matrix4.identity()
                ..translate(finalTranslateX, finalTranslateY)
                ..scale(finalScale),
              alignment: Alignment.topLeft,
              child: Stack(
                children: [
                  PhotoViewGallery.builder(
                    scrollPhysics: const BouncingScrollPhysics(),
                    builder: (BuildContext context, int index) {
                      return PhotoViewGalleryPageOptions(
                        controller: _photoViewController,
                        imageProvider: NetworkImage(widget.imageUrls[index]),
                        initialScale: PhotoViewComputedScale.contained,
                        minScale: PhotoViewComputedScale.contained,
                        maxScale: PhotoViewComputedScale.covered * 3,
                        heroAttributes:
                            PhotoViewHeroAttributes(tag: "image_$index"),
                        onScaleEnd: (context, details, value) {
                          final minScale =
                              PhotoViewComputedScale.contained.multiplier;
                          if (value.scale! < minScale) {
                            _photoViewController.scale = minScale;
                          }
                        },
                      );
                    },
                    itemCount: widget.imageUrls.length,
                    loadingBuilder: (context, event) => Center(
                      child: Container(
                        width: 20.0,
                        height: 20.0,
                        child: CircularProgressIndicator(
                          value: event == null
                              ? 0
                              : event.cumulativeBytesLoaded /
                                  event.expectedTotalBytes!,
                        ),
                      ),
                    ),
                    backgroundDecoration: BoxDecoration(
                      color: Colors.transparent,
                    ),
                    pageController: pageController,
                    onPageChanged: (index) {
                      setState(() {
                        currentIndex = index;
                      });
                    },
                  ),
                  // Close button
                  Positioned(
                    top: 40,
                    right: 20,
                    child: Opacity(
                      opacity: finalOpacity,
                      child: IconButton(
                        icon: const Icon(Icons.close,
                            color: Colors.white, size: 30),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ),
                  // Image counter
                  Positioned(
                    top: 40,
                    left: 20,
                    child: Opacity(
                      opacity: finalOpacity,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          '${currentIndex + 1}/${widget.imageUrls.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
