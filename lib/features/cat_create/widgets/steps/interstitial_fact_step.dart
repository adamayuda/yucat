import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';

/// Non-input "did you know" interstitial shown between wizard form steps.
/// Breaks up the questionnaire with a brief "why this matters" beat.
class InterstitialFactStep extends StatelessWidget {
  final IconData icon;
  final Color accent;

  /// Headline text. The [highlight] substring (if present) is tinted [accent].
  final String headline;
  final String highlight;
  final String body;

  /// Placeholder citation copy. Replace with a real veterinary source.
  // TODO: swap placeholder citation for a real veterinary nutrition source.
  final String? citation;

  const InterstitialFactStep({
    super.key,
    required this.icon,
    required this.accent,
    required this.headline,
    required this.highlight,
    required this.body,
    this.citation,
  });

  @override
  Widget build(BuildContext context) {
    final parts = headline.split(highlight);
    final hasHighlight = highlight.isNotEmpty && parts.length == 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Spacer(flex: 1),
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: DSColors.surfaceCard,
            shape: BoxShape.circle,
            boxShadow: DSShadows.e2,
          ),
          child: Icon(icon, color: accent, size: 48),
        ),
        const SizedBox(height: DSDimens.size3xl),
        if (hasHighlight)
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: parts[0]),
                TextSpan(
                  text: highlight,
                  style: TextStyle(color: accent),
                ),
                TextSpan(text: parts[1]),
              ],
            ),
            textAlign: TextAlign.center,
            style: DSTextStyles.displayLg,
          )
        else
          Text(
            headline,
            textAlign: TextAlign.center,
            style: DSTextStyles.displayLg,
          ),
        const SizedBox(height: DSDimens.sizeS),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: DSDimens.sizeS),
          child: Text(
            body,
            textAlign: TextAlign.center,
            style: DSTextStyles.bodyLg.copyWith(color: DSColors.inkSecondary),
          ),
        ),
        const Spacer(flex: 2),
        if (citation != null) _CitationCard(text: citation!),
      ],
    );
  }
}

class _CitationCard extends StatelessWidget {
  final String text;

  const _CitationCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DSDimens.sizeS),
      decoration: BoxDecoration(
        color: DSColors.surfaceCard,
        borderRadius: BorderRadius.circular(DSRadii.lg),
        boxShadow: DSShadows.e1,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.menu_book_rounded,
            size: 20,
            color: DSColors.inkSecondary,
          ),
          const SizedBox(width: DSDimens.sizeXs),
          Expanded(
            child: Text(
              text,
              style: DSTextStyles.caption.copyWith(
                color: DSColors.inkSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
