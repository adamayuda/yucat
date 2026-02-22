import 'package:flutter/material.dart';

const totalSteps = 9;

class StepperBarWidget extends StatelessWidget {
  final int currentStep;
  final VoidCallback onPreviousStep;

  const StepperBarWidget({
    super.key,
    required this.currentStep,
    required this.onPreviousStep,
  });

  @override
  Widget build(BuildContext context) {
    final stepNumber = currentStep + 1;
    final progress = stepNumber / totalSteps;

    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 0, 40, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              TextButton.icon(
                onPressed: onPreviousStep,
                icon: Icon(
                  Icons.chevron_left,
                  size: 24,
                  color: const Color(0xFF686868),
                ),
                label: Text(
                  'Back',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF686868),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 12,
            width: double.infinity,
            child: Stack(
              children: [
                // Background (uncompleted portion)
                Container(
                  width: double.infinity,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFFF5E8FF,
                    ), // Light lavender/pale purple
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                // Progress (completed portion)
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: Color(0xFFFF5FC9), // Pink/vibrant color
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Step $stepNumber of $totalSteps',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF686868),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
