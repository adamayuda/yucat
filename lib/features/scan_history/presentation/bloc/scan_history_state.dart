part of 'scan_history_bloc.dart';

sealed class ScanHistoryState extends Equatable {
  const ScanHistoryState();
}

class ScanHistoryLoadingState extends ScanHistoryState {
  const ScanHistoryLoadingState();

  @override
  List<Object?> get props => [];
}

class ScanHistoryLoadedState extends ScanHistoryState {
  final List<ProductDisplayModel> products;

  const ScanHistoryLoadedState({required this.products});

  @override
  List<Object?> get props => [products];
}
