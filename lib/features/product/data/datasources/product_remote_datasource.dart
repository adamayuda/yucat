import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RemoteSearchDataSource {
  final FirebaseFunctions _functions;
  final FirebaseAuth _auth;

  RemoteSearchDataSource({
    required FirebaseFunctions functions,
    required FirebaseAuth auth,
  }) : _functions = functions,
       _auth = auth;

  Future<Map<String, dynamic>?> fetchProductByImage({
    required String imageBase64,
    required String mimeType,
    String? countryCode,
    String? locale,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

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
      });

      final data = result.data;
      if (data == null) {
        return null;
      }

      return Map<String, dynamic>.from(data);
    } catch (e) {
      throw Exception('Failed to fetch product by image: $e');
    }
  }
}
