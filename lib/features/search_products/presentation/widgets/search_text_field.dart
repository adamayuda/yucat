import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';

class SearchTextField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hintText;

  const SearchTextField({
    super.key,
    required this.controller,
    required this.onChanged,
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
        style: DSTextStyles.bodyLg,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: DSTextStyles.bodyLg.copyWith(color: DSColors.inkTertiary),
          filled: true,
          fillColor: DSColors.surfaceCard,
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: DSColors.inkSecondary,
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
