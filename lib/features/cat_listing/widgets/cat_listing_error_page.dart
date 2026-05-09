import 'package:flutter/material.dart';
import 'package:yucat/presentation/components/ds_state_view.dart';

class CatListingErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onPressed;

  const CatListingErrorWidget({
    super.key,
    required this.message,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DSStateView.error(
        body: message,
        onCtaPressed: onPressed,
      ),
    );
  }
}
