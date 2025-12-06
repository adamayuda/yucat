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
          Center(
            child: Text(
              'Is your cat neutered?',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(),
            ),
          ),
          Center(
            child: Text(
              'Neutered cats often need different calorie levels.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
          ),
          SizedBox(height: DSDimens.sizeM),

          Column(
            children: _options.map((option) {
              final isSelected = status == option['value'];
              return Padding(
                padding: EdgeInsets.only(
                  bottom: option == _options.last ? 0 : DSDimens.sizeS,
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(DSDimens.sizeXs),
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () => onStatusChanged(option['value']),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: DSDimens.sizeS,
                      vertical: DSDimens.sizeXs,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(DSDimens.sizeXs),
                      border: Border.all(
                        color: isSelected
                            ? DSColors.primary
                            : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            option['label']!,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: isSelected
                                      ? DSColors.primary
                                      : Colors.grey[800],
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                          ),
                        ),
                      ],
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
