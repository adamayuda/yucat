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

  Future<Map<String, dynamic>?> fetchProductByBarcode(String barcode) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Call the Callable Function - pass barcode as parameter
      // Firebase automatically wraps this in {"data": {"barcode": "..."}}
      final callable = _functions.httpsCallable('fetchProductByBarcode');
      final result = await callable.call({'barcode': barcode});

      final data = result.data;
      if (data == null) {
        return null;
      }

      return Map<String, dynamic>.from(data);
    } catch (e) {
      throw Exception('Failed to search by barcode: $e');
    }
  }
}
