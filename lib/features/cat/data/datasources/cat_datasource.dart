import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

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
      print('Error fetching cats: $e');
      return null;
    }
  }

  Future<DocumentReference<Map<String, dynamic>>?> createCat({
    required String userId,
    required String name,
    int? age,
    String? ageGroup,
    double? weight,
    bool neutered = false,
    String? profileImageUrl,
    String? neuteredStatus,
    String? breed,
    String? weightCategory,
    String? activityLevel,
    String? coatType,
    List<String>? healthConditions,
  }) async {
    try {
      final catData = {
        'user': _firestore.collection('users').doc(userId),
        'name': name,
        'age': age,
        'age_group': ageGroup,
        'weight': weight,
        'neutered': neutered,
        if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
        'neutered_status': neuteredStatus,
        'breed': breed,
        'weight_category': weightCategory,
        'activity_level': activityLevel,
        'coat_type': coatType,
        if (healthConditions != null && healthConditions.isNotEmpty)
          'health_conditions': healthConditions,
      };

      final docRef = await _firestore.collection('cats').add(catData);

      return docRef;
    } catch (e) {
      print('Error creating cat: $e');
      return null;
    }
  }

  Future<String?> uploadCatProfileImage({
    required File imageFile,
    required String catId,
  }) async {
    try {
      final fileName = '${catId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('cats').child(fileName);

      await ref.putFile(imageFile);

      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading cat profile image: $e');
      return null;
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
      print('Error updating cat profile image URL: $e');
      rethrow;
    }
  }

  Future<void> deleteCat({required String catId}) async {
    try {
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
        print('Error deleting cat profile image: $e');
      }
    } catch (e) {
      print('Error deleting cat: $e');
      rethrow;
    }
  }

  Future<void> updateCat({
    required String catId,
    required Map<String, dynamic> catData,
  }) async {
    try {
      await _firestore.collection('cats').doc(catId).update(catData);
    } catch (e) {
      print('Error updating cat: $e');
      rethrow;
    }
  }
}
