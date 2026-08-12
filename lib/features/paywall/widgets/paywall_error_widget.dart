import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/paywall/bloc/paywall_bloc.dart';
import 'package:yucat/features/paywall/bloc/paywall_event.dart';
import 'package:yucat/features/paywall/bloc/paywall_state.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/ds_state_view.dart';

class PaywallErrorWidget extends StatelessWidget {
  final PaywallError kind;
  final PaywallBloc bloc;
  final String trigger;

  const PaywallErrorWidget({
    super.key,
    required this.kind,
    required this.bloc,
    required this.trigger,
  });

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
          // Retry rather than close: under the hard gate `PopScope` blocks the
          // pop, so a Close button here leaves the user on a dead screen with
          // no way forward. A dismissible paywall can still be swiped away.
          ctaLabel: l10n.paywallRetry,
          onCtaPressed: () => bloc.add(PaywallInitialEvent(trigger: trigger)),
        ),
      ),
    );
  }
}
