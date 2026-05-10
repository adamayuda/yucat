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
