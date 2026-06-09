import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';

class SearchTextField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hintText;

  /// Called when the clear (✕) button is tapped. The button only renders while
  /// the field has text.
  final VoidCallback? onClear;

  /// Called when the keyboard search/return key is pressed.
  final ValueChanged<String>? onSubmitted;

  const SearchTextField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.onClear,
    this.onSubmitted,
    this.hintText = 'Search for a cat food',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DSColors.surfaceCard,
        borderRadius: BorderRadius.circular(DSRadii.pill),
        boxShadow: DSShadows.e1,
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        style: DSTextStyles.bodyLg,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: DSTextStyles.bodyLg.copyWith(color: DSColors.inkTertiary),
          filled: true,
          fillColor: DSColors.surfaceCard,
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: DSColors.inkSecondary,
          ),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(
                  Icons.close_rounded,
                  color: DSColors.inkSecondary,
                  size: 20,
                ),
                splashRadius: 20,
                onPressed: onClear,
              );
            },
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: DSDimens.sizeS,
            vertical: DSDimens.sizeS,
          ),
          border: _border,
          enabledBorder: _border,
          focusedBorder: _border,
        ),
      ),
    );
  }

  OutlineInputBorder get _border => OutlineInputBorder(
        borderRadius: BorderRadius.circular(DSRadii.pill),
        borderSide: BorderSide.none,
      );
}
