import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yucat/features/auth/domain/usecase/current_user_usecase.dart';
import 'package:yucat/features/cat/domain/usecases/create_cat_usecase.dart';
import 'package:yucat/features/cat_create/presentation/presentation/models/cat_create_model.dart';

part 'cat_create_event.dart';
part 'cat_create_state.dart';

class CatCreateBloc extends Bloc<CatCreateEvent, CatCreateState> {
  final CreateCatUsecase _createCatUsecase;
  final CurrentUserUsecase _currentUserUsecase;

  CatCreateBloc({
    required CreateCatUsecase createCatUsecase,
    required CurrentUserUsecase currentUserUsecase,
  }) : _createCatUsecase = createCatUsecase,
       _currentUserUsecase = currentUserUsecase,
       super(const CatCreateLoadingState()) {
    on<CatCreateInitialEvent>(_onCatCreateInitialEvent);
    on<CatCreateCatEvent>(_onCatCreateCatEvent);
  }

  Future<void> _onCatCreateInitialEvent(
    CatCreateInitialEvent event,
    Emitter<CatCreateState> emit,
  ) async {
    add(
      const CatCreateCatEvent(cat: CatCreateModel(name: '', neutered: false)),
    );
  }

  Future<void> _onCatCreateCatEvent(
    CatCreateCatEvent event,
    Emitter<CatCreateState> emit,
  ) async {
    try {
      emit(const CatCreateLoadingState());

      final user = _currentUserUsecase();
      if (user == null) {
        emit(
          const CatCreateErrorState(
            message: 'You must be signed in to create a cat.',
          ),
        );
        return;
      }

      await _createCatUsecase(
        userId: user.uid,
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

      emit(const CatCreateLoadedState());
    } catch (e) {
      emit(CatCreateErrorState(message: e.toString()));
    }
  }
}
