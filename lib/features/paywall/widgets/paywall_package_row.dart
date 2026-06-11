import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/paywall/utils/paywall_format.dart';
import 'package:yucat/l10n/app_localizations.dart';

class PaywallPackageRow extends StatelessWidget {
  final Package package;
  final List<Package> allPackages;
  final bool selected;
  final String? badge;

  /// When true and the package has an introductory offer, the row shows the
  /// discounted intro price (full price struck through) instead of the regular
  /// price. Controlled by the paywall's promo switch + intro eligibility.
  final bool showIntro;
  final VoidCallback onTap;

  const PaywallPackageRow({
    super.key,
    required this.package,
    required this.allPackages,
    required this.selected,
    required this.onTap,
    this.badge,
    this.showIntro = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final period = periodTitleFor(package, l10n);
    final price = package.storeProduct.priceString;
    final showIntroOffer = showIntro && hasIntroOffer(package);
    final introPrice = introPriceStringFor(package);
    final renewal = renewalLabelFor(package);
    final introSavings = introSavingsLabelFor(package);
    // Intro plans show the renewal line ("then $49.99/yr"); others show the
    // per-month breakdown.
    final perMonth = showIntroOffer ? renewal : perPeriodLabel(package);
    final savings = showIntroOffer ? null : savingsLabelFor(package, allPackages);

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
                if (badge != null) ...[
                  _Badge(label: badge!, accent: selected),
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
                          if (perMonth != null) ...[
                            const SizedBox(height: DSDimens.sizeXxxxs),
                            Text(
                              perMonth,
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
                        if (showIntroOffer && introPrice != null) ...[
                          Text(
                            price,
                            style: DSTextStyles.bodyMd.copyWith(
                              color: DSColors.inkTertiary,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          const SizedBox(height: DSDimens.sizeXxxxs),
                          Text(
                            introPrice,
                            style: DSTextStyles.titleMd.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ] else
                          Text(
                            price,
                            style: DSTextStyles.titleMd.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        if (showIntroOffer && introSavings != null) ...[
                          const SizedBox(height: DSDimens.sizeXxxxs),
                          Text(
                            introSavings,
                            style: DSTextStyles.caption.copyWith(
                              color: DSColors.paywallAccent,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ] else if (savings != null) ...[
                          const SizedBox(height: DSDimens.sizeXxxxs),
                          Text(
                            savings,
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
