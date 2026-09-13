import 'package:yucat/features/health_carnet/domain/entities/health_event_entity.dart';

/// How strongly the app may push an act.
///
/// The mockup's flat "à faire" list hides a distinction that decides how
/// insistent the UI is allowed to be — see `README.md` §1.1.
enum HealthObligation {
  /// Required by law in *some* jurisdictions (rabies, identification). The app
  /// must **never** assert what the user's local law is, so these render with a
  /// "check local requirements" note and never a red overdue badge.
  legal,

  /// Recommended for every cat by veterinary consensus. Full urgency.
  core,

  /// Only for cats matching a condition (outdoor, multi-cat, hunter). The
  /// profile carries no such signal today, so these are manual-add only.
  lifestyle,

  /// User- or vet-directed one-offs. Never auto-generated.
  optional,
}

/// One age band of a protocol, and how often the act repeats inside it.
///
/// A protocol is a *list* of these rather than a single interval, because feline
/// schedules are genuinely age-banded: FVRCP is a 3-weekly kitten series, then a
/// one-off 6-month booster, then triennial. One structure covers every row of
/// the catalogue.
class ProtocolPhase {
  /// Inclusive lower bound, in months. Fractional on purpose — kitten protocols
  /// are specified in weeks (6 wk ≈ 1.5 months).
  final double fromAgeMonths;

  /// Exclusive upper bound, or null for "and thereafter".
  final double? toAgeMonths;

  /// Repeat interval in days, or null for a single act somewhere in the window.
  final int? intervalDays;

  const ProtocolPhase({
    required this.fromAgeMonths,
    this.toAgeMonths,
    this.intervalDays,
  });

  bool contains(double ageMonths) =>
      ageMonths >= fromAgeMonths &&
      (toAgeMonths == null || ageMonths < toAgeMonths!);

  bool get isOneTime => intervalDays == null;
}

/// A recurring veterinary act and the schedule it follows.
///
/// Sources: WSAVA Vaccination Guidelines, AAFP/AAHA Feline Vaccination
/// Guidelines (2020), AAFP Feline Life Stage Guidelines (2021), ESCCAP for
/// parasite control. Where guidelines differ by region the catalogue takes the
/// conservative reading — this is guidance, never a medical or legal
/// instruction.
class HealthProtocol {
  /// Stable key, persisted as `protocol_id` on every record that satisfies it.
  /// ⚠️ Never rename one: it is the join key between history and schedule.
  final String id;

  final HealthCategory category;
  final HealthObligation obligation;

  /// Ordered by [ProtocolPhase.fromAgeMonths], ascending. Empty means the act is
  /// recordable but never scheduled (professional dental scaling is
  /// vet-indicated, not on a clock).
  final List<ProtocolPhase> phases;

  /// Whether the engine may generate a due item for this on its own.
  ///
  /// False for everything lifestyle-gated: the profile carries no
  /// indoor/outdoor or multi-cat signal, so the app cannot know these apply.
  /// They still appear in the "Add an act" picker so a user can opt in.
  final bool autoSchedule;

  /// Drops out of the schedule once `CatEntity.neutered` is true.
  final bool suppressWhenNeutered;

  /// Only scheduled for a cat with at least one entry in `healthConditions`.
  final bool requiresHealthCondition;

  /// Fallback recurrence when a record carries no `intervalDays` override and
  /// no phase applies. Only rabies uses the override, and only because the
  /// booster interval is a property of the vial (1 or 3 years) rather than of
  /// the cat — so the default here is the conservative one year.
  final int? defaultIntervalDays;

  const HealthProtocol({
    required this.id,
    required this.category,
    required this.obligation,
    required this.phases,
    this.autoSchedule = true,
    this.suppressWhenNeutered = false,
    this.requiresHealthCondition = false,
    this.defaultIntervalDays,
  });

  /// The phase covering [ageMonths], or null when the age falls in a gap
  /// between bands (or before the first one).
  ProtocolPhase? phaseAt(double ageMonths) {
    for (final phase in phases) {
      if (phase.contains(ageMonths)) return phase;
    }
    return null;
  }

