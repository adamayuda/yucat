part of 'litter_detail_bloc.dart';

sealed class LitterDetailState extends Equatable {
  const LitterDetailState();
}

class LitterDetailHiddenState extends LitterDetailState {
  @override
  List<Object?> get props => [];
}

class LitterDetailLoadedState extends LitterDetailState {
  final LitterDisplayModel litter;
  final bool isSaved;

  const LitterDetailLoadedState({
    required this.litter,
    this.isSaved = false,
  });

  LitterDetailLoadedState copyWith({bool? isSaved}) => LitterDetailLoadedState(
        litter: litter,
        isSaved: isSaved ?? this.isSaved,
      );

  @override
  List<Object?> get props => [litter, isSaved];
}

class LitterDetailErrorState extends LitterDetailState {
  @override
  List<Object?> get props => [];
}
