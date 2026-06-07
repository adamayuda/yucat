part of 'cat_create_bloc.dart';

sealed class CatCreateState extends Equatable {
  const CatCreateState();
}

class CatCreateLoadedState extends CatCreateState {
  final int currentStep;
  final CatCreateModel cat;
  final bool isSubmitting;

  /// One-shot transient error message for a SnackBar (e.g. create/update
  /// failed). [errorTick] increments every time we want to re-fire the
  /// SnackBar so [BlocListener] sees a state change even if the message
  /// is unchanged.
  final String? transientError;
  final int errorTick;

  const CatCreateLoadedState({
    required this.currentStep,
    required this.cat,
    this.isSubmitting = false,
    this.transientError,
    this.errorTick = 0,
  });

  @override
  List<Object?> get props =>
      [currentStep, cat, isSubmitting, transientError, errorTick];
}
