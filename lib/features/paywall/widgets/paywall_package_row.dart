import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/paywall/utils/paywall_format.dart';

class PaywallPackageRow extends StatelessWidget {
  final Package package;
  final List<Package> allPackages;
  final bool selected;
  final String? badge;
  final VoidCallback onTap;

  const PaywallPackageRow({
    super.key,
    required this.package,
    required this.allPackages,
    required this.selected,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final period = periodTitleFor(package);
    final price = package.storeProduct.priceString;
    final perMonth = perPeriodLabel(package);
    final savings = savingsLabelFor(package, allPackages);

    return AnimatedContainer(
      duration: DSMotion.durFast,
      curve: DSMotion.curveStandard,
      decoration: BoxDecoration(
        color: selected
            ? DSColors.accentSuccessSoft
            : DSColors.surfaceCard,
        borderRadius: BorderRadius.circular(DSRadii.xl),
        border: Border.all(
          color: selected ? DSColors.accentSuccess : Colors.transparent,
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
                            const SizedBox(height: 2),
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
                        Text(
                          price,
                          style: DSTextStyles.titleMd.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (savings != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            savings,
                            style: DSTextStyles.caption.copyWith(
                              color: DSColors.accentSuccess,
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
    final bg = accent ? DSColors.coralSurface : DSColors.surfaceCardDim;
    final fg = accent ? DSColors.coralAccent : DSColors.inkSecondary;
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
