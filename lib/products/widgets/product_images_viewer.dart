// lib/product/widgets/product_images_viewer.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductImagesViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const ProductImagesViewer({
    super.key,
    required this.images,
    required this.initialIndex,
  });

  @override
  State<ProductImagesViewer> createState() => _ProductImagesViewerState();
}

class _ProductImagesViewerState extends State<ProductImagesViewer> {
  late final PageController _pageController;
  late int _currentIndex;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: widget.images.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return InteractiveViewer(
                  minScale: 1,
                  maxScale: 4,
                  child: Center(
                    child: CachedNetworkImage(
                      imageUrl: widget.images[index],
                      fit: BoxFit.contain,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.broken_image_outlined,
                        size: 100,
                        color: Colors.white54,
                      ),
                    ),
                  ),
                );
              },
            ),
            Positioned(
              top: 12,
              right: 12,
              child: Material(
                color: Colors.black.withOpacity(0.45),
                borderRadius: BorderRadius.circular(20),
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ),
            ),
            if (widget.images.length > 1)
              Positioned(
                bottom: 26,
                left: 0,
                right: 0,
                child: _buildDotsIndicator(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDotsIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.images.length, (index) {
        final isActive = index == _currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.white.withOpacity(0.45),
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}
