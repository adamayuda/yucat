import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';

class StepperBottomWidget extends StatelessWidget {
  final int currentStep;
  final VoidCallback onNextStep;
  final bool isSubmitting;

  const StepperBottomWidget({
    super.key,
    required this.currentStep,
    required this.onNextStep,
    this.isSubmitting = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 40, right: 40, bottom: 50),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: isSubmitting ? null : onNextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: DSColors.primary,
                foregroundColor: DSColors.white,
                disabledBackgroundColor: DSColors.primaryDisabled,
                disabledForegroundColor: DSColors.white,
                padding: const EdgeInsets.symmetric(vertical: DSDimens.sizeS),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DSDimens.sizeXxs),
                ),
              ),
              child: isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: DSColors.white,
                      ),
                    )
                  : Text(
                      currentStep == 8 ? 'Create Profile' : 'Next',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
