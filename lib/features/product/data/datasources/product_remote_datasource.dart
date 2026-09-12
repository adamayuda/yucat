import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yucat/features/product/domain/entities/label_target.dart';
import 'package:yucat/features/product/domain/entities/scan_exception.dart';

class RemoteSearchDataSource {
  final FirebaseFunctions _functions;
  final FirebaseAuth _auth;

  RemoteSearchDataSource({
    required FirebaseFunctions functions,
    required FirebaseAuth auth,
  }) : _functions = functions,
       _auth = auth;

  /// Calls `fetchProductByImageV2`. Throws a [ScanException] carrying the
  /// callable's error code on failure, so callers can tell a timeout from an
  /// offline device from an exhausted backend.
  Future<Map<String, dynamic>?> fetchProductByImage({
    required String imageBase64,
    required String mimeType,
    String? countryCode,
    String? locale,
    String? gtin,
  }) async {
    // The backend now requires `request.auth`; a missing session is reported
    // under the same code the server would use, so the bloc handles both alike.
    if (_auth.currentUser?.uid == null) {
      throw const ScanException(
        code: 'unauthenticated',
        message: 'User not authenticated',
      );
    }

    try {
      final callable = _functions.httpsCallable(
        'fetchProductByImageV2',
        options: HttpsCallableOptions(timeout: const Duration(seconds: 120)),
      );
      final result = await callable.call({
        'image': imageBase64,
        'mimeType': mimeType,
        // Device country (ISO 3166-1 alpha-2) lets the backend bias web_search
        // to the user's market. Omitted when unknown.
        if (countryCode != null && countryCode.isNotEmpty)
          'countryCode': countryCode,
        // App language (ISO 639-1). Drives the translated `localizedText` in
        // the response. Omitted when unknown → English.
        if (locale != null && locale.isNotEmpty) 'locale': locale,
        // Normalised barcode read off the still (see `normalizeGtin`). The
        // backend looks it up before identify and re-validates it.
        if (gtin != null && gtin.isNotEmpty) 'gtin': gtin,
      });

      final data = result.data;
      if (data == null) {
        return null;
      }

      return Map<String, dynamic>.from(data);
    } on FirebaseFunctionsException catch (e) {
      throw ScanException(code: e.code, message: e.message);
    } catch (e) {
      throw ScanException(
        code: ScanException.unknownCode,
        message: e.toString(),
      );
    }
  }

  /// Calls `analyzeProductLabel` — the back-label rescue. Same error contract
  /// as [fetchProductByImage]. The 90 s timeout matches the server's: one
  /// vision call, no web search.
  Future<Map<String, dynamic>?> analyzeProductLabel({
    required String imageBase64,
    required String mimeType,
    required LabelTarget target,
    String? countryCode,
    String? locale,
  }) async {
    if (_auth.currentUser?.uid == null) {
      throw const ScanException(
        code: 'unauthenticated',
        message: 'User not authenticated',
      );
    }

    try {
      final callable = _functions.httpsCallable(
        'analyzeProductLabel',
        options: HttpsCallableOptions(timeout: const Duration(seconds: 90)),
      );
      final result = await callable.call({
        'labelImage': imageBase64,
        'mimeType': mimeType,
        if (target.productKey != null) 'productKey': target.productKey,
        if (target.gtin != null) 'gtin': target.gtin,
        if (target.brand != null || target.name != null)
          'identification': {
            'brand': target.brand ?? '',
            'name': target.name ?? '',
            if (target.foodType != null) 'foodType': target.foodType,
          },
        if (countryCode != null && countryCode.isNotEmpty)
          'countryCode': countryCode,
        if (locale != null && locale.isNotEmpty) 'locale': locale,
      });

      final data = result.data;
      if (data == null) return null;
      return Map<String, dynamic>.from(data);
    } on FirebaseFunctionsException catch (e) {
      throw ScanException(code: e.code, message: e.message);
    } catch (e) {
      throw ScanException(
        code: ScanException.unknownCode,
        message: e.toString(),
      );
    }
  }
}
