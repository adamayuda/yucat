import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';
import 'package:yucat/features/saved_products/domain/usecases/get_saved_products_usecase.dart';

part 'saved_products_event.dart';
part 'saved_products_state.dart';

class SavedProductsBloc
    extends Bloc<SavedProductsEvent, SavedProductsState> {
  final GetSavedProductsUsecase _getSavedProductsUsecase;

  SavedProductsBloc({
    required GetSavedProductsUsecase getSavedProductsUsecase,
  })  : _getSavedProductsUsecase = getSavedProductsUsecase,
        super(const SavedProductsLoadingState()) {
    on<SavedProductsInitialEvent>(_onInitial);
    on<SavedProductsRefreshEvent>(_onRefresh);
  }

  Future<void> _onInitial(
    SavedProductsInitialEvent event,
    Emitter<SavedProductsState> emit,
  ) async {
    final products = await _getSavedProductsUsecase();
    emit(SavedProductsLoadedState(products: products));
  }

  Future<void> _onRefresh(
    SavedProductsRefreshEvent event,
    Emitter<SavedProductsState> emit,
  ) async {
    final products = await _getSavedProductsUsecase();
    emit(SavedProductsLoadedState(products: products));
  }
}
