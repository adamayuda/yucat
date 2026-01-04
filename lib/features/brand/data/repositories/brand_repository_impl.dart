import 'package:yucat/features/brand/data/datasources/brand_datasource.dart';
import 'package:yucat/features/brand/data/mappers/brand_document_mapper.dart';
import 'package:yucat/features/brand/domain/entities/brand_entity.dart';
import 'package:yucat/features/brand/domain/repositories/brand_repository.dart';

class BrandRepositoryImpl implements BrandRepository {
  final BrandDataSource _dataSource;
  final BrandDocumentMapper _mapper;

  BrandRepositoryImpl({
    required BrandDataSource dataSource,
    required BrandDocumentMapper mapper,
  }) : _dataSource = dataSource,
       _mapper = mapper;

  @override
  Future<List<BrandEntity>> getBrands() async {
    final querySnapshot = await _dataSource.getBrands();
    return querySnapshot?.docs.map((doc) => _mapper(doc)).toList() ?? [];
  }
}
