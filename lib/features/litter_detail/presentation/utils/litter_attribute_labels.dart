import 'package:yucat/features/litter/domain/entities/litter_entity.dart';
import 'package:yucat/features/litter_detail/presentation/models/litter_display_model.dart';
import 'package:yucat/l10n/app_localizations.dart';

/// One rendered attribute pill.
///
/// [tone] drives the pill colour: attributes are facts, but some of those facts
/// are good news for a cat (unscented, low dust) and some are bad (high dust,
/// added fragrance), and flattening them all to neutral grey would hide the
/// part the owner actually needs to see.
enum LitterAttributeTone { positive, neutral, negative }

typedef LitterAttribute = ({String label, LitterAttributeTone tone});

String litterMaterialLabel(LitterMaterial material, AppLocalizations l10n) {
  switch (material) {
    case LitterMaterial.clayBentonite:
      return l10n.litterMaterialClayBentonite;
    case LitterMaterial.clayNonClumping:
      return l10n.litterMaterialClayNonClumping;
    case LitterMaterial.silicaCrystal:
      return l10n.litterMaterialSilicaCrystal;
    case LitterMaterial.corn:
      return l10n.litterMaterialCorn;
    case LitterMaterial.wheat:
      return l10n.litterMaterialWheat;
    case LitterMaterial.tofu:
      return l10n.litterMaterialTofu;
    case LitterMaterial.paper:
      return l10n.litterMaterialPaper;
    case LitterMaterial.wood:
      return l10n.litterMaterialWood;
    case LitterMaterial.walnut:
      return l10n.litterMaterialWalnut;
    case LitterMaterial.grass:
      return l10n.litterMaterialGrass;
    case LitterMaterial.mixed:
      return l10n.litterMaterialMixed;
    case LitterMaterial.other:
      return l10n.litterMaterialOther;
  }
}

/// The attribute pills to render, in reading order.
///
/// Every entry is gated on the attribute being *known* — an `unknown` value
/// contributes no pill at all, so the card never implies a fact the backend
/// could not establish.
List<LitterAttribute> litterAttributes(
  LitterDisplayModel litter,
  AppLocalizations l10n,
) {
  final out = <LitterAttribute>[];

  out.add((
    label: litterMaterialLabel(litter.material, l10n),
    tone: LitterAttributeTone.neutral,
  ));

  switch (litter.clumping) {
    case LitterTristate.yes:
      out.add((
        label: l10n.litterAttrClumping,
        tone: LitterAttributeTone.positive,
      ));
    case LitterTristate.no:
      out.add((
        label: l10n.litterAttrNonClumping,
        tone: LitterAttributeTone.neutral,
      ));
    case LitterTristate.unknown:
      break;
  }

  switch (litter.dustLevel) {
    case LitterLevel.low:
      out.add((
        label: l10n.litterAttrDustLow,
        tone: LitterAttributeTone.positive,
      ));
    case LitterLevel.moderate:
      out.add((
        label: l10n.litterAttrDustModerate,
        tone: LitterAttributeTone.neutral,
      ));
    case LitterLevel.high:
      out.add((
        label: l10n.litterAttrDustHigh,
        tone: LitterAttributeTone.negative,
      ));
    case LitterLevel.unknown:
      break;
  }

  switch (litter.scented) {
    case LitterTristate.no:
      out.add((
        label: l10n.litterAttrUnscented,
        tone: LitterAttributeTone.positive,
      ));
    case LitterTristate.yes:
      // Fragrance is a genuine negative for cats, not a feature — see the
      // scoring rubric in functions/src/prompts/litter-rubric.ts.
      out.add((
        label: l10n.litterAttrScented,
        tone: LitterAttributeTone.negative,
      ));
    case LitterTristate.unknown:
      break;
  }

  switch (litter.odorControl) {
    case LitterLevel.high:
      out.add((
        label: l10n.litterAttrOdorHigh,
        tone: LitterAttributeTone.positive,
      ));
    case LitterLevel.moderate:
      out.add((
        label: l10n.litterAttrOdorModerate,
        tone: LitterAttributeTone.neutral,
      ));
    case LitterLevel.low:
      out.add((
        label: l10n.litterAttrOdorLow,
        tone: LitterAttributeTone.negative,
      ));
    case LitterLevel.unknown:
      break;
  }

  switch (litter.trackingLevel) {
    case LitterLevel.low:
      out.add((
        label: l10n.litterAttrTrackingLow,
        tone: LitterAttributeTone.positive,
      ));
    case LitterLevel.moderate:
      out.add((
        label: l10n.litterAttrTrackingModerate,
        tone: LitterAttributeTone.neutral,
      ));
    case LitterLevel.high:
      out.add((
        label: l10n.litterAttrTrackingHigh,
        tone: LitterAttributeTone.negative,
      ));
    case LitterLevel.unknown:
      break;
  }

  if (litter.flushable == LitterTristate.yes) {
    out.add((
      label: l10n.litterAttrFlushable,
      tone: LitterAttributeTone.positive,
    ));
  }
  if (litter.biodegradable == LitterTristate.yes) {
    out.add((
      label: l10n.litterAttrBiodegradable,
      tone: LitterAttributeTone.positive,
    ));
  }

  return out;
}
