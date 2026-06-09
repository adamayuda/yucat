part of 'scan_history_bloc.dart';

sealed class ScanHistoryEvent extends Equatable {
  const ScanHistoryEvent();
}

class ScanHistoryInitialEvent extends ScanHistoryEvent {
  const ScanHistoryInitialEvent();

  @override
  List<Object?> get props => [];
}

class ScanHistoryRefreshEvent extends ScanHistoryEvent {
  const ScanHistoryRefreshEvent();

  @override
  List<Object?> get props => [];
}