  /// The first phase starting at or after [ageMonths] — used to answer "when
  /// does this become relevant?" for a cat too young for any band yet.
  ProtocolPhase? nextPhaseFrom(double ageMonths) {
    for (final phase in phases) {
      if (phase.fromAgeMonths >= ageMonths) return phase;
    }
    return null;
  }
}

/// The protocol catalogue.
///
/// ⚠️ **FIP vaccination is deliberately absent** — AAFP/WSAVA do not recommend
/// it, and it must not be offered.
///
/// ⚠️ Professional dental scaling under anesthesia is [HealthObligation.optional]
/// with **no phases**. It is vet-indicated, not clock-driven, and the app must
/// never schedule an anesthetic procedure.
class HealthProtocols {
  HealthProtocols._();

  // --- Core vaccines -------------------------------------------------------

  /// Panleukopenia + herpesvirus + calicivirus ("typhus"/"coryza" in French).
  /// Kitten series every 3 weeks from 6–8 wk to ≥16 wk, a booster at 6 months,
  /// then triennially.
  static const fvrcp = HealthProtocol(
    id: 'fvrcp',
    category: HealthCategory.vaccine,
    obligation: HealthObligation.core,
    phases: [
      ProtocolPhase(fromAgeMonths: 1.5, toAgeMonths: 4.0, intervalDays: 21),
      ProtocolPhase(fromAgeMonths: 6.0, toAgeMonths: 12.0),
      ProtocolPhase(fromAgeMonths: 12.0, intervalDays: 1095),
    ],
  );

  /// First dose from 12 weeks, booster a year later, then per the vial used.
  /// The 1-vs-3-year interval is recorded per dose, not baked in here.
  static const rabies = HealthProtocol(
    id: 'rabies',
    category: HealthCategory.vaccine,
    obligation: HealthObligation.legal,
    phases: [ProtocolPhase(fromAgeMonths: 3.0, intervalDays: 365)],
    defaultIntervalDays: 365,
  );

  /// Core **for kittens** (AAFP): retrovirus test first, then two doses 3–4
  /// weeks apart from 8–9 weeks, boosted at a year.
  static const felv = HealthProtocol(
    id: 'felv',
    category: HealthCategory.vaccine,
    obligation: HealthObligation.core,
    phases: [ProtocolPhase(fromAgeMonths: 2.0, toAgeMonths: 12.0, intervalDays: 21)],
  );

  /// The same vaccine after the first year, where it stops being core and
  /// becomes risk-based. Manual-add only — the app cannot tell whether the cat
  /// goes outdoors.
  static const felvBooster = HealthProtocol(
    id: 'felv_booster',
    category: HealthCategory.vaccine,
    obligation: HealthObligation.lifestyle,
    phases: [ProtocolPhase(fromAgeMonths: 12.0, intervalDays: 730)],
    autoSchedule: false,
  );

  // --- Parasites -----------------------------------------------------------

  /// ESCCAP: every 2 weeks from 3 weeks old, monthly to 6 months, then at least
  /// four times a year.
  static const dewormingInternal = HealthProtocol(
    id: 'deworming_internal',
    category: HealthCategory.parasite,
    obligation: HealthObligation.core,
    phases: [
      ProtocolPhase(fromAgeMonths: 0.75, toAgeMonths: 3.0, intervalDays: 14),
      ProtocolPhase(fromAgeMonths: 3.0, toAgeMonths: 6.0, intervalDays: 30),
      ProtocolPhase(fromAgeMonths: 6.0, intervalDays: 91),
    ],
  );

  /// Monthly deworming, for hunters, raw-fed cats, or households with young
  /// children. Manual-add only.
  static const dewormingMonthly = HealthProtocol(
    id: 'deworming_monthly',
    category: HealthCategory.parasite,
    obligation: HealthObligation.lifestyle,
    phases: [ProtocolPhase(fromAgeMonths: 6.0, intervalDays: 30)],
    autoSchedule: false,
  );

  /// Fleas and ticks, monthly and year-round.
  static const parasiteExternal = HealthProtocol(
    id: 'parasite_external',
    category: HealthCategory.parasite,
    obligation: HealthObligation.core,
    phases: [ProtocolPhase(fromAgeMonths: 2.0, intervalDays: 30)],
  );

