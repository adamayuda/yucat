import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:yucat/core/image/compress_jpeg.dart';

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
///
/// Attachments live in Storage at `cats/{catId}/health/{eventId}.jpeg` — one
/// object per record, named by the record, so nothing has to be looked up to
/// delete it. ⚠️ That path needs its **own Storage rule** too (see README §6).
class HealthEventDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  HealthEventDataSource({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
  })  : _firestore = firestore,
        _storage = storage;

  /// Longest side of an uploaded attachment. A booklet page has to stay
  /// readable when zoomed, so this is above the 1024 px profile photo.
  static const int _attachmentMaxSide = 1280;
  static const int _attachmentQuality = 85;

  CollectionReference<Map<String, dynamic>> _events(String catId) =>
      _firestore.collection('cats').doc(catId).collection('health_events');

  Reference _attachmentRef(String catId, String eventId) =>
      _storage.ref().child('cats/$catId/health/$eventId.jpeg');

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

  Future<void> updateEvent({
    required String catId,
    required String eventId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _events(catId).doc(eventId).update(data);
    } catch (e) {
      debugPrint('Error updating health event: $e');
      rethrow;
    }
  }

  /// Uploads the photo for [eventId] and returns its download URL. Throws on
  /// failure — the caller decides what a record without its photo means.
  Future<String> uploadAttachment({
    required String catId,
    required String eventId,
    required File file,
  }) async {
    final upload = await compressToJpeg(
          file,
          maxSide: _attachmentMaxSide,
          quality: _attachmentQuality,
          prefix: 'health_attachment',
        ) ??
        file;
    final ref = _attachmentRef(catId, eventId);
    await ref.putFile(upload, SettableMetadata(contentType: 'image/jpeg'));
    return ref.getDownloadURL();
  }

  /// Best-effort: a missing object is the expected case for a record that
  /// never had a photo, and a stale object is not worth failing a delete over.
  Future<void> deleteAttachment({
    required String catId,
    required String eventId,
  }) async {
    try {
      await _attachmentRef(catId, eventId).delete();
    } on FirebaseException catch (e) {
      if (e.code != 'object-not-found') {
        debugPrint('Error deleting health attachment: $e');
      }
    } catch (e) {
      debugPrint('Error deleting health attachment: $e');
    }
  }

  /// Object first, then document: a document that outlives its object shows
  /// a broken thumbnail, an object that outlives its document is invisible.
  Future<void> deleteEvent({
    required String catId,
    required String eventId,
  }) async {
    await deleteAttachment(catId: catId, eventId: eventId);
    try {
      await _events(catId).doc(eventId).delete();
    } catch (e) {
      debugPrint('Error deleting health event: $e');
      rethrow;
    }
  }
}
