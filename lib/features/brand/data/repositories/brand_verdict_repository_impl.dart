import 'package:yucat/features/brand/data/datasources/brand_verdict_datasource.dart';
import 'package:yucat/features/brand/domain/entities/brand_verdict.dart';
import 'package:yucat/features/brand/domain/repositories/brand_verdict_repository.dart';

class BrandVerdictRepositoryImpl implements BrandVerdictRepository {
  final BrandVerdictDataSource _dataSource;

  BrandVerdictRepositoryImpl({required BrandVerdictDataSource dataSource})
      : _dataSource = dataSource;

  @override
  Future<BrandVerdict?> analyze({
    required String brand,
    String? catName,
    required String locale,
    BrandCatalogContext? context,
  }) {
    final payload = <String, dynamic>{
      'brand': brand,
      if (catName != null) 'catName': catName,
      'locale': locale,
      if (context != null && context.productCount > 0)
        'catalogContext': {
          'avgScore': context.avgScore.round(),
          'productCount': context.productCount,
          'topCons': context.topCons,
        },
    };
    return _dataSource.analyze(payload);
  }
}
