import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/product_model.dart';

part 'product_detail_event.dart';
part 'product_detail_state.dart';

class ProductDetailBloc extends Bloc<ProductDetailEvent, ProductDetailState> {
  ProductDetailBloc() : super(ProductDetailHiddenState()) {
    on<ProductDetailInitialEvent>(_onProductDetailInitialEvent);
  }

  Future<void> _onProductDetailInitialEvent(
    ProductDetailInitialEvent event,
    Emitter<ProductDetailState> emit,
  ) async {
    if (event.product != null) {
      emit(ProductDetailLoadedState(product: event.product!));
      return;
    }

    // If no product provided, emit error state
    emit(ProductDetailErrorState());
  }
}
