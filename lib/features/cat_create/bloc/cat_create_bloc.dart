import 'package:auto_route/auto_route.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yucat/features/analytics/analytics_events.dart';
import 'package:yucat/features/analytics/domain/usecase/log_event_usecase.dart';
import 'package:yucat/features/analytics/domain/usecase/log_screen_view_usecase.dart';
import 'package:yucat/features/auth/domain/usecase/current_user_usecase.dart';
import 'package:yucat/features/auth/domain/usecase/ensure_signed_in_usecase.dart';
import 'package:yucat/features/cat/domain/usecases/create_cat_usecase.dart';
import 'package:yucat/features/cat/domain/usecases/update_cat_usecase.dart';
import 'package:yucat/features/cat/presentation/utils/cat_product_recommendations.dart';
import 'package:yucat/features/cat_create/mappers/cat_model_to_entity_mapper.dart';
import 'package:yucat/features/cat_create/presentation/models/cat_create_model.dart';
import 'package:yucat/features/cat_create/presentation/models/cat_summary.dart';
import 'package:yucat/services/notification_service.dart';

part 'cat_create_event.dart';
part 'cat_create_state.dart';

class CatCreateBloc extends Bloc<CatCreateEvent, CatCreateState> {
  static const _createCatScreenName = 'CreateCatRoute';
  static const _stepNames = [
    'CatName',
    'Gender',
    'ProfilePhoto',
    'Age',
    'BodyCondition',
    'Activity',
    'WaterIntakeFact',
    'NeuteredStatus',
    'Coat',
    'CoatFact',
    'HealthConditions',
    'Breed',
  ];

  final CreateCatUsecase _createCatUsecase;
  final UpdateCatUsecase _updateCatUsecase;
  final CatModelToEntityMapper _catModelToEntityMapper;
  final CurrentUserUsecase _currentUserUsecase;
  final EnsureSignedInUsecase _ensureSignedInUsecase;
  final LogScreenViewUsecase _logScreenViewUsecase;
  final LogEventUsecase _logEventUsecase;
  final NotificationService _notificationService;

  DateTime? _creationStartTime;
  CatCreateModel? _originalCat;
  int _errorTick = 0;

  CatCreateBloc({
    required CreateCatUsecase createCatUsecase,
    required UpdateCatUsecase updateCatUsecase,
    required CatModelToEntityMapper catModelToEntityMapper,
    required CurrentUserUsecase currentUserUsecase,
    required EnsureSignedInUsecase ensureSignedInUsecase,
    required LogScreenViewUsecase logScreenViewUsecase,
    required LogEventUsecase logEventUsecase,
    required NotificationService notificationService,
  }) : _createCatUsecase = createCatUsecase,
       _updateCatUsecase = updateCatUsecase,
       _catModelToEntityMapper = catModelToEntityMapper,
       _currentUserUsecase = currentUserUsecase,
       _ensureSignedInUsecase = ensureSignedInUsecase,
       _logScreenViewUsecase = logScreenViewUsecase,
       _logEventUsecase = logEventUsecase,
       _notificationService = notificationService,
       super(const CatCreateInitial()) {
    on<CatCreateInitialEvent>(_onCatCreateInitialEvent);
    on<CatCreateGoToNextStepEvent>(_onCatCreateGoToNextStepEvent);
    on<CatCreateStepChangedEvent>(_onCatCreateStepChangedEvent);
    on<CatCreateUpdateCatEvent>(_onCatCreateUpdateCatEvent);
    on<CatCreateCatEvent>(_onCatCreateCatEvent);
  }

