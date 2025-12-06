import 'package:yucat/features/product_detail/domain/entities/product_entity.dart';
import 'package:yucat/features/search/domain/repositories/search_repository.dart';

class SearchByBarcodeUsecase {
  final SearchRepository _searchRepository;

  SearchByBarcodeUsecase({required SearchRepository searchRepository})
    : _searchRepository = searchRepository;

  Future<ProductEntity?> call({required String barcode}) async {
    return _searchRepository.searchByBarcode(barcode);
  }
}
