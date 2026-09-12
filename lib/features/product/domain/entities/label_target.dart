/// Which capture the scanner is making.
///
/// `pack` is the everyday scan — the front of the package, identified and
/// looked up by the backend. `label` is the rescue path: a photo of the
/// ingredients / analysis panel, sent to `analyzeProductLabel`, which reads the
/// nutrition straight off it. Same camera, same shutter; only the guidance,
/// the capture size and the event differ.
enum ScanMode { pack, label }

/// What a label capture attaches its data to. Every field is optional: a
/// product that came from a scan carries its Algolia key, one read off a
/// barcode carries the gtin, one that failed identify may carry only what the
/// backend transcribed — and a label with none of them still resolves by the
/// brand/name printed on the panel itself.
class LabelTarget {
  final String? productKey;
  final String? gtin;
  final String? brand;
  final String? name;
  final String? foodType;

  const LabelTarget({
    this.productKey,
    this.gtin,
    this.brand,
    this.name,
    this.foodType,
  });

  bool get isEmpty =>
      productKey == null && gtin == null && brand == null && name == null;
}
