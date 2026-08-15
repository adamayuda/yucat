import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yucat/features/litter_detail/presentation/models/litter_display_model.dart';
import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';
import 'package:yucat/features/saved_products/domain/usecases/get_saved_litters_usecase.dart';
import 'package:yucat/features/saved_products/domain/usecases/get_saved_products_usecase.dart';

part 'saved_products_event.dart';
part 'saved_products_state.dart';

class SavedProductsBloc
    extends Bloc<SavedProductsEvent, SavedProductsState> {
  final GetSavedProductsUsecase _getSavedProductsUsecase;
  final GetSavedLittersUsecase _getSavedLittersUsecase;

  SavedProductsBloc({
    required GetSavedProductsUsecase getSavedProductsUsecase,
    required GetSavedLittersUsecase getSavedLittersUsecase,
  })  : _getSavedProductsUsecase = getSavedProductsUsecase,
        _getSavedLittersUsecase = getSavedLittersUsecase,
        super(const SavedProductsLoadingState()) {
    on<SavedProductsInitialEvent>(_onInitial);
    on<SavedProductsRefreshEvent>(_onRefresh);
  }

  Future<void> _onInitial(
    SavedProductsInitialEvent event,
    Emitter<SavedProductsState> emit,
  ) async {
    final products = await _getSavedProductsUsecase();
    final litters = await _getSavedLittersUsecase();
    emit(SavedProductsLoadedState(products: products, litters: litters));
  }

  Future<void> _onRefresh(
    SavedProductsRefreshEvent event,
    Emitter<SavedProductsState> emit,
  ) async {
    final products = await _getSavedProductsUsecase();
    final litters = await _getSavedLittersUsecase();
    emit(SavedProductsLoadedState(products: products, litters: litters));
  }
}
