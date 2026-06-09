import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';
import 'package:yucat/features/scan_history/domain/usecases/get_scan_history_usecase.dart';

part 'scan_history_event.dart';
part 'scan_history_state.dart';

class ScanHistoryBloc extends Bloc<ScanHistoryEvent, ScanHistoryState> {
  final GetScanHistoryUsecase _getScanHistoryUsecase;

  ScanHistoryBloc({
    required GetScanHistoryUsecase getScanHistoryUsecase,
  })  : _getScanHistoryUsecase = getScanHistoryUsecase,
        super(const ScanHistoryLoadingState()) {
    on<ScanHistoryInitialEvent>(_onInitial);
    on<ScanHistoryRefreshEvent>(_onRefresh);
  }

  Future<void> _onInitial(
    ScanHistoryInitialEvent event,
    Emitter<ScanHistoryState> emit,
  ) async {
    final products = await _getScanHistoryUsecase();
    emit(ScanHistoryLoadedState(products: products));
  }

  Future<void> _onRefresh(
    ScanHistoryRefreshEvent event,
    Emitter<ScanHistoryState> emit,
  ) async {
    final products = await _getScanHistoryUsecase();
    emit(ScanHistoryLoadedState(products: products));
  }
}
