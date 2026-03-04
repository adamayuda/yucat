part of 'cat_create_bloc.dart';

sealed class CatCreateEvent extends Equatable {
  const CatCreateEvent();
}

class CatCreateInitialEvent extends CatCreateEvent {
  final CatCreateModel? cat;

  const CatCreateInitialEvent({this.cat});

  @override
  List<Object?> get props => [cat];
}

class CatCreateGoToNextStepEvent extends CatCreateEvent {
  final int step;

  const CatCreateGoToNextStepEvent({required this.step});

  @override
  List<Object?> get props => [step];
}

class CatCreateStepChangedEvent extends CatCreateEvent {
  final int step;

  const CatCreateStepChangedEvent({required this.step});

  @override
  List<Object?> get props => [step];
}

class CatCreateUpdateCatEvent extends CatCreateEvent {
  final CatCreateModel cat;

  const CatCreateUpdateCatEvent({required this.cat});

  @override
  List<Object?> get props => [cat];
}

class CatCreateCatEvent extends CatCreateEvent {
  final CatCreateModel cat;
  final BuildContext context;

  const CatCreateCatEvent({required this.cat, required this.context});

  @override
  List<Object?> get props => [cat, context];
}
