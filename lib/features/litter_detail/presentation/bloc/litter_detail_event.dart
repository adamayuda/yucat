part of 'litter_detail_bloc.dart';

sealed class LitterDetailEvent extends Equatable {
  const LitterDetailEvent();
}

class LitterDetailInitialEvent extends LitterDetailEvent {
  final LitterDisplayModel? litter;

  const LitterDetailInitialEvent({this.litter});

  @override
  List<Object?> get props => [litter];
}

class LitterDetailToggleSavedEvent extends LitterDetailEvent {
  const LitterDetailToggleSavedEvent();

  @override
  List<Object?> get props => [];
}
