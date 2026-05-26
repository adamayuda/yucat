import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';

class PaywallValueProps extends StatelessWidget {
  const PaywallValueProps({super.key});

  static const _rows = <_Row>[
    _Row(label: 'Ingredient scanner', free: true),
    _Row(label: 'Personalized verdicts', free: false),
    _Row(label: 'Unlimited scans', free: false),
    _Row(label: 'Reformulation alerts', free: false),
    _Row(label: 'Saved foods & history', free: true),
    _Row(label: 'Multi-cat profiles', free: false),
  ];

  static const _colWidth = 56.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSDimens.sizeL,
        vertical: DSDimens.sizeL,
      ),
      decoration: BoxDecoration(
        color: DSColors.surfaceCard,
        borderRadius: BorderRadius.circular(DSRadii.xl),
        boxShadow: DSShadows.e1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('What you get', style: DSTextStyles.titleMd),
              ),
              SizedBox(
                width: _colWidth,
                child: Text(
                  'Free',
                  textAlign: TextAlign.center,
                  style: DSTextStyles.caption.copyWith(
                    color: DSColors.inkSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(
                width: _colWidth,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: DSDimens.sizeXxs,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: DSColors.accentSuccess,
                      borderRadius: BorderRadius.circular(DSRadii.sm),
                    ),
                    child: Text(
                      'Plus',
                      style: DSTextStyles.caption.copyWith(
                        color: DSColors.inkInverse,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: DSDimens.sizeS),
          Stack(
            children: [
              // Plus highlight stripe behind the Plus column
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: _colWidth + 4,
                  decoration: BoxDecoration(
                    color: DSColors.accentSuccessSoft,
                    borderRadius: BorderRadius.circular(DSRadii.md),
                    border: Border.all(
                      color: DSColors.accentSuccess.withValues(alpha: 0.35),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              Column(
                children: [
                  for (var i = 0; i < _rows.length; i++) ...[
                    _ValueRow(row: _rows[i], colWidth: _colWidth),
                    if (i < _rows.length - 1)
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: DSColors.surfaceCardDim,
                      ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Row {
  final String label;

  /// Whether the feature is available on the free tier.
  final bool free;

  const _Row({required this.label, required this.free});
}

class _ValueRow extends StatelessWidget {
  final _Row row;
  final double colWidth;

  const _ValueRow({required this.row, required this.colWidth});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DSDimens.sizeXs),
      child: Row(
        children: [
          Expanded(
            child: Text(
              row.label,
              style: DSTextStyles.bodyMd.copyWith(
                color: DSColors.inkPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            width: colWidth,
            child: Center(
              child: row.free
                  ? Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                        color: DSColors.accentSuccess,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: DSColors.inkInverse,
                        size: 14,
                      ),
                    )
                  : const Icon(
                      Icons.lock_outline_rounded,
                      color: DSColors.inkTertiary,
                      size: 18,
                    ),
            ),
          ),
          SizedBox(
            width: colWidth,
            child: Center(
              child: Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: DSColors.accentSuccess,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: DSColors.inkInverse,
                  size: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
