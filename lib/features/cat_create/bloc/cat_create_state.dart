part of 'cat_create_bloc.dart';

sealed class CatCreateState extends Equatable {
  const CatCreateState();
}

class CatCreateLoadedState extends CatCreateState {
  final int currentStep;
  final CatCreateModel cat;

  const CatCreateLoadedState({required this.currentStep, required this.cat});

  @override
  List<Object?> get props => [currentStep, cat];
}
