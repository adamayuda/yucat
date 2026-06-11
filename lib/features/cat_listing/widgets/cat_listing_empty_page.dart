import 'package:flutter/material.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/ds_state_view.dart';

class CatListingEmptyWidget extends StatelessWidget {
  final VoidCallback onPressed;

  const CatListingEmptyWidget({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: DSStateView.empty(
        illustrationAsset: 'assets/images/Illustrations/empty-state.gif',
        headline: l10n.catListingEmptyHeadline,
        body: l10n.catListingEmptyBody,
        ctaLabel: l10n.catListingEmptyCta,
        onCtaPressed: onPressed,
      ),
    );
  }
}
