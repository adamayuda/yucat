import 'package:cloud_functions/cloud_functions.dart';
import 'package:yucat/features/cat/domain/entities/cat_narrative.dart';

/// Thin wrapper over the `generateCatNarrative` Callable Function.
class CatNarrativeDataSource {
  final FirebaseFunctions _functions;

  CatNarrativeDataSource({required FirebaseFunctions functions})
      : _functions = functions;

  /// Calls the function with [payload] and returns the narrative + outlook, or
  /// null if the backend produced no narrative.
  Future<CatNarrative?> generateNarrative(Map<String, dynamic> payload) async {
    final callable = _functions.httpsCallable(
      'generateCatNarrative',
      options: HttpsCallableOptions(timeout: const Duration(seconds: 30)),
    );
    final result = await callable.call(payload);
    final data = result.data;
    if (data == null) return null;
    final map = Map<String, dynamic>.from(data);
    final narrative = map['narrative'];
    if (narrative is! String || narrative.trim().isEmpty) return null;
    final outlook = map['outlook'];
    return CatNarrative(
      narrative: narrative.trim(),
      outlook: outlook is String && outlook.trim().isNotEmpty
          ? outlook.trim()
          : null,
    );
  }
}
