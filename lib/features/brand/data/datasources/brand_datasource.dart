import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class BrandDataSource {
  final FirebaseFirestore _firestore;

  BrandDataSource({required FirebaseFirestore firestore})
    : _firestore = firestore;

  Future<QuerySnapshot<Map<String, dynamic>>?> getBrands() async {
    try {
      final querySnapshot = await _firestore.collection('brands').get();

      return querySnapshot;
    } catch (e) {
      debugPrint('Error fetching brands: $e');
      return null;
    }
  }
}