  /// Endemic regions only. Manual-add only.
  static const heartworm = HealthProtocol(
    id: 'heartworm',
    category: HealthCategory.parasite,
    obligation: HealthObligation.lifestyle,
    phases: [ProtocolPhase(fromAgeMonths: 2.0, intervalDays: 30)],
    autoSchedule: false,
  );

  // --- Exams and screening -------------------------------------------------

  /// The annual wellness visit. Weight and the oral exam ride along on the same
  /// appointment, which is why they are **not** separate protocols — three due
  /// items for one vet visit would be noise. Twice yearly from age 10, per the
  /// AAFP life-stage guidelines.
  static const annualCheckup = HealthProtocol(
    id: 'annual_checkup',
    category: HealthCategory.exam,
    obligation: HealthObligation.core,
    phases: [
      ProtocolPhase(fromAgeMonths: 12.0, toAgeMonths: 120.0, intervalDays: 365),
      ProtocolPhase(fromAgeMonths: 120.0, intervalDays: 182),
    ],
  );

  /// CBC, chemistry, T4, urinalysis and blood pressure, annually from age 7.
  static const seniorPanel = HealthProtocol(
    id: 'senior_panel',
    category: HealthCategory.lab,
    obligation: HealthObligation.core,
    phases: [ProtocolPhase(fromAgeMonths: 84.0, intervalDays: 365)],
  );

  /// Recheck for a diagnosed condition (CKD, diabetes, hyperthyroidism,
  /// urinary). Only scheduled when the profile lists a health condition.
  static const conditionFollowUp = HealthProtocol(
    id: 'condition_follow_up',
    category: HealthCategory.exam,
    obligation: HealthObligation.core,
    phases: [ProtocolPhase(fromAgeMonths: 0.0, intervalDays: 182)],
    requiresHealthCondition: true,
  );

  // --- One-time ------------------------------------------------------------

  /// AAFP "Fix by Five". Drops out of the schedule once the profile says the
  /// cat is neutered.
  static const neutering = HealthProtocol(
    id: 'neutering',
    category: HealthCategory.surgery,
    obligation: HealthObligation.core,
    phases: [ProtocolPhase(fromAgeMonths: 4.0)],
    suppressWhenNeutered: true,
  );

  /// Mandatory in many countries and required for EU pet travel — but the app
  /// must not claim to know the user's jurisdiction, hence [HealthObligation.legal].
  static const microchip = HealthProtocol(
    id: 'microchip',
    category: HealthCategory.identification,
    obligation: HealthObligation.legal,
    phases: [ProtocolPhase(fromAgeMonths: 2.0)],
  );

  /// FeLV/FIV status, at acquisition and after any bite wound.
  static const retrovirusTest = HealthProtocol(
    id: 'retrovirus_test',
    category: HealthCategory.lab,
    obligation: HealthObligation.core,
    phases: [ProtocolPhase(fromAgeMonths: 2.0)],
  );

  // --- Recordable, never scheduled ----------------------------------------

  /// Vet-indicated, not clock-driven. No phases: the engine can never produce a
  /// due item for it, only the user can log one.
  static const dentalScaling = HealthProtocol(
    id: 'dental_scaling',
    category: HealthCategory.dental,
    obligation: HealthObligation.optional,
    phases: [],
    autoSchedule: false,
  );

  /// Every protocol, in the order the "Add an act" picker shows them.
  static const all = <HealthProtocol>[
    annualCheckup,
    fvrcp,
    rabies,
    felv,
    felvBooster,
    dewormingInternal,
    dewormingMonthly,
    parasiteExternal,
    heartworm,
    dentalScaling,
    seniorPanel,
    retrovirusTest,
    conditionFollowUp,
    neutering,
    microchip,
  ];

  /// The subset the schedule engine may generate on its own.
  static List<HealthProtocol> get scheduled =>
      all.where((p) => p.autoSchedule && p.phases.isNotEmpty).toList();

  static HealthProtocol? byId(String? id) {
    if (id == null) return null;
    for (final p in all) {
      if (p.id == id) return p;
    }
    return null;
  }
}
