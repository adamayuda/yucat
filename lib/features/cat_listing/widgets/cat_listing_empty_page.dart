import 'package:flutter/material.dart';
import 'package:yucat/presentation/components/ds_state_view.dart';

class CatListingEmptyWidget extends StatelessWidget {
  final VoidCallback onPressed;

  const CatListingEmptyWidget({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DSStateView.empty(
        illustrationAsset: 'assets/images/Illustrations/Add new cat.gif',
        headline: 'No cats yet',
        body: "Create a profile so YuCat can match food to your cat's needs.",
        ctaLabel: 'Add my cat',
        onCtaPressed: onPressed,
      ),
    );
  }
}
