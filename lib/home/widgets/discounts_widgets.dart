// lib/home/widgets/discounts_widgets.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DiscountsSlider extends StatefulWidget {
  const DiscountsSlider({super.key});

  @override
  State<DiscountsSlider> createState() => _DiscountsSliderState();
}

class _DiscountsSliderState extends State<DiscountsSlider> {
  final List<String> _images = const [
    'images/womendisc.png',
    'images/shoes.png',
    'images/pantsdisc.png',
    'images/accessories.png',
    'images/shoesdisc.png',
  ];

  late final PageController _pageController;
  Timer? _autoScrollTimer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.9);
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted || !_pageController.hasClients) {
        timer.cancel();
        return;
      }

      _currentPage = (_currentPage + 1) % _images.length;
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'discounts'.tr,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        AspectRatio(
          aspectRatio: 600 / 400,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _images.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double scale = 1.0;
                  double opacity = 1.0;

                  if (_pageController.position.haveDimensions) {
                    final page =
                        _pageController.page ?? _currentPage.toDouble();
                    final delta = (page - index).abs();
                    scale = (1 - (delta * 0.15)).clamp(0.85, 1.0);
                    opacity = (1 - (delta * 0.5)).clamp(0.5, 1.0);
                  }

                  return Center(
                    child: Opacity(
                      opacity: opacity,
                      child: Transform.scale(scale: scale, child: child),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: AspectRatio(
                      aspectRatio: 600 / 400,
                      child: Image.asset(_images[index], fit: BoxFit.cover),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_images.length, (index) {
            final bool isActive = index == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isActive ? 20 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: isActive
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.primary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }
}
