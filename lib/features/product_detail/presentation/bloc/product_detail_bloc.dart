import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/product_display_model.dart';
import 'package:yucat/features/analytics/domain/usecase/log_screen_view_usecase.dart';

part 'product_detail_event.dart';
part 'product_detail_state.dart';

class ProductDetailBloc extends Bloc<ProductDetailEvent, ProductDetailState> {
  final LogScreenViewUsecase _logScreenViewUsecase;
  ProductDetailBloc({required LogScreenViewUsecase logScreenViewUsecase})
    : _logScreenViewUsecase = logScreenViewUsecase,
      super(ProductDetailHiddenState()) {
    on<ProductDetailInitialEvent>(_onProductDetailInitialEvent);
  }

  Future<void> _onProductDetailInitialEvent(
    ProductDetailInitialEvent event,
    Emitter<ProductDetailState> emit,
  ) async {
    _logScreenViewUsecase.call(screenName: 'ProductDetailScreen');
    if (event.product != null) {
      emit(ProductDetailLoadedState(product: event.product!));
      return;
    }

    // If no product provided, emit error state
    emit(ProductDetailErrorState());
  }
}
