import 'package:cloud_functions/cloud_functions.dart';
import 'package:yucat/features/brand/domain/entities/brand_verdict.dart';

/// Thin wrapper over the `analyzeBrand` Callable Function.
class BrandVerdictDataSource {
  final FirebaseFunctions _functions;

  BrandVerdictDataSource({required FirebaseFunctions functions})
      : _functions = functions;

  Future<BrandVerdict?> analyze(Map<String, dynamic> payload) async {
    final callable = _functions.httpsCallable(
      'analyzeBrand',
      options: HttpsCallableOptions(timeout: const Duration(seconds: 30)),
    );
    final result = await callable.call(payload);
    final data = result.data;
    if (data == null) return null;
    final verdict = Map<String, dynamic>.from(data)['verdict'];
    if (verdict == null) return null;
    final map = Map<String, dynamic>.from(verdict);
    final headline = map['headline'];
    if (headline is! String || headline.trim().isEmpty) return null;
    return BrandVerdict(
      score: (map['score'] as num?)?.round() ?? 0,
      headline: headline.trim(),
      reasons: ((map['reasons'] as List?) ?? const [])
          .map((e) => e.toString())
          .toList(),
      positives: ((map['positives'] as List?) ?? const [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}
