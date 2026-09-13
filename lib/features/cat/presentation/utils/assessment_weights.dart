/// Dimension priorities shared by the two rules engines —
/// `cat_product_assessment.dart` (per-cat product verdict) and
/// `cat_diet_recommendations.dart` (owner-facing diet tips).
///
/// They used to be two private copies of the same numbers; a retune in one
/// silently left the other behind. Health and weight dominate, breed is a
/// tiebreaker; `coat` and `hydration` exist only for the diet tips.
class AssessmentWeights {
  AssessmentWeights._();

  static const health = 15;
  static const weight = 12;
  static const age = 10;
  static const activity = 8;
  static const neutered = 6;
  static const breed = 5;
  static const coat = 4;
  static const hydration = 3;
}
