import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/analytics/analytics_events.dart';
import 'package:yucat/features/analytics/domain/usecase/log_event_usecase.dart';
import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/ds_card.dart';
import 'package:yucat/presentation/components/ds_chip.dart';
import 'package:yucat/service_locator.dart';

/// The guaranteed analysis, with an **as-fed / dry-matter** toggle.
///
/// The pack prints as-fed figures, and so did this card — which is how a 10 %
/// pâté reads as "less protein" than a 32 % kibble when, water removed, it is
/// the higher-protein food. The per-cat engine has always judged on dry
/// matter; the toggle lets the reader see what it sees. Energy is a modified-
/// Atwater estimate (`ProductDisplayModel.calories`), flagged as such.
class NutritionGridCard extends StatefulWidget {
  final ProductDisplayModel product;

  const NutritionGridCard({super.key, required this.product});

  @override
  State<NutritionGridCard> createState() => _NutritionGridCardState();
}

class _NutritionGridCardState extends State<NutritionGridCard> {
  bool _dryMatter = false;

  /// A macro of exactly 0 means it was missing from the guaranteed analysis
  /// (the backend defaults unknown values to 0). Show an em-dash rather than a
  /// misleading "0.0%".
  String _pct(double asFed) {
    if (asFed <= 0) return '—';
    final v = _dryMatter ? asFed * widget.product.dryMatterFactor : asFed;
    return '${v.toStringAsFixed(1)}%';
  }

  /// Carbs is derived by subtraction, so whenever the rest of the analysis is
  /// present we can always show it. A derived ~0 — common for high-moisture
  /// wet food — is a real value, not "missing". Only blank carbs when the
  /// whole analysis is unavailable.
  String _carbs() {
    final p = widget.product;
    if (p.dataUnavailable) return '—';
    final asFed = p.carbs < 0 ? 0.0 : p.carbs;
    final v = _dryMatter ? asFed * p.dryMatterFactor : asFed;
    return '${v.toStringAsFixed(1)}%';
  }

  String _energy(AppLocalizations l10n) {
    final p = widget.product;
    if (p.dataUnavailable) return '—';
    final v = _dryMatter ? p.calories * p.dryMatterFactor : p.calories;
    return l10n.productDetailEnergyValue(v.round());
  }

  void _toggle(bool dryMatter) {
    if (dryMatter == _dryMatter) return;
    setState(() => _dryMatter = dryMatter);
    sl<LogEventUsecase>().call(
      eventName: AnalyticsEvents.nutritionBasisToggled,
      properties: {
        'basis': dryMatter ? 'dry_matter' : 'as_fed',
        'product_name': widget.product.name,
        'product_brand': widget.product.brand,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = widget.product;
    final cells = <_MacroCell>[
      _MacroCell(
        iconAsset: 'assets/images/Protein.svg',
        label: l10n.productDetailNutrientProtein,
        value: _pct(p.protein),
      ),
      _MacroCell(
        iconAsset: 'assets/images/Fat.svg',
        label: l10n.productDetailNutrientFat,
        value: _pct(p.fat),
      ),
      _MacroCell(
        iconAsset: 'assets/images/Carbs.svg',
        label: l10n.productDetailNutrientCarbs,
        value: _carbs(),
      ),
      _MacroCell(
        iconAsset: 'assets/images/Fiber.svg',
        label: l10n.productDetailNutrientFiber,
        value: _pct(p.fiber),
      ),
      // Moisture is what the toggle divides out, so it always reads as fed.
      _MacroCell(
        iconAsset: 'assets/images/Moisture.svg',
        label: l10n.productDetailNutrientMoisture,
        value: p.moisture <= 0 ? '—' : '${p.moisture.toStringAsFixed(1)}%',
      ),
      _MacroCell(
        icon: Icons.grain_rounded,
        label: l10n.productDetailNutrientAsh,
        value: _pct(p.ash),
      ),
      _MacroCell(
        icon: Icons.local_fire_department_rounded,
        label: l10n.productDetailNutrientEnergy,
        value: _energy(l10n),
      ),
    ];

    return DSCard(
      padding: const EdgeInsets.all(DSDimens.sizeL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.productDetailNutritionTitle,
                  style: DSTextStyles.caption.copyWith(
                    color: DSColors.inkSecondary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              DSChip(
                label: l10n.productDetailBasisAsFed,
                selected: !_dryMatter,
                onTap: () => _toggle(false),
              ),
              const SizedBox(width: DSDimens.sizeXxs),
              DSChip(
                label: l10n.productDetailBasisDryMatter,
                selected: _dryMatter,
                onTap: () => _toggle(true),
              ),
            ],
          ),
          const SizedBox(height: DSDimens.sizeS),
          LayoutBuilder(
            builder: (context, constraints) {
              const perRow = 4;
              const gap = DSDimens.sizeXxs;
              final w = (constraints.maxWidth - gap * (perRow - 1)) / perRow;
              return Wrap(
                spacing: gap,
                runSpacing: DSDimens.sizeS,
                children: [
                  for (final c in cells) SizedBox(width: w, child: c),
                ],
              );
            },
          ),
          const SizedBox(height: DSDimens.sizeS),
          Text(
            _dryMatter
                ? l10n.productDetailBasisDryMatterHint
                : l10n.productDetailBasisAsFedHint,
            style: DSTextStyles.caption.copyWith(color: DSColors.inkTertiary),
          ),
        ],
      ),
    );
  }
}

class _MacroCell extends StatelessWidget {
  final String? iconAsset;
  final IconData? icon;
  final String label;
  final String value;

  const _MacroCell({
    this.iconAsset,
    this.icon,
    required this.label,
    required this.value,
  }) : assert(iconAsset != null || icon != null);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (iconAsset != null)
          SvgPicture.asset(iconAsset!, width: 34, height: 34)
        else
          SizedBox(
            width: 34,
            height: 34,
            child: Icon(icon, size: 26, color: DSColors.inkSecondary),
          ),
        const SizedBox(height: DSDimens.sizeXxxs),
        Text(
          value,
          style: DSTextStyles.caption.copyWith(
            color: DSColors.inkPrimary,
            fontWeight: FontWeight.w700,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          label,
          style: DSTextStyles.caption.copyWith(
            color: DSColors.inkSecondary,
            fontSize: 10,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
