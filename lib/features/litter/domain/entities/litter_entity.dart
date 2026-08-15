/// The substrate a litter is made from — the single biggest quality driver.
///
/// [wire] mirrors the backend enum in `functions/src/models/litter.ts`; the two
/// lists must stay in sync or an unknown value silently degrades to [other].
enum LitterMaterial {
  clayBentonite('clay-bentonite'),
  clayNonClumping('clay-non-clumping'),
  silicaCrystal('silica-crystal'),
  corn('corn'),
  wheat('wheat'),
  tofu('tofu'),
  paper('paper'),
  wood('wood'),
  walnut('walnut'),
  grass('grass'),
  mixed('mixed'),
  other('other');

  const LitterMaterial(this.wire);

  final String wire;

  static LitterMaterial fromWire(String? value) {
    for (final m in LitterMaterial.values) {
      if (m.wire == value) return m;
    }
    return LitterMaterial.other;
  }

  /// Coarse substrates (crystals, pellets) that are harder on sore paws than a
  /// fine, sand-like grain.
  bool get isCoarseUnderfoot =>
      this == LitterMaterial.silicaCrystal || this == LitterMaterial.wood;
}

/// A graded attribute. `unknown` is a first-class value: most of these are not
/// printed on every pack, and the UI stays silent rather than guessing.
enum LitterLevel {
  low('low'),
  moderate('moderate'),
  high('high'),
  unknown('unknown');

  const LitterLevel(this.wire);

  final String wire;

  static LitterLevel fromWire(String? value) {
    for (final l in LitterLevel.values) {
      if (l.wire == value) return l;
    }
    return LitterLevel.unknown;
  }
}

/// A yes/no fact that may simply not be established.
enum LitterTristate {
  yes('yes'),
  no('no'),
  unknown('unknown');

  const LitterTristate(this.wire);

  final String wire;

  static LitterTristate fromWire(String? value) {
    for (final t in LitterTristate.values) {
      if (t.wire == value) return t;
    }
    return LitterTristate.unknown;
  }
}

/// A scanned cat litter.
///
/// Unlike [ProductEntity], the per-cat layer reads the **structured attributes**
/// below rather than keyword-scanning the prose, so [pros]/[cons] carry no
/// hidden contract and the canonical/localized split here is purely about
/// display fallback.
class LitterEntity {
  final String name;
  final String brand;

  /// 0–100 universal quality score. **0 is a sentinel meaning "no data found"**,
  /// not a grade — it drives the neutral no-data state, exactly as for food.
  final int score;
  final String imageUrl;

  final LitterMaterial material;
  final LitterTristate clumping;
  final LitterLevel dustLevel;
  final LitterTristate scented;
  final LitterLevel trackingLevel;
  final LitterLevel odorControl;
  final LitterTristate flushable;
  final LitterTristate biodegradable;
  final List<String> additives;

  /// Canonical **English** copy, kept for parity with the food path (and so a
  /// future rules pass has a stable string to read).
  final List<String> pros;
  final List<String> cons;
  final String format;
  final String packageSize;
  final String description;

  /// Backend-translated copy for the requested app language, when available.
  final String? localizedFormat;
  final String? localizedPackageSize;
  final String? localizedDescription;
  final List<String>? localizedPros;
  final List<String>? localizedCons;

  final bool isAiIdentified;

  const LitterEntity({
    required this.name,
    required this.brand,
    required this.score,
    required this.imageUrl,
    this.material = LitterMaterial.other,
    this.clumping = LitterTristate.unknown,
    this.dustLevel = LitterLevel.unknown,
    this.scented = LitterTristate.unknown,
    this.trackingLevel = LitterLevel.unknown,
    this.odorControl = LitterLevel.unknown,
    this.flushable = LitterTristate.unknown,
    this.biodegradable = LitterTristate.unknown,
    this.additives = const [],
    this.pros = const [],
    this.cons = const [],
    this.format = '',
    this.packageSize = '',
    this.description = '',
    this.localizedFormat,
    this.localizedPackageSize,
    this.localizedDescription,
    this.localizedPros,
    this.localizedCons,
    this.isAiIdentified = false,
  });
}
