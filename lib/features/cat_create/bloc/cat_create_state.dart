part of 'cat_create_bloc.dart';

/// Semantic kind of a one-shot create/edit failure. The UI layer turns this
/// into a localized SnackBar message — no user-facing copy lives in the bloc.
enum CatCreateError { create, save }

sealed class CatCreateState extends Equatable {
  const CatCreateState();
}

class CatCreateLoadedState extends CatCreateState {
  final int currentStep;
  final CatCreateModel cat;
  final bool isSubmitting;

  /// One-shot transient error for a SnackBar (e.g. create/update failed).
  /// [errorTick] increments every time we want to re-fire the SnackBar so
  /// [BlocListener] sees a state change even if the error kind is unchanged.
  final CatCreateError? transientError;
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
