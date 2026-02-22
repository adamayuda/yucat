import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';

class StepperBottomWidget extends StatelessWidget {
  final int currentStep;
  final VoidCallback onNextStep;

  const StepperBottomWidget({
    super.key,
    required this.currentStep,
    required this.onNextStep,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 40, right: 40, bottom: 50),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: onNextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: DSColors.primary,
                foregroundColor: DSColors.white,
                disabledBackgroundColor: const Color(0xFFEDAFDD),
                disabledForegroundColor: DSColors.white,
                padding: const EdgeInsets.symmetric(vertical: DSDimens.sizeS),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DSDimens.sizeXxs),
                ),
              ),
              child: Text(
                currentStep == 8 ? 'Create Profile' : 'Next',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
