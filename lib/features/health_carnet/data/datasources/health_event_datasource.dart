import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Reads and writes one cat's health records at
/// `cats/{catId}/health_events/{eventId}`.
///
/// ⚠️ Unlike `CatDataSource`, which returns null on a read failure and lets its
/// repository collapse that to `[]`, this one **throws** — the same call the
/// `RecipeFirestoreDataSource` makes, for the same reason. A network error that
/// rendered "no records yet" would tell an owner their vaccination history had
/// vanished. `HealthCarnetBloc` has a retryable error state, and a throw is what
/// fires it.
///
/// Writes rethrow so the failure analytics event carries the real cause, which
/// is the convention `CatDataSource.createCat` documents.
///
/// ⚠️ The subcollection needs its **own** security rule — Firestore rules do not
/// inherit from the parent document, and this project's rules live in the
/// console, not the repo (`firebase.json` has no `firestore` block). Every read
/// here fails `permission-denied` until that rule exists.
class HealthEventDataSource {
  final FirebaseFirestore _firestore;

  HealthEventDataSource({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> _events(String catId) =>
      _firestore.collection('cats').doc(catId).collection('health_events');

  /// Every record for the cat, unordered.
  ///
  /// Deliberately unfiltered and unsorted: `N` is tens of documents, so sorting
  /// in memory avoids a `where` + `orderBy` pair, and therefore avoids needing a
  /// composite index — which for this project would have to be created
  /// out-of-band. Do not add a filtered query here without also creating one.
  Future<QuerySnapshot<Map<String, dynamic>>> getEvents({
    required String catId,
  }) async {
    try {
      return await _events(catId).get();
    } catch (e) {
      throw Exception('Failed to fetch health events: $e');
    }
  }

  Future<DocumentReference<Map<String, dynamic>>> addEvent({
    required String catId,
    required Map<String, dynamic> data,
  }) async {
    try {
      return await _events(catId).add(data);
    } catch (e) {
      debugPrint('Error adding health event: $e');
      rethrow;
    }
  }

  Future<void> deleteEvent({
    required String catId,
    required String eventId,
  }) async {
    try {
      await _events(catId).doc(eventId).delete();
    } catch (e) {
      debugPrint('Error deleting health event: $e');
      rethrow;
    }
  }
}
