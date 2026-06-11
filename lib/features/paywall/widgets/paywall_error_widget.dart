import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/paywall/bloc/paywall_state.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/ds_state_view.dart';

class PaywallErrorWidget extends StatelessWidget {
  final PaywallError kind;

  const PaywallErrorWidget({super.key, required this.kind});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      color: DSColors.tintMint,
      child: SafeArea(
        child: DSStateView.error(
          body: switch (kind) {
            PaywallError.iosOnly => l10n.paywallErroriOSOnly,
            PaywallError.couldNotLoadPlans => l10n.paywallErrorCouldNotLoadPlans,
            PaywallError.noPlansAvailable => l10n.paywallErrorNoPlansAvailable,
          },
          ctaLabel: l10n.commonClose,
          onCtaPressed: () => Navigator.of(context).pop(false),
        ),
      ),
    );
  }
}
