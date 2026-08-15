import 'package:yucat/features/cat/domain/entities/cat_entity.dart';
import 'package:yucat/features/litter/domain/entities/litter_entity.dart';
import 'package:yucat/features/litter_detail/presentation/models/litter_display_model.dart';

/// Per-cat litter notes.
///
/// **There is deliberately no breed dimension and no per-cat score.** Unlike
/// food, litter quality does not change with breed — what changes is a small
/// number of *safety and monitoring* facts driven by age, health conditions and
/// coat. So this engine produces flags, not a number: the 0-100 score on the
/// litter stays universal.
///
/// The other deliberate difference from `cat_product_assessment.dart`: every
/// rule reads the litter's **structured attributes** (material, clumping, dust,
/// scent), never a keyword scan of prose. That is why there are no false
/// positives of the `'fish'`-inside-`'fish oil'` kind here — and why the
/// canonical-English contract that binds the food engine does not apply.
///
/// Every rule is gated on the attribute being *known*: an `unknown` attribute
/// produces no flag rather than a guess.

enum LitterFlagSeverity {
  /// A genuine safety risk for this cat — render prominently.
  warning,

  /// Worth knowing, not dangerous.
  caution,

  /// This litter suits this cat particularly well.
  good,
}

/// Stable identifiers for each note. The UI maps these to localized copy, so
/// the engine stays free of display strings (and of the six ARB files).
enum LitterFlagCode {
  /// Kitten + clumping clay: swallowed granules can clump in the gut.
  kittenClumpingClay,

  /// Kitten + silica crystals: sharp granules that kittens may ingest.
  kittenSilica,

  /// Urinary / kidney / diabetic cat + clumping: clumps make urine output
  /// visible, which is exactly what these conditions need watched.
  monitoringClumping,

  /// Same conditions, non-clumping litter: changes in urine output are much
  /// harder to spot.
  monitoringNonClumping,

  /// Skin-sensitive cat + added fragrance.
  sensitiveScented,

  /// Skin-sensitive cat + high dust.
  sensitiveDust,

  /// Senior / joint issues + coarse substrate (crystals, pellets).
  pawComfortCoarse,

  /// Senior / joint issues + fine, sand-like grain.
  pawComfortFine,

  /// Long coat + heavy tracking: granules ride out of the box in the fur.
  longCoatTracking,
}

class LitterCatFlag {
  final LitterFlagCode code;
  final LitterFlagSeverity severity;

  const LitterCatFlag(this.code, this.severity);
}

/// Conditions for which watching urine output matters day to day.
const _kUrineMonitoringConditions = {
  'urinary_issues',
  'kidney_disease',
  'diabetes',
};

/// Substrates whose grain is fine and sand-like — the texture cats prefer, and
/// the one that is kindest to sore paws.
const _kFineGrainMaterials = {
  LitterMaterial.clayBentonite,
  LitterMaterial.corn,
  LitterMaterial.wheat,
  LitterMaterial.walnut,
  LitterMaterial.grass,
};

/// Returns this cat's litter notes, most severe first. Empty means nothing
/// about this litter needs calling out for this cat — which the UI states
/// explicitly rather than rendering a blank card.
List<LitterCatFlag> litterFlagsForCat(CatEntity cat, LitterDisplayModel litter) {
  final flags = <LitterCatFlag>[];
  final conditions = cat.healthConditions ?? const <String>[];
  final needsUrineMonitoring =
      conditions.any(_kUrineMonitoringConditions.contains);

  // --- Age: kitten ingestion risk ----------------------------------------
  if (_isKitten(cat)) {
    if (litter.material == LitterMaterial.clayBentonite &&
        litter.clumping != LitterTristate.no) {
      flags.add(
        const LitterCatFlag(
          LitterFlagCode.kittenClumpingClay,
          LitterFlagSeverity.warning,
        ),
      );
    } else if (litter.material == LitterMaterial.silicaCrystal) {
      flags.add(
        const LitterCatFlag(
          LitterFlagCode.kittenSilica,
          LitterFlagSeverity.warning,
        ),
      );
    }
  }

  // --- Health: urine monitoring ------------------------------------------
  if (needsUrineMonitoring) {
    if (litter.clumping == LitterTristate.yes) {
      flags.add(
        const LitterCatFlag(
          LitterFlagCode.monitoringClumping,
          LitterFlagSeverity.good,
        ),
      );
    } else if (litter.clumping == LitterTristate.no) {
      flags.add(
        const LitterCatFlag(
          LitterFlagCode.monitoringNonClumping,
          LitterFlagSeverity.caution,
        ),
      );
    }
  }

  // --- Health: skin sensitivity ------------------------------------------
  if (conditions.contains('skin_allergies')) {
    if (litter.scented == LitterTristate.yes) {
      flags.add(
        const LitterCatFlag(
          LitterFlagCode.sensitiveScented,
          LitterFlagSeverity.caution,
        ),
      );
    }
    if (litter.dustLevel == LitterLevel.high) {
      flags.add(
        const LitterCatFlag(
          LitterFlagCode.sensitiveDust,
          LitterFlagSeverity.caution,
        ),
      );
    }
  }

  // --- Age + joints: paw comfort -----------------------------------------
  if (_isSenior(cat) || conditions.contains('joint_issues')) {
    if (litter.material.isCoarseUnderfoot) {
      flags.add(
        const LitterCatFlag(
          LitterFlagCode.pawComfortCoarse,
          LitterFlagSeverity.caution,
        ),
      );
    } else if (_kFineGrainMaterials.contains(litter.material)) {
      flags.add(
        const LitterCatFlag(
          LitterFlagCode.pawComfortFine,
          LitterFlagSeverity.good,
        ),
      );
    }
  }

  // --- Coat: tracking ----------------------------------------------------
  // Coat length, not breed: a long-coated cat of any breed carries granules
  // out of the box in its fur and between its toes.
  if (cat.coatType == 'long_hair' && litter.trackingLevel == LitterLevel.high) {
    flags.add(
      const LitterCatFlag(
        LitterFlagCode.longCoatTracking,
        LitterFlagSeverity.caution,
      ),
    );
  }

  flags.sort(
    (a, b) => a.severity.index.compareTo(b.severity.index),
  );
  return flags;
}

bool _isKitten(CatEntity cat) {
  if (cat.ageGroup == 'kitten') return true;
  final months = cat.age;
  return cat.ageGroup == null && months != null && months < 12;
}

bool _isSenior(CatEntity cat) {
  if (cat.ageGroup == 'senior') return true;
  final months = cat.age;
  return cat.ageGroup == null && months != null && months >= 120;
}
