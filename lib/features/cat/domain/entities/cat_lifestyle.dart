/// The wire values for `CatEntity.lifestyle`, and the one question the health
/// carnet asks of it. Strings rather than an enum because they are persisted;
/// an unknown value reads as "not set", never as outdoor.
abstract final class CatLifestyle {
  static const indoor = 'indoor';
  static const outdoor = 'outdoor';

  static bool isOutdoor(String? lifestyle) => lifestyle == outdoor;

  /// Null for anything that is not one of the two known values.
  static String? normalize(String? raw) => switch (raw) {
        indoor => indoor,
        outdoor => outdoor,
        _ => null,
      };
}
