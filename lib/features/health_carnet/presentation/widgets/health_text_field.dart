import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yucat/config/themes/theme.dart';

/// The carnet's labelled text input — lifted out of the add-record sheet so
/// the vet-contact sheet shares it rather than copying it.
///
/// ⚠️ Built from scratch rather than leaning on
/// `AppTheme.lightTheme.inputDecorationTheme`, which still points at the legacy
/// palette (`inputLightGrey` fill, `DSColors.black` labels). Every real input in
/// the app overrides it for the same reason.
class HealthTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final String? errorText;
  final int maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;

  const HealthTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.errorText,
    this.maxLines = 1,
    this.keyboardType,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: DSTextStyles.label),
        const SizedBox(height: DSDimens.sizeXxs),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DSDimens.sizeXs,
            vertical: DSDimens.sizeXxs,
          ),
          decoration: BoxDecoration(
            color: DSColors.surfaceCardDim,
            borderRadius: BorderRadius.circular(DSRadii.md),
            border: errorText == null
                ? null
                : Border.all(color: DSColors.accentDanger),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            textCapitalization: textCapitalization,
            cursorColor: DSColors.coralAccent,
            style: DSTextStyles.bodyLg,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: DSTextStyles.bodyLg.copyWith(
                color: DSColors.inkTertiary,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: DSDimens.sizeXxxs),
          Text(
            errorText!,
            style: DSTextStyles.caption.copyWith(color: DSColors.accentDanger),
          ),
        ],
      ],
    );
  }
}
