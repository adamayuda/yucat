import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/product_display_model.dart';
import 'package:yucat/features/analytics/domain/usecase/log_event_usecase.dart';
import 'package:yucat/features/saved_products/domain/usecases/is_product_saved_usecase.dart';
import 'package:yucat/features/saved_products/domain/usecases/save_product_usecase.dart';
import 'package:yucat/features/saved_products/domain/usecases/unsave_product_usecase.dart';

part 'product_detail_event.dart';
part 'product_detail_state.dart';

class ProductDetailBloc extends Bloc<ProductDetailEvent, ProductDetailState> {
  final LogEventUsecase _logEventUsecase;
  final IsProductSavedUsecase _isProductSavedUsecase;
  final SaveProductUsecase _saveProductUsecase;
  final UnsaveProductUsecase _unsaveProductUsecase;

  ProductDetailBloc({
    required LogEventUsecase logEventUsecase,
    required IsProductSavedUsecase isProductSavedUsecase,
    required SaveProductUsecase saveProductUsecase,
    required UnsaveProductUsecase unsaveProductUsecase,
  })  : _logEventUsecase = logEventUsecase,
        _isProductSavedUsecase = isProductSavedUsecase,
        _saveProductUsecase = saveProductUsecase,
        _unsaveProductUsecase = unsaveProductUsecase,
        super(ProductDetailHiddenState()) {
    on<ProductDetailInitialEvent>(_onProductDetailInitialEvent);
    on<ProductDetailToggleSavedEvent>(_onToggleSaved);
  }

  Future<void> _onProductDetailInitialEvent(
    ProductDetailInitialEvent event,
    Emitter<ProductDetailState> emit,
  ) async {
    if (event.product == null) {
      emit(ProductDetailErrorState());
      return;
    }

    final product = event.product!;
    _logEventUsecase.call(
      eventName: 'Product Detail Viewed',
      properties: {
        'product_name': product.name,
        'product_brand': product.brand,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    final isSaved = await _isProductSavedUsecase(product);
    emit(ProductDetailLoadedState(product: product, isSaved: isSaved));
  }

  Future<void> _onToggleSaved(
    ProductDetailToggleSavedEvent event,
    Emitter<ProductDetailState> emit,
  ) async {
    final current = state;
    if (current is! ProductDetailLoadedState) return;

    final nextSaved = !current.isSaved;
    if (nextSaved) {
      await _saveProductUsecase(current.product);
      _logEventUsecase.call(
        eventName: 'Product Saved',
        properties: {
          'product_name': current.product.name,
          'product_brand': current.product.brand,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } else {
      await _unsaveProductUsecase(current.product);
      _logEventUsecase.call(
        eventName: 'Product Unsaved',
        properties: {
          'product_name': current.product.name,
          'product_brand': current.product.brand,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    }
    emit(current.copyWith(isSaved: nextSaved));
  }
}
