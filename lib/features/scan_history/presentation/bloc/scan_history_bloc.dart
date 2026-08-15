import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yucat/features/litter_detail/presentation/models/litter_display_model.dart';
import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';
import 'package:yucat/features/scan_history/domain/usecases/get_litter_history_usecase.dart';
import 'package:yucat/features/scan_history/domain/usecases/get_scan_history_usecase.dart';

part 'scan_history_event.dart';
part 'scan_history_state.dart';

class ScanHistoryBloc extends Bloc<ScanHistoryEvent, ScanHistoryState> {
  final GetScanHistoryUsecase _getScanHistoryUsecase;
  final GetLitterHistoryUsecase _getLitterHistoryUsecase;

  ScanHistoryBloc({
    required GetScanHistoryUsecase getScanHistoryUsecase,
    required GetLitterHistoryUsecase getLitterHistoryUsecase,
  })  : _getScanHistoryUsecase = getScanHistoryUsecase,
        _getLitterHistoryUsecase = getLitterHistoryUsecase,
        super(const ScanHistoryLoadingState()) {
    on<ScanHistoryInitialEvent>(_onInitial);
    on<ScanHistoryRefreshEvent>(_onRefresh);
  }

  Future<void> _onInitial(
    ScanHistoryInitialEvent event,
    Emitter<ScanHistoryState> emit,
  ) async {
    // Food and litter live in separate stores; the page renders them as two
    // sections, so both are loaded together.
    final products = await _getScanHistoryUsecase();
    final litters = await _getLitterHistoryUsecase();
    emit(ScanHistoryLoadedState(products: products, litters: litters));
  }

  Future<void> _onRefresh(
    ScanHistoryRefreshEvent event,
    Emitter<ScanHistoryState> emit,
  ) async {
    // Food and litter live in separate stores; the page renders them as two
    // sections, so both are loaded together.
    final products = await _getScanHistoryUsecase();
    final litters = await _getLitterHistoryUsecase();
    emit(ScanHistoryLoadedState(products: products, litters: litters));
  }
}
