import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/paywall/utils/paywall_format.dart';
import 'package:yucat/features/paywall/utils/trial_info.dart';
import 'package:yucat/l10n/app_localizations.dart';

class PaywallPackageRow extends StatelessWidget {
  final Package package;
  final bool selected;

  /// The free trial this user will actually receive on this plan, or null.
  /// Drives the "3 DAYS FREE" badge and the "then $49.99/year" subtitle — it is
  /// already eligibility-checked, so a non-null value is safe to advertise.
  final TrialInfo? trial;
  final VoidCallback onTap;

  const PaywallPackageRow({
    super.key,
    required this.package,
    required this.selected,
    required this.onTap,
    this.trial,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final period = periodTitleFor(package, l10n);
    final price = package.storeProduct.priceString;
    // A trial row explains what happens *after* the trial; without one the
    // per-month breakdown does the softening instead.
    final subtitle = trial != null
        ? thenPriceLabelFor(package, l10n)
        : perPeriodLabel(package, l10n);
    final perMonth = trial != null ? perPeriodLabel(package, l10n) : null;

    return AnimatedContainer(
      duration: DSMotion.durFast,
      curve: DSMotion.curveStandard,
      decoration: BoxDecoration(
        color: selected
            ? DSColors.paywallAccentSoft
            : DSColors.surfaceCard,
        borderRadius: BorderRadius.circular(DSRadii.xl),
        border: Border.all(
          color: selected ? DSColors.paywallAccent : Colors.transparent,
          width: 2,
        ),
        boxShadow: selected ? null : DSShadows.e1,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(DSRadii.xl),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(DSRadii.xl),
          child: Padding(
            padding: const EdgeInsets.all(DSDimens.sizeS),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (trial != null) ...[
                  _Badge(
                    label: l10n.paywallBadgeFreeTrial(trial!.days),
                    // Always filled: the trial is the offer, not a secondary
                    // label, so it shouldn't dim with selection state.
                    accent: true,
                  ),
                  const SizedBox(height: DSDimens.sizeXxs),
                ],
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(period, style: DSTextStyles.titleMd),
                          if (subtitle != null) ...[
                            const SizedBox(height: DSDimens.sizeXxxxs),
                            Text(
                              subtitle,
                              style: DSTextStyles.bodyMd.copyWith(
                                color: DSColors.inkSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: DSDimens.sizeS),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Full price only — a trial isn't a discount, so a
                        // struck-through price here would be misleading.
                        Text(
                          price,
                          style: DSTextStyles.titleMd.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (perMonth != null) ...[
                          const SizedBox(height: DSDimens.sizeXxxxs),
                          Text(
                            perMonth,
                            style: DSTextStyles.caption.copyWith(
                              color: DSColors.paywallAccent,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final bool accent;

  const _Badge({required this.label, required this.accent});

  @override
  Widget build(BuildContext context) {
    final bg = accent ? DSColors.paywallAccent : DSColors.surfaceCardDim;
    final fg = accent ? DSColors.inkInverse : DSColors.inkSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSDimens.sizeXs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(DSRadii.pill),
      ),
      child: Text(
        label,
        style: DSTextStyles.caption.copyWith(
          color: fg,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}
