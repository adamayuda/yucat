import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/paywall/bloc/paywall_bloc.dart';
import 'package:yucat/features/paywall/bloc/paywall_event.dart';
import 'package:yucat/features/paywall/utils/intro_offer_info.dart';
import 'package:yucat/features/paywall/utils/paywall_format.dart';
import 'package:yucat/features/paywall/utils/trial_info.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/ds_pill_button.dart';

/// The one-screen downsell shown after the user backs out of the store sheet.
///
/// Three in four people who tap the CTA cancel Apple's sheet — the first
/// place they see "€29.99/year" next to the €0.00 trial — and until now got
/// nothing. This offers the same yearly plan once with a discounted first year
/// ([intro], e.g. "€19.99 for your first year, then €29.99/year"). No trial is
/// claimed; [trialOnMainPlan] is only used to word the way back ("Keep the
/// 3-day free trial" vs "No thanks"). Copy says "year" outright because the
/// offer product *is* the yearly plan — the period suffix is still used for
/// the renewal line so it can't drift from the store.
///
/// Resolves to nothing; the outcome is reported to [bloc] as
/// [PaywallSecondChanceAcceptedEvent] or [PaywallSecondChanceDismissedEvent],
/// so a swipe-down, a tap outside and the "no thanks" link all count the same.
Future<void> showPaywallSecondChanceSheet(
  BuildContext context, {
  required PaywallBloc bloc,
  required Package package,
  required IntroOfferInfo intro,
  required TrialInfo? trialOnMainPlan,
}) async {
  final accepted = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _SecondChanceSheet(
      package: package,
      intro: intro,
      trialOnMainPlan: trialOnMainPlan,
    ),
  );
  bloc.add(
    accepted == true
        ? const PaywallSecondChanceAcceptedEvent()
        : const PaywallSecondChanceDismissedEvent(),
  );
}

class _SecondChanceSheet extends StatelessWidget {
  final Package package;
  final IntroOfferInfo intro;
  final TrialInfo? trialOnMainPlan;

  const _SecondChanceSheet({
    required this.package,
    required this.intro,
    required this.trialOnMainPlan,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final price = package.storeProduct.priceString;
    final introPrice = intro.priceString;
    final period = periodSuffixFor(package, l10n);
    final trial = trialOnMainPlan;

    return Container(
      decoration: const BoxDecoration(
        color: DSColors.surfaceCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(DSRadii.xl)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            DSDimens.sizeL,
            DSDimens.sizeS,
            DSDimens.sizeL,
            DSDimens.sizeL,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: DSColors.surfaceCardDim,
                    borderRadius: BorderRadius.circular(DSRadii.pill),
                  ),
                ),
              ),
              const SizedBox(height: DSDimens.sizeL),
              Text(
                l10n.paywallSecondChanceTitle,
                textAlign: TextAlign.center,
                style: DSTextStyles.headlineMd,
              ),
              const SizedBox(height: DSDimens.sizeXs),
              Text(
                l10n.paywallSecondChanceBody(introPrice, price),
                textAlign: TextAlign.center,
                style: DSTextStyles.bodyMd.copyWith(
                  color: DSColors.inkSecondary,
                ),
              ),
              const SizedBox(height: DSDimens.sizeL),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: DSDimens.sizeS,
                  horizontal: DSDimens.sizeL,
                ),
                decoration: BoxDecoration(
                  color: DSColors.tintMist,
                  borderRadius: BorderRadius.circular(DSRadii.lg),
                ),
                child: Column(
                  children: [
                    Text(
                      l10n.paywallSecondChanceFirstYear(introPrice),
                      textAlign: TextAlign.center,
                      style: DSTextStyles.displayLg,
                    ),
                    const SizedBox(height: DSDimens.sizeXxxs),
                    Text(
                      period == null
                          ? l10n.paywallCancelAnytime
                          : '${l10n.paywallThenPrice(price, period)} · '
                              '${l10n.paywallCancelAnytime}',
                      textAlign: TextAlign.center,
                      style: DSTextStyles.caption.copyWith(
                        color: DSColors.inkSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: DSDimens.sizeL),
              DSPillButton(
                label: l10n.paywallSecondChanceCta(introPrice),
                onPressed: () => Navigator.of(context).pop(true),
              ),
              const SizedBox(height: DSDimens.sizeXxs),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  trial != null
                      ? l10n.paywallSecondChanceKeepTrial(trial.days)
                      : l10n.paywallSecondChanceNoThanks,
                  style: DSTextStyles.label.copyWith(
                    color: DSColors.inkSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
