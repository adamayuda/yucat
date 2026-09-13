import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yucat/features/product/domain/entities/scan_exception.dart';

/// Calls `readHealthBooklet`. Same shape and error contract as
/// `RemoteSearchDataSource.analyzeProductLabel`: a [ScanException] carrying
/// the callable's code, and a 90 s timeout matching the server's — one
/// vision call, no web search.
class HealthBookletDataSource {
  final FirebaseFunctions _functions;
  final FirebaseAuth _auth;

  HealthBookletDataSource({
    required FirebaseFunctions functions,
    required FirebaseAuth auth,
  })  : _functions = functions,
        _auth = auth;

  Future<Map<String, dynamic>?> readBooklet({
    required String imageBase64,
    required String today,
    String? catName,
  }) async {
    if (_auth.currentUser?.uid == null) {
      throw const ScanException(
        code: 'unauthenticated',
        message: 'User not authenticated',
      );
    }
    try {
      final callable = _functions.httpsCallable(
        'readHealthBooklet',
        options: HttpsCallableOptions(timeout: const Duration(seconds: 90)),
      );
      final result = await callable.call({
        'image': imageBase64,
        'today': today,
        if (catName != null && catName.isNotEmpty) 'catName': catName,
      });
      final data = result.data;
      if (data == null) return null;
      return Map<String, dynamic>.from(data);
    } on FirebaseFunctionsException catch (e) {
      throw ScanException(code: e.code, message: e.message);
    } catch (e) {
      throw ScanException(code: ScanException.unknownCode, message: e.toString());
    }
  }
}
