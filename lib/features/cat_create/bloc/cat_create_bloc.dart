import 'package:auto_route/auto_route.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yucat/config/routes/router.dart';
import 'package:yucat/features/analytics/domain/usecase/log_screen_view_usecase.dart';
import 'package:yucat/features/auth/domain/usecase/current_user_usecase.dart';
import 'package:yucat/features/cat/domain/usecases/create_cat_usecase.dart';
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
  final CurrentUserUsecase _currentUserUsecase;
  final LogScreenViewUsecase _logScreenViewUsecase;

  CatCreateBloc({
    required CreateCatUsecase createCatUsecase,
    required CurrentUserUsecase currentUserUsecase,
    required LogScreenViewUsecase logScreenViewUsecase,
  }) : _createCatUsecase = createCatUsecase,
       _currentUserUsecase = currentUserUsecase,
       _logScreenViewUsecase = logScreenViewUsecase,
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
    // _logScreenViewUsecase.call(screenName: 'CatCreateScreen');
    emit(
      const CatCreateLoadedState(
        currentStep: 0,
        cat: CatCreateModel(name: '', neutered: false),
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
      // emit(const CatCreateLoadingState());

      final user = _currentUserUsecase();
      // if (user == null) {
      //   emit(
      //     const CatCreateErrorState(
      //       message: 'You must be signed in to create a cat.',
      //     ),
      //   );
      //   return;
      // }

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

      event.context.router.push(const CatListingRoute());
      // emit(const CatCreateLoadedState());
    } catch (e) {
      // emit(CatCreateErrorState(message: e.toString()));
    }
  }
}
