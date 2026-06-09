part of 'cat_create_bloc.dart';

sealed class CatCreateEvent extends Equatable {
  const CatCreateEvent();
}

class CatCreateInitialEvent extends CatCreateEvent {
  final CatCreateModel? cat;

  /// The step the wizard should open on. Onboarding seeds the name and starts
  /// at the gender step, so the bloc must land on this step directly rather
  /// than emitting step 0 first (which would briefly drive the PageView back
  /// toward the name step and desync the controller).
  final int initialStep;

  const CatCreateInitialEvent({this.cat, this.initialStep = 0});

  @override
  List<Object?> get props => [cat, initialStep];
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

  /// Optional hand-off used in onboarding: when set, the bloc invokes this on
  /// success instead of popping with the result (so the caller can push the
  /// success screen over the wizard). See [CreateCatPage.onCreated].
  final void Function(BuildContext context, CatSummary summary)? onCreated;

  const CatCreateCatEvent({
    required this.cat,
    required this.context,
    this.onCreated,
  });

  @override
  List<Object?> get props => [cat, context];
}
