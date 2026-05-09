import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/presentation/components/ds_card.dart';

class PaywallValueProps extends StatelessWidget {
  const PaywallValueProps({super.key});

  static const _rows = <_Row>[
    _Row(label: 'Unlimited cats', free: false),
    _Row(label: 'Unlimited scans', free: false),
    _Row(label: 'Personalized assessments', free: true),
    _Row(label: 'Priority support', free: false),
  ];

  @override
  Widget build(BuildContext context) {
    return DSCard(
      padding: const EdgeInsets.all(DSDimens.sizeL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('What you get', style: DSTextStyles.titleMd),
              ),
              const SizedBox(
                width: 56,
                child: Text(
                  'Free',
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                width: 56,
                child: Text(
                  'Pro',
                  textAlign: TextAlign.center,
                  style: DSTextStyles.bodyMd.copyWith(
                    fontWeight: FontWeight.w700,
                    color: DSColors.accentSuccess,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: DSDimens.sizeS),
          for (var i = 0; i < _rows.length; i++) ...[
            if (i > 0) const Divider(height: DSDimens.sizeM, color: DSColors.surfaceCardDim),
            _ValueRow(row: _rows[i]),
          ],
        ],
      ),
    );
  }
}

class _Row {
  final String label;
  final bool free;
  const _Row({required this.label, required this.free});
}

class _ValueRow extends StatelessWidget {
  final _Row row;

  const _ValueRow({required this.row});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(row.label, style: DSTextStyles.bodyLg)),
        SizedBox(
          width: 56,
          child: Center(
            child: Icon(
              row.free ? Icons.check_rounded : Icons.close_rounded,
              color: row.free ? DSColors.inkSecondary : DSColors.inkTertiary,
              size: 20,
            ),
          ),
        ),
        SizedBox(
          width: 56,
          child: Center(
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: DSColors.accentSuccess,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.check_rounded,
                color: DSColors.inkInverse,
                size: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
