import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:yucat/config/themes/theme.dart';

class DSDotIndicator extends StatelessWidget {
  final PageController controller;
  final int count;

  const DSDotIndicator({
    super.key,
    required this.controller,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return SmoothPageIndicator(
      controller: controller,
      count: count,
      effect: const ExpandingDotsEffect(
        dotColor: Color(0xFFD7D7DD),
        activeDotColor: DSColors.inkPrimary,
        dotHeight: 8,
        dotWidth: 8,
        expansionFactor: 3,
        spacing: 6,
      ),
    );
  }
}
