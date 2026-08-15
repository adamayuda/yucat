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
  final List<LitterDisplayModel> litters;

  const ScanHistoryLoadedState({
    required this.products,
    this.litters = const [],
  });

  bool get isEmpty => products.isEmpty && litters.isEmpty;

  @override
  List<Object?> get props => [products, litters];
}
