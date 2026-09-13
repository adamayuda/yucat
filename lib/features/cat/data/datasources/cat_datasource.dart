import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:yucat/core/image/compress_jpeg.dart';
import 'package:flutter/foundation.dart';

class CatDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  CatDataSource({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
  }) : _firestore = firestore,
       _storage = storage;

  Future<QuerySnapshot<Map<String, dynamic>>?> getCats({
    required String userId,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection('cats')
          .where('user', isEqualTo: _firestore.collection('users').doc(userId))
          .get();

      return querySnapshot;
    } catch (e) {
      debugPrint('Error fetching cats: $e');
      return null;
    }
  }

  Future<DocumentReference<Map<String, dynamic>>?> createCat({
    required String userId,
    required String name,
    int? age,
    DateTime? birthDate,
    String? ageGroup,
    double? weight,
    bool neutered = false,
    String? profileImageUrl,
    String? neuteredStatus,
    String? breed,
    String? weightCategory,
    String? activityLevel,
    String? coatType,
    String? gender,
    List<String>? healthConditions,
  }) async {
    try {
      final catData = {
        'user': _firestore.collection('users').doc(userId),
        'name': name,
        'age': age,
        // ⚠️ This map is hand-built, not `CatDocumentMapper.toDocument` —
        // keep the two in step. Timestamp, like `health_events`.
        'birth_date': birthDate == null ? null : Timestamp.fromDate(birthDate),
        'age_group': ageGroup,
        'weight': weight,
        'neutered': neutered,
        if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
        'neutered_status': neuteredStatus,
        'breed': breed,
        'weight_category': weightCategory,
        'activity_level': activityLevel,
        'coat_type': coatType,
        'gender': gender,
        if (healthConditions != null && healthConditions.isNotEmpty)
          'health_conditions': healthConditions,
      };

      final docRef = await _firestore.collection('cats').add(catData);

      return docRef;
    } catch (e) {
      // Surface the real failure (e.g. permission-denied, network) instead of
      // collapsing it to a generic null → "Failed to create cat", so the
      // `Cat Creation Failed` analytics event carries the actual cause.
      debugPrint('Error creating cat: $e');
      rethrow;
    }
  }

  /// Longest side of an uploaded profile photo, in px. The avatar never renders
  /// above ~132 px, so a camera-native 12 MP JPEG is pure upload time and
  /// Storage cost; 1024 px still looks sharp on a 3× display.
  static const int _profileImageMaxSide = 1024;
  static const int _profileImageQuality = 85;

  Future<String?> uploadCatProfileImage({
    required File imageFile,
    required String catId,
  }) async {
    try {
      final stamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${catId}_$stamp.jpg';
      final ref = _storage.ref().child('cats').child(fileName);

      final upload = await compressToJpeg(
            imageFile,
            maxSide: _profileImageMaxSide,
            quality: _profileImageQuality,
            prefix: 'cat_profile',
          ) ??
          imageFile;
      await ref.putFile(
        upload,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading cat profile image: $e');
      return null;
    }
  }

  /// Best-effort removal of a profile photo by its download URL — used when a
  /// photo is replaced, so a cat that changes picture five times doesn't leave
  /// four orphans behind. Never throws: the new photo is already live, and a
  /// stale object in Storage is not worth failing the user's action over.
  Future<void> deleteCatProfileImage({required String imageUrl}) async {
    try {
      await _storage.refFromURL(imageUrl).delete();
    } catch (e) {
      debugPrint('Error deleting replaced cat profile image: $e');
    }
  }

  Future<void> updateCatProfileImageUrl({
    required String catId,
    required String profileImageUrl,
  }) async {
    try {
      await _firestore.collection('cats').doc(catId).update({
        'profileImageUrl': profileImageUrl,
      });
    } catch (e) {
      debugPrint('Error updating cat profile image URL: $e');
      rethrow;
    }
  }

  Future<void> deleteCat({required String catId}) async {
    try {
      // Firestore does not cascade-delete subcollections, so best-effort clean
      // up the cat's health_events first to avoid orphaned docs.
      try {
        final events = await _firestore
            .collection('cats')
            .doc(catId)
            .collection('health_events')
            .get();
        for (final doc in events.docs) {
          await doc.reference.delete();
        }
      } catch (e) {
        debugPrint('Error deleting cat health events: $e');
      }

      // Delete Firestore document
      await _firestore.collection('cats').doc(catId).delete();

      // Try to delete profile image from Storage if exists
      try {
        final listResult = await _storage.ref().child('cats').listAll();
        for (final item in listResult.items) {
          if (item.name.startsWith(catId)) {
            await item.delete();
          }
        }
      } catch (e) {
        // Ignore if image doesn't exist or can't be deleted
        debugPrint('Error deleting cat profile image: $e');
      }

      // Carnet attachments live under their own prefix; Storage has no
      // recursive delete, so list and remove them one by one. Best-effort,
      // like the profile photo: the document is already gone.
      try {
        final attachments =
            await _storage.ref().child('cats/$catId/health').listAll();
        for (final item in attachments.items) {
          await item.delete();
        }
      } catch (e) {
        debugPrint('Error deleting cat health attachments: $e');
      }
    } catch (e) {
      debugPrint('Error deleting cat: $e');
      rethrow;
    }
  }

  /// Writes the allergy list outright, including an empty one.
  ///
  /// Deliberately not routed through [updateCat]: the document mapper omits an
  /// empty `allergies` key so a cat-wizard save can't wipe the list, which also
  /// means it can never *clear* it. Clearing is a real user action, so it gets
  /// its own write.
  Future<void> updateCatAllergies({
    required String catId,
    required List<String> allergies,
  }) async {
    try {
      await _firestore.collection('cats').doc(catId).update({
        'allergies': allergies,
      });
    } catch (e) {
      debugPrint('Error updating cat allergies: $e');
      rethrow;
    }
  }

  /// Writes the vet map, or deletes the field when [vet] is null. Same
  /// reasoning as [updateCatAllergies]: the mapper omits the key when unset,
  /// so removal needs its own write.
  Future<void> updateCatVet({
    required String catId,
    required Map<String, dynamic>? vet,
  }) async {
    try {
      await _firestore.collection('cats').doc(catId).update({
        'vet': vet ?? FieldValue.delete(),
      });
    } catch (e) {
      debugPrint('Error updating cat vet: $e');
      rethrow;
    }
  }

  /// Writes the lifestyle string, or deletes the field when null. Same
  /// reasoning as [updateCatAllergies].
  Future<void> updateCatLifestyle({
    required String catId,
    required String? lifestyle,
  }) async {
    try {
      await _firestore.collection('cats').doc(catId).update({
        'lifestyle': lifestyle ?? FieldValue.delete(),
      });
    } catch (e) {
      debugPrint('Error updating cat lifestyle: $e');
      rethrow;
    }
  }

  /// Writes `weight` alone. Called by the carnet when a weigh-in is logged, so
  /// the profile weight the food assessment reads stops being a snapshot from
  /// the wizard. `weight_category` (the owner's body-condition answer) is
  /// deliberately not touched.
  Future<void> updateCatWeight({
    required String catId,
    required double weight,
  }) async {
    try {
      await _firestore.collection('cats').doc(catId).update({'weight': weight});
    } catch (e) {
      debugPrint('Error updating cat weight: $e');
      rethrow;
    }
  }

  Future<void> updateCat({
    required String catId,
    required Map<String, dynamic> catData,
  }) async {
    try {
      debugPrint('CATDIAG wrote catId=$catId breed=${catData['breed']} '
          'photo=${catData['profileImageUrl']}');
      await _firestore.collection('cats').doc(catId).update(catData);
    } catch (e) {
      debugPrint('Error updating cat: $e');
      rethrow;
    }
  }
}
