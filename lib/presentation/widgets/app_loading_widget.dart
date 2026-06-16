import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/presentation/components/mascot_illustration.dart';

/// Shared inline loader — a thinking cat mascot that gently bobs while content
/// is fetched. Replaces the legacy `Loading.gif`.
class AppLoadingWidget extends StatelessWidget {
  const AppLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: MascotIllustration(
        mascotAsset: 'assets/images/cat-thinking.svg',
        tint: DSColors.tintLavender,
        size: 180,
      ),
    );
  }
}
