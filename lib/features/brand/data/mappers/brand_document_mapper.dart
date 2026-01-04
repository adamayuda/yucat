import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yucat/features/brand/domain/entities/brand_entity.dart';

abstract class BrandDocumentMapper {
  BrandEntity call(QueryDocumentSnapshot<Map<String, dynamic>> doc);
}

class BrandDocumentMapperImpl implements BrandDocumentMapper {
  @override
  BrandEntity call(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return BrandEntity(
      name: data['name'] as String,
      image: data['image'] as String,
    );
  }
}
