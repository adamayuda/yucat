import 'package:auto_route/auto_route.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yucat/config/routes/router.dart';
import 'package:yucat/features/analytics/domain/usecase/log_event_usecase.dart';
import 'package:yucat/features/analytics/domain/usecase/log_screen_view_usecase.dart';
import 'package:yucat/features/auth/domain/usecase/current_user_usecase.dart';
import 'package:yucat/features/cat/domain/usecases/create_cat_usecase.dart';
import 'package:yucat/features/cat/domain/usecases/update_cat_usecase.dart';
import 'package:yucat/features/cat_create/mappers/cat_model_to_entity_mapper.dart';
import 'package:yucat/features/cat_create/presentation/models/cat_create_model.dart';

part 'cat_create_event.dart';
part 'cat_create_state.dart';

class CatCreateBloc extends Bloc<CatCreateEvent, CatCreateState> {
  static const _createCatScreenName = 'CreateCatRoute';
  static const _stepNames = [
    'CatName',
    'ProfilePhoto',
    'Gender',
    'Age',
    'Activity',
    'NeuteredStatus',
    'Coat',
    'HealthConditions',
    'Breed',
  ];

  final CreateCatUsecase _createCatUsecase;
  final UpdateCatUsecase _updateCatUsecase;
  final CatModelToEntityMapper _catModelToEntityMapper;
  final CurrentUserUsecase _currentUserUsecase;
  final LogScreenViewUsecase _logScreenViewUsecase;
  final LogEventUsecase _logEventUsecase;

  DateTime? _creationStartTime;
  CatCreateModel? _originalCat;

  CatCreateBloc({
    required CreateCatUsecase createCatUsecase,
    required UpdateCatUsecase updateCatUsecase,
    required CatModelToEntityMapper catModelToEntityMapper,
    required CurrentUserUsecase currentUserUsecase,
    required LogScreenViewUsecase logScreenViewUsecase,
    required LogEventUsecase logEventUsecase,
  }) : _createCatUsecase = createCatUsecase,
       _updateCatUsecase = updateCatUsecase,
       _catModelToEntityMapper = catModelToEntityMapper,
       _currentUserUsecase = currentUserUsecase,
       _logScreenViewUsecase = logScreenViewUsecase,
       _logEventUsecase = logEventUsecase,
       super(
         const CatCreateLoadedState(
           currentStep: 0,
           cat: CatCreateModel(name: '', neutered: false),
         ),
       ) {
    on<CatCreateInitialEvent>(_onCatCreateInitialEvent);
    on<CatCreateGoToNextStepEvent>(_onCatCreateGoToNextStepEvent);
    on<CatCreateStepChangedEvent>(_onCatCreateStepChangedEvent);
    on<CatCreateUpdateCatEvent>(_onCatCreateUpdateCatEvent);
    on<CatCreateCatEvent>(_onCatCreateCatEvent);
  }

  void _onCatCreateGoToNextStepEvent(
    CatCreateGoToNextStepEvent event,
    Emitter<CatCreateState> emit,
  ) {
    final currentState = state;
    if (currentState is CatCreateLoadedState && currentState.currentStep < 8) {
      final nextStep = event.step + 1;

      _logEventUsecase.call(
        eventName: 'Cat Creation Step Completed',
        properties: {
          'step_index': event.step,
          'step_name': _stepNames[event.step],
          'next_step_index': nextStep,
          'next_step_name': _stepNames[nextStep],
        },
      );

      emit(CatCreateLoadedState(currentStep: nextStep, cat: currentState.cat));
      _logScreenViewUsecase.call(
        screenName: _createCatScreenName,
        index: nextStep,
        name: _stepNames[nextStep],
      );
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
          eventName: 'Cat Creation Step Abandoned',
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
      _logScreenViewUsecase.call(
        screenName: _createCatScreenName,
        index: event.step,
        name: _stepNames[event.step],
      );
    }
  }

  Future<void> _onCatCreateInitialEvent(
    CatCreateInitialEvent event,
    Emitter<CatCreateState> emit,
  ) async {
    _creationStartTime = DateTime.now();

    final isEditMode = event.cat != null;
    _originalCat = event.cat;

    _logEventUsecase.call(
      eventName: isEditMode ? 'Cat Edit Started' : 'Cat Creation Started',
      properties: {
        'is_edit_mode': isEditMode,
        if (isEditMode) 'cat_name': event.cat!.name,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    emit(
      CatCreateLoadedState(
        currentStep: 0,
        cat: event.cat ?? const CatCreateModel(name: '', neutered: false),
      ),
    );
  }

  void _onCatCreateUpdateCatEvent(
    CatCreateUpdateCatEvent event,
    Emitter<CatCreateState> emit,
  ) {
    final currentState = state;
    if (currentState is CatCreateLoadedState) {
      emit(
        CatCreateLoadedState(
          currentStep: currentState.currentStep,
          cat: event.cat,
        ),
      );
    }
  }

  Future<void> _onCatCreateCatEvent(
    CatCreateCatEvent event,
    Emitter<CatCreateState> emit,
  ) async {
    try {
      final user = _currentUserUsecase();
      final isEditMode = _originalCat != null;

      if (isEditMode) {
        // Update existing cat
        final catEntity = _catModelToEntityMapper(event.cat);
        await _updateCatUsecase(cat: catEntity);

        // Track which fields changed
        final fieldsChanged = _getChangedFields(event.cat);

        _logEventUsecase.call(
          eventName: 'Cat Profile Updated',
          properties: {
            'cat_name': event.cat.name,
            'cat_age_group': event.cat.ageGroup ?? 'unknown',
            'cat_breed': event.cat.breed ?? 'unknown',
            'fields_changed': fieldsChanged,
            'timestamp': DateTime.now().toIso8601String(),
          },
        );
      } else {
        // Create new cat
        await _createCatUsecase(
          userId: user!.uid,
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
          healthConditions: event.cat.healthConditions,
        );

        final creationTimeSeconds = _creationStartTime != null
            ? DateTime.now().difference(_creationStartTime!).inSeconds
            : null;

        _logEventUsecase.call(
          eventName: 'Cat Created',
          properties: {
            'name': event.cat.name,
            'age_group': event.cat.ageGroup,
            'breed': event.cat.breed,
            'has_health_conditions': event.cat.healthConditions.isNotEmpty,
            'health_conditions': event.cat.healthConditions,
            'neutered': event.cat.neutered,
            'has_photo': event.cat.profileImageFile != null,
            'creation_time_seconds': creationTimeSeconds,
            'timestamp': DateTime.now().toIso8601String(),
          },
        );
      }

      event.context.router.push(const CatListingRoute());
    } catch (e) {
      final isEditMode = _originalCat != null;
      _logEventUsecase.call(
        eventName: isEditMode ? 'Cat Update Failed' : 'Cat Creation Failed',
        properties: {
          'error_type': e.runtimeType.toString(),
          'error_message': e.toString(),
          'step_index': (state as CatCreateLoadedState).currentStep,
        },
      );
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