  /// Logs a single wizard step view: the generic `Screen View` (kept for
  /// continuity) plus the dedicated `Cat Wizard Step Viewed` event with a stable
  /// `step_index` + `step_name` and `is_edit_mode`, used to build the wizard
  /// flow funnel & drop-off curve in Mixpanel. Filter `is_edit_mode = false`
  /// for the first-time creation drop-off.
  void _trackStepView(int index) {
    _logScreenViewUsecase.call(
      screenName: _createCatScreenName,
      index: index,
      name: _stepNames[index],
    );
    _logEventUsecase.call(
      eventName: AnalyticsEvents.catWizardStepViewed,
      properties: {
        'step_index': index,
        'step_name': _stepNames[index],
        'is_edit_mode': _originalCat != null,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
    // First-time creation only. Editing an existing cat is not the acquisition
    // funnel, and tagging it would put established users into the
    // "stalled mid-wizard" segment every time they tweaked a profile.
    if (_originalCat == null) {
      _notificationService.setFunnelStage(FunnelStage.catCreate);
    }
  }

  void _onCatCreateGoToNextStepEvent(
    CatCreateGoToNextStepEvent event,
    Emitter<CatCreateState> emit,
  ) {
    final currentState = state;
    if (currentState is CatCreateLoadedState &&
        currentState.currentStep < _stepNames.length - 1) {
      final nextStep = event.step + 1;

      _logEventUsecase.call(
        eventName: AnalyticsEvents.catCreationStepCompleted,
        properties: {
          'step_index': event.step,
          'step_name': _stepNames[event.step],
          'next_step_index': nextStep,
          'next_step_name': _stepNames[nextStep],
        },
      );

      emit(CatCreateLoadedState(currentStep: nextStep, cat: currentState.cat));
      _trackStepView(nextStep);
    }
  }

  void _onCatCreateStepChangedEvent(
    CatCreateStepChangedEvent event,
    Emitter<CatCreateState> emit,
  ) {
    final currentState = state;
    if (currentState is CatCreateLoadedState) {
      if (event.step < currentState.currentStep) {
        _logEventUsecase.call(
          eventName: AnalyticsEvents.catCreationStepAbandoned,
          properties: {
            'from_step': currentState.currentStep,
            'to_step': event.step,
            'from_step_name': _stepNames[currentState.currentStep],
            'to_step_name': _stepNames[event.step],
          },
        );
      }

      emit(
        CatCreateLoadedState(currentStep: event.step, cat: currentState.cat),
      );
      _trackStepView(event.step);
    }
  }

  Future<void> _onCatCreateInitialEvent(
    CatCreateInitialEvent event,
    Emitter<CatCreateState> emit,
  ) async {
    _creationStartTime = DateTime.now();

    // Edit mode is signalled by an existing Firestore id on the incoming
    // model. A non-null model without an id is just seeded values (e.g.
    // name + photo collected during onboarding) — still a creation.
    final isEditMode = event.cat?.id != null;
    _originalCat = isEditMode ? event.cat : null;

    _logEventUsecase.call(
      eventName: isEditMode
          ? AnalyticsEvents.catEditStarted
          : AnalyticsEvents.catCreationStarted,
      properties: {
        'is_edit_mode': isEditMode,
        if (isEditMode) 'cat_name': event.cat!.name,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    // Land directly on the requested starting step. Emitting step 0 first
    // (then jumping) would make the PageView animate toward the name step and
    // desync the controller from the bloc on the seeded onboarding path.
    emit(
      CatCreateLoadedState(
        currentStep: event.initialStep,
        cat: event.cat ?? const CatCreateModel(name: '', neutered: false),
      ),
    );
    _trackStepView(event.initialStep);
  }

  void _onCatCreateUpdateCatEvent(
    CatCreateUpdateCatEvent event,
    Emitter<CatCreateState> emit,
  ) {
    final currentState = state;
    if (currentState is CatCreateLoadedState) {
      // In edit mode the Firestore id must never be dropped. A step widget can
      // fire `onChanged` during the first build — before `CatCreateInitialEvent`
      // is processed — reading the bloc's empty initial state; that update is
      // then queued after init and would otherwise overwrite the seeded id,
      // breaking "Save changes" with "Cannot update cat without ID". Re-anchor
      // the id from the original cat being edited (no-op for create mode).
      final preservedId = event.cat.id ?? _originalCat?.id;
      emit(
        CatCreateLoadedState(
          currentStep: currentState.currentStep,
          cat: event.cat.copyWith(id: preservedId),
        ),
      );
    }
  }

  /// The optional profile fields the user actually filled in.
  ///
  /// Eight of the ten input steps are freely skippable — `create_cat_page.dart`
  /// hard-codes `hasSelection = true` for gender, age, body condition,
  /// activity, neutered status, coat and breed — and every optional field flows
  /// nullable all the way into Firestore. That directly degrades
  /// `cat_product_assessment.dart`, which scores across six dimensions: a cat
  /// with no age group or breed silently gets a generic verdict instead of the
  /// personalised one the product promises. Counting them is how you find out
  /// how often that happens.
  ///
  /// `name` is excluded (always required) as is the photo (its own explicit
  /// "Skip" affordance, already reported as `has_photo`).
  List<String> _completedFields(CatCreateModel cat) => [
        if (cat.gender != null) 'gender',
        if (cat.age != null) 'age',
        if (cat.ageGroup != null) 'age_group',
        if (cat.weight != null) 'weight',
        if (cat.weightCategory != null) 'weight_category',
        if (cat.activityLevel != null) 'activity_level',
        if (cat.neuteredStatus != null) 'neutered_status',
        if (cat.coatType != null) 'coat_type',
        if (cat.breed != null) 'breed',
        if (cat.healthConditions.isNotEmpty) 'health_conditions',
      ];

  /// Total optional fields [_completedFields] can report, so `fields_completed`
  /// is readable in Mixpanel without hardcoding the denominator in a report.
  static const int _optionalFieldCount = 10;

  /// Step label for a wizard index, or `unknown` if the index is out of range.
  /// Emitted alongside `step_index` on failures so a renumbered wizard does not
  /// silently repoint historical error reports at a different screen.
  String _stepName(int index) =>
      index >= 0 && index < _stepNames.length ? _stepNames[index] : 'unknown';

  /// The uid to write the new cat under, retrying anonymous sign-in if the
  /// boot-time attempt never landed. Throws [AuthUnavailableException] — a
  /// named type, so `Cat Creation Failed` reports something actionable — when
  /// there is still no session, which is genuinely unrecoverable here.
  Future<String> _requireUserId() async {
    final user = _currentUserUsecase() ?? await _ensureSignedInUsecase();
    if (user == null) throw const AuthUnavailableException();
    return user.uid;
  }

  Future<void> _onCatCreateCatEvent(
    CatCreateCatEvent event,
    Emitter<CatCreateState> emit,
  ) async {
    final currentState = state;
    if (currentState is CatCreateLoadedState && currentState.isSubmitting) return;

    emit(CatCreateLoadedState(
      currentStep: (currentState as CatCreateLoadedState).currentStep,
      cat: currentState.cat,
      isSubmitting: true,
    ));

    try {
      final isEditMode = _originalCat != null;

      if (isEditMode) {
        // Update existing cat
        final catEntity = _catModelToEntityMapper(event.cat);
        await _updateCatUsecase(
          cat: catEntity,
          profileImageFile: event.cat.profileImageFile,
        );

        // The profile changed — drop cached picks so the next fetch re-scores
        // against the new attributes (otherwise stale picks survive the edit).
        invalidateProductPicksCache(catEntity.id);

        // Track which fields changed
        final fieldsChanged = _getChangedFields(event.cat);

        _logEventUsecase.call(
          eventName: AnalyticsEvents.catProfileUpdated,
          properties: {
            'cat_name': event.cat.name,
            'cat_age_group': event.cat.ageGroup ?? 'unknown',
            'cat_breed': event.cat.breed ?? 'unknown',
            'fields_changed': fieldsChanged,
            'timestamp': DateTime.now().toIso8601String(),
          },
        );
      } else {
        // Create new cat.
        //
        // Re-establish the session here rather than trusting the one Splash
        // was supposed to create. Anonymous sign-in can fail silently at boot
        // and the wizard touches no network for the twelve steps in between,
        // so this is the first moment the failure becomes observable — and it
        // used to become observable as `user!.uid` throwing a bare _TypeError.
        final userId = await _requireUserId();
        await _createCatUsecase(
          userId: userId,
          name: event.cat.name,
          age: event.cat.age,
          ageGroup: event.cat.ageGroup,
          weight: event.cat.weight,
          neutered: event.cat.neutered,
          profileImageFile: event.cat.profileImageFile,
          neuteredStatus: event.cat.neuteredStatus,
          breed: event.cat.breed,
          weightCategory: event.cat.weightCategory,
          activityLevel: event.cat.activityLevel,
          coatType: event.cat.coatType,
          gender: event.cat.gender,
          healthConditions: event.cat.healthConditions,
        );

        final completedFields = _completedFields(event.cat);
        final creationTimeSeconds = _creationStartTime != null
            ? DateTime.now().difference(_creationStartTime!).inSeconds
            : null;

        _logEventUsecase.call(
          eventName: AnalyticsEvents.catCreated,
          properties: {
            'name': event.cat.name,
            'age_group': event.cat.ageGroup,
            'breed': event.cat.breed,
            'gender': event.cat.gender,
            'has_health_conditions': event.cat.healthConditions.isNotEmpty,
            'health_conditions': event.cat.healthConditions,
            'neutered': event.cat.neutered,
            'has_photo': event.cat.profileImageFile != null,
            // How much of the personalisation promise this profile can actually
            // fulfil. See _completedFields.
            'fields_completed': completedFields.length,
            'fields_skipped': _optionalFieldCount - completedFields.length,
            'completed_field_names': completedFields,
            'creation_time_seconds': creationTimeSeconds,
            'timestamp': DateTime.now().toIso8601String(),
          },
        );
      }

      // Return a structured profile summary so callers (e.g. onboarding) can
      // surface it on a success screen. Onboarding supplies [onCreated] to push
      // that screen over the wizard (forward slide); everyone else pops with it.
      if (!event.context.mounted) return;
      final summary = CatSummary.fromModel(event.cat);
      if (event.onCreated != null) {
        event.onCreated!(event.context, summary);
      } else {
        event.context.router.maybePop(summary);
      }
    } catch (e) {
      final isEditMode = _originalCat != null;
      _logEventUsecase.call(
        eventName: isEditMode
            ? AnalyticsEvents.catUpdateFailed
            : AnalyticsEvents.catCreationFailed,
        properties: {
          // Dart runtime type. Coarse — a bare `_TypeError` says nothing about
          // *where* — so throw named exceptions (see AuthUnavailableException)
          // for failures worth telling apart in Mixpanel.
          'error_type': e.runtimeType.toString(),
          'error_message': e.toString(),
          'step_index': (state as CatCreateLoadedState).currentStep,
          'step_name': _stepName((state as CatCreateLoadedState).currentStep),
        },
      );

      _errorTick++;
      emit(CatCreateLoadedState(
        currentStep: (state as CatCreateLoadedState).currentStep,
        cat: (state as CatCreateLoadedState).cat,
        isSubmitting: false,
        transientError:
            isEditMode ? CatCreateError.save : CatCreateError.create,
        errorTick: _errorTick,
      ));
    }
  }

  List<String> _getChangedFields(CatCreateModel updatedCat) {
    if (_originalCat == null) return [];

    final changedFields = <String>[];

    if (updatedCat.name != _originalCat!.name) changedFields.add('name');
    if (updatedCat.age != _originalCat!.age) changedFields.add('age');
    if (updatedCat.ageGroup != _originalCat!.ageGroup) {
      changedFields.add('ageGroup');
    }
    if (updatedCat.weight != _originalCat!.weight) changedFields.add('weight');
    if (updatedCat.neutered != _originalCat!.neutered) {
      changedFields.add('neutered');
    }
    if (updatedCat.neuteredStatus != _originalCat!.neuteredStatus) {
      changedFields.add('neuteredStatus');
    }
    if (updatedCat.breed != _originalCat!.breed) changedFields.add('breed');
    if (updatedCat.weightCategory != _originalCat!.weightCategory) {
      changedFields.add('weightCategory');
    }
    if (updatedCat.activityLevel != _originalCat!.activityLevel) {
      changedFields.add('activityLevel');
    }
    if (updatedCat.coatType != _originalCat!.coatType) {
      changedFields.add('coatType');
    }
    if (updatedCat.healthConditions != _originalCat!.healthConditions) {
      changedFields.add('healthConditions');
    }
    if (updatedCat.profileImageFile != null) changedFields.add('profileImage');

    return changedFields;
  }
}
