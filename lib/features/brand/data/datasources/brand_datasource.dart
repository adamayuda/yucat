import 'package:cloud_firestore/cloud_firestore.dart';

class BrandDataSource {
  final FirebaseFirestore _firestore;

  BrandDataSource({required FirebaseFirestore firestore})
    : _firestore = firestore;

  Future<QuerySnapshot<Map<String, dynamic>>?> getBrands() async {
    try {
      final querySnapshot = await _firestore.collection('brands').get();

      return querySnapshot;
    } catch (e) {
      print('Error fetching brands: $e');
      return null;
    }
  }
}
