import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/l10n/app_localizations.dart';

/// Full-screen, pinch-to-zoom view of one record's photo.
///
/// Pushed with a plain `MaterialPageRoute` rather than an AutoRoute page: it
/// carries one string and needs no deep link, so it is not worth a
/// `build_runner` cycle or a `router.gr.dart` entry.
class HealthAttachmentViewer extends StatelessWidget {
  final String imageUrl;

  const HealthAttachmentViewer({super.key, required this.imageUrl});

  static Future<void> open(BuildContext context, String imageUrl) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => HealthAttachmentViewer(imageUrl: imageUrl),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: DSColors.inkInverse,
        elevation: 0,
        title: Text(
          l10n.healthAttachmentViewerTitle,
          style: DSTextStyles.titleMd.copyWith(color: DSColors.inkInverse),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 1,
          maxScale: 5,
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, progress) => progress == null
                ? child
                : const CircularProgressIndicator(color: DSColors.inkInverse),
            errorBuilder: (_, __, ___) => const Icon(
              Icons.broken_image_outlined,
              color: DSColors.inkInverse,
              size: 48,
            ),
          ),
        ),
      ),
    );
  }
}
