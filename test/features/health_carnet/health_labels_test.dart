import 'package:flutter_test/flutter_test.dart';
import 'package:yucat/features/health_carnet/domain/entities/health_protocol.dart';
import 'package:yucat/features/health_carnet/presentation/utils/health_labels.dart';

/// `health_labels.dart` imports Flutter for the icon/colour helpers, but the
/// slug map is a plain function — and the point of this test is coverage: a
/// protocol added to the catalogue without an article must fail here rather
/// than ship with a dead "Learn more".
void main() {
  test('every protocol in the catalogue maps to an article slug', () {
    for (final protocol in HealthProtocols.all) {
      final slug = healthProtocolArticleSlug(protocol.id);
      expect(slug, isNotEmpty, reason: protocol.id);
    }
  });

  test('the three dedicated articles are wired to their protocols', () {
    expect(healthProtocolArticleSlug('dental_scaling'), 'dental-disease-in-cats');
    expect(healthProtocolArticleSlug('senior_panel'), 'caring-for-a-senior-cat');
    expect(healthProtocolArticleSlug('condition_follow_up'), 'why-cats-hide-pain');
    expect(healthProtocolArticleSlug('rabies'), 'the-preventive-care-calendar');
  });
}
