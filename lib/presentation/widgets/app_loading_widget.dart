import 'package:flutter/material.dart';

class AppLoadingWidget extends StatelessWidget {
  const AppLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        'assets/images/Illustrations/Animate This Illustration.webp',
        width: 200,
        height: 200,
      ),
    );
  }
}
