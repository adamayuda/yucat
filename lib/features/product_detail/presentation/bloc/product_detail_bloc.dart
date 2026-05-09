import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/product_display_model.dart';
import 'package:yucat/features/analytics/domain/usecase/log_event_usecase.dart';

part 'product_detail_event.dart';
part 'product_detail_state.dart';

class ProductDetailBloc extends Bloc<ProductDetailEvent, ProductDetailState> {
  final LogEventUsecase _logEventUsecase;

  ProductDetailBloc({
    required LogEventUsecase logEventUsecase,
  }) : _logEventUsecase = logEventUsecase,
       super(ProductDetailHiddenState()) {
    on<ProductDetailInitialEvent>(_onProductDetailInitialEvent);
  }

  Future<void> _onProductDetailInitialEvent(
    ProductDetailInitialEvent event,
    Emitter<ProductDetailState> emit,
  ) async {
    if (event.product != null) {
      _logEventUsecase.call(
        eventName: 'Product Detail Viewed',
        properties: {
          'product_name': event.product!.name,
          'product_brand': event.product!.brand,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      emit(ProductDetailLoadedState(product: event.product!));
      return;
    }

    // If no product provided, emit error state
    emit(ProductDetailErrorState());
  }
}
