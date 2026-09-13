import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/health_carnet/presentation/utils/cat_health_schedule.dart';
import 'package:yucat/features/health_carnet/presentation/utils/health_date_format.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/ds_card.dart';

/// Monthly weight bars.
///
/// Built from plain widgets rather than a `CustomPainter`. The project has no
/// charting package, and its one chart-shaped component — `LineChartCard` — is a
/// marketing illustration whose painter takes **no data at all** (both curves are
/// hardcoded canvas fractions) and which nothing references. For a handful of
/// monthly bars, a `Row` of `FractionallySizedBox` columns gets animation and tap
/// targets for free and stays readable.
class WeightChartCard extends StatelessWidget {
  final List<WeightPoint> buckets;

  const WeightChartCard({super.key, required this.buckets});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = healthLocaleOf(context);
    final scale = _Scale.forValues(buckets.map((b) => b.kg).toList());

    return DSCard(
      padding: const EdgeInsets.all(DSDimens.sizeS),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.healthCarnetWeightChartTitle,
                  style: DSTextStyles.titleMd,
                ),
              ),
              Text(
                l10n.healthCarnetWeightChartSubtitle(buckets.length),
                style: DSTextStyles.bodyMd.copyWith(
                  color: DSColors.inkTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSDimens.sizeS),
          SizedBox(
            height: 132,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final bucket in buckets)
                  Expanded(
                    child: _Bar(
                      value: bucket.kg,
                      heightFactor: scale.factorFor(bucket.kg),
                      label: healthFormatMonthShort(bucket.date, locale),
                      valueLabel: healthFormatKg(bucket.kg, locale),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Maps weights onto bar heights.
///
/// ⚠️ The axis is **zoomed to the data**, not anchored at zero — otherwise a cat
/// moving 4.5 → 4.8 kg renders as five bars of identical height and the card
/// says nothing. The cost is that small changes look large, which for a health
/// metric could alarm someone over 100 g of normal fluctuation. The mitigation
/// is that **every bar is labelled with its actual value**, so the number always
/// overrides the impression the shape gives. Keep that label.
class _Scale {
  final double low;
  final double high;

  const _Scale({required this.low, required this.high});

  factory _Scale.forValues(List<double> values) {
    if (values.isEmpty) return const _Scale(low: 0, high: 1);
    final min = values.reduce(math.min);
    final max = values.reduce(math.max);
    final span = max - min;
    // A flat series (or a single reading) has no span to zoom into; give it a
    // fixed half-kilo window so the bars sit mid-height instead of collapsing.
    if (span < 0.05) return _Scale(low: min - 0.5, high: max + 0.25);
    return _Scale(low: min - span * 0.6, high: max + span * 0.25);
  }

  double factorFor(double value) =>
      ((value - low) / (high - low)).clamp(0.08, 1.0);
}

class _Bar extends StatelessWidget {
  final double value;
  final double heightFactor;
  final String label;
  final String valueLabel;

  const _Bar({
    required this.value,
    required this.heightFactor,
    required this.label,
    required this.valueLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DSDimens.sizeXxxs),
      child: Column(
        children: [
          Text(
            valueLabel,
            style: DSTextStyles.label,
            maxLines: 1,
          ),
          const SizedBox(height: DSDimens.sizeXxs),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: heightFactor,
                child: AnimatedContainer(
                  duration: DSMotion.durMed,
                  curve: DSMotion.curveStandard,
                  decoration: BoxDecoration(
                    color: DSColors.accentInfo,
                    borderRadius: BorderRadius.circular(DSRadii.sm),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: DSDimens.sizeXxs),
          Text(
            label,
            style: DSTextStyles.caption,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}
