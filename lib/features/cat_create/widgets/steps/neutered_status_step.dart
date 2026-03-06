import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';

class NeuteredStatusStep extends StatelessWidget {
  /// One of: "intact", "neutered", "pregnant", "lactating"
  final String? status;
  final ValueChanged<String?> onStatusChanged;

  static const List<Map<String, String>> _options = [
    {'value': 'intact', 'label': 'Intact'},
    {'value': 'neutered', 'label': 'Neutered / Spayed'},
    {'value': 'pregnant', 'label': 'Pregnant'},
    {'value': 'lactating', 'label': 'Lactating'},
  ];

  const NeuteredStatusStep({
    super.key,
    required this.status,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: DSColors.primaryLight,
                  borderRadius: BorderRadius.circular(DSDimens.sizeXxs),
                ),
                width: 40,
                height: 40,
                child: Image.asset(
                  'assets/images/Icons/syringe.png',
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(width: DSDimens.sizeS),
              Expanded(
                child: Text(
                  'Is your cat neutered?',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 29,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: DSDimens.sizeS),
          Center(
            child: Text(
              'Neutered cats often need different calorie levels.',

              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          SizedBox(height: DSDimens.sizeS),

          Column(
            children: _options.map((option) {
              final isSelected = status == option['value'];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: InkWell(
                  onTap: () => onStatusChanged(option['value']),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? DSColors.primarySurface
                          : DSColors.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      option['label']!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: DSColors.darkBlue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
