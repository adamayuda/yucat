import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';

class ActivityStep extends StatelessWidget {
  final String? activityLevel;
  final ValueChanged<String?> onActivityLevelChanged;

  const ActivityStep({
    super.key,
    required this.activityLevel,
    required this.onActivityLevelChanged,
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
                  color: const Color(0xFFF5E8FF),
                  borderRadius: BorderRadius.circular(DSDimens.sizeXxs),
                ),
                width: 40,
                height: 40,
                child: Image.asset(
                  'assets/images/Icons/body cat 2.png',
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(width: DSDimens.sizeS),
              Expanded(
                child: Text(
                  'How active is your cat?',
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
              'Activity helps us understand calorie needs.',

              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(height: DSDimens.sizeS),

          Column(
            children: ['Low', 'Medium', 'High'].map((level) {
              final value = level.toLowerCase();
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: InkWell(
                  onTap: () => onActivityLevelChanged(value),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: activityLevel == value
                          ? const Color(0xFFFEF5FE)
                          : const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      level,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF334156),
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
