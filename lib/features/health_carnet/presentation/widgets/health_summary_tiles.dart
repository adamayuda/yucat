import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/l10n/app_localizations.dart';

/// The two cards under the header: latest weight, and how much is outstanding.
///
/// A local widget rather than `DSStatPill`, which lays its stat and description
/// out in a row — the mockup stacks a small caps label over a large value.
class HealthSummaryTiles extends StatelessWidget {
  final String weightValue;
  final String? weightDelta;

  /// True when [weightDelta] is a gain, which tints it green. Losses and the
  /// no-data case stay neutral: unexplained weight loss in a cat is a reason to
  /// see a vet, and colouring it red here would be the app making a call it
  /// isn't qualified to make.
  final bool weightDeltaPositive;
  final int todoCount;
  final String todoCaption;

  const HealthSummaryTiles({
    super.key,
    required this.weightValue,
    required this.weightDelta,
    required this.weightDeltaPositive,
    required this.todoCount,
    required this.todoCaption,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: _Tile(
            label: l10n.healthCarnetStatWeightLabel,
            value: weightValue,
            caption: weightDelta,
            captionColor: weightDeltaPositive
                ? DSColors.accentSuccess
                : DSColors.inkTertiary,
          ),
        ),
        const SizedBox(width: DSDimens.sizeXs),
        Expanded(
          child: _Tile(
            label: l10n.healthCarnetStatTodoLabel,
            value: '$todoCount',
            caption: todoCaption,
            captionColor: DSColors.inkTertiary,
          ),
        ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  final String label;
  final String value;
  final String? caption;
  final Color captionColor;

  const _Tile({
    required this.label,
    required this.value,
    required this.caption,
    required this.captionColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DSDimens.sizeS),
      decoration: BoxDecoration(
        color: DSColors.surfaceCard,
        borderRadius: BorderRadius.circular(DSRadii.lg),
        boxShadow: DSShadows.e1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: DSTextStyles.caption.copyWith(
              letterSpacing: 0.6,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: DSDimens.sizeXxs),
          Text(value, style: DSTextStyles.headlineMd),
          const SizedBox(height: DSDimens.sizeXxxs),
          Text(
            caption ?? '',
            style: DSTextStyles.bodyMd.copyWith(color: captionColor),
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}
