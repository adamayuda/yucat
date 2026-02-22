import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/auth/domain/usecase/current_user_usecase.dart';
import 'package:yucat/features/cat_create/bloc/cat_create_bloc.dart';
import 'package:yucat/features/cat_create/presentation/models/cat_create_model.dart';
import 'package:yucat/features/cat_create/widgets/stepper_bar_widget.dart';
import 'package:yucat/features/cat_create/widgets/stepper_bottom_widget.dart';
import 'package:yucat/features/cat_create/widgets/steps/activity_step.dart';
import 'package:yucat/features/cat_create/widgets/steps/age_step.dart';
import 'package:yucat/features/cat_create/widgets/steps/breed_step.dart';
import 'package:yucat/features/cat_create/widgets/steps/cat_name_step.dart';
import 'package:yucat/features/cat_create/widgets/steps/coat_step.dart';
import 'package:yucat/features/cat_create/widgets/steps/gender_step.dart';
import 'package:yucat/features/cat_create/widgets/steps/health_conditions_step.dart';
import 'package:yucat/features/cat_create/widgets/steps/neutered_status_step.dart';
import 'package:yucat/features/cat_create/widgets/steps/profile_photo_step.dart';
import 'package:yucat/service_locator.dart';

@RoutePage()
class CreateCatPage extends StatefulWidget {
  const CreateCatPage({super.key});

  @override
  State<CreateCatPage> createState() => _CreateCatPageState();
}

class _CreateCatPageState extends State<CreateCatPage> {
  final _nameController = TextEditingController();
  final _nameFieldKey = GlobalKey<FormFieldState<String>>();

  bool _useDefaultPhoto = false;
  final ImagePicker _imagePicker = ImagePicker();
  final PageController _pageController = PageController();

  static const List<String> _breeds = [
    'Other',
    'Abyssinian',
    'American Shorthair',
    'Bengal',
    'Birman',
    'British Shorthair',
    'Burmese',
    'Devon Rex',
    'Domestic Longhair',
    'Domestic Shorthair',
    'Exotic Shorthair',
    'Maine Coon',
    'Norwegian Forest Cat',
    'Oriental Shorthair',
    'Persian',
    'Ragdoll',
    'Russian Blue',
    'Scottish Fold',
    'Siamese',
    'Sphynx',
    'Tabby',
    'Tonkinese',
    'Turkish Angora',
    'Tuxedo',
  ];

  late CatCreateBloc _bloc;
  late CurrentUserUsecase _currentUserUsecase;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<CatCreateBloc>();
    _currentUserUsecase = sl<CurrentUserUsecase>();
    _bloc.add(const CatCreateStepChangedEvent(step: 0));
    // Listen to name field changes to update swipe physics
    _nameController.addListener(_onNameChanged);
  }

  void _onNameChanged() {
    // Rebuild to update PageView physics when name changes
    setState(() {});

    final currentState = _bloc.state;
    if (currentState is CatCreateLoadedState) {
      final updatedCat = currentState.cat.copyWith(
        name: _nameController.text.trim(),
      );
      _bloc.add(CatCreateUpdateCatEvent(cat: updatedCat));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _goToNextStep({required int step}) {
    // Dismiss keyboard when navigating to next step
    FocusScope.of(context).unfocus();

    // Ensure the cat name is provided before leaving step 0
    if (step == 0) {
      final isValid = _nameFieldKey.currentState?.validate() ?? false;
      if (!isValid) {
        return;
      }
    }

    _bloc.add(CatCreateGoToNextStepEvent(step: step));
  }

  void _goToPreviousStep(int currentStep) {
    if (currentStep > 0) {
      _bloc.add(CatCreateStepChangedEvent(step: currentStep - 1));
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CatCreateBloc, CatCreateState>(
      bloc: _bloc,
      listenWhen: (previous, current) => _listenWhen(previous, current),
      listener: (context, state) => _onStateChangeListener(state),
      builder: (context, state) => _onStateChangeBuilder(state),
    );
  }

  bool _listenWhen(CatCreateState previous, CatCreateState current) {
    if (current is! CatCreateLoadedState || previous is! CatCreateLoadedState) {
      return false;
    }
    return current.currentStep != previous.currentStep;
  }

  void _onStateChangeListener(CatCreateState state) {
    if (state is CatCreateLoadedState) {
      _pageController.animateToPage(
        state.currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _onStateChangeBuilder(CatCreateState state) {
    switch (state) {
      case CatCreateLoadedState(:final currentStep, :final cat):
        return _buildPageView(currentStep: currentStep, cat: cat);
    }
  }

  Widget _buildPageView({
    required int currentStep,
    required CatCreateModel cat,
  }) {
    return Scaffold(
      backgroundColor: DSColors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight * 1.5 + 8),
        child: AppBar(
          backgroundColor: DSColors.white,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          automaticallyImplyLeading: false,
          titleSpacing: 0,
          flexibleSpace: SafeArea(
            child: SizedBox(
              width: double.infinity,
              child: StepperBarWidget(
                currentStep: currentStep,
                onPreviousStep: () => _goToPreviousStep(currentStep),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 62),
              child: PageView(
                controller: _pageController,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  _buildStepWrapper(0, cat),
                  _buildStepWrapper(1, cat),
                  _buildStepWrapper(2, cat),
                  _buildStepWrapper(3, cat),
                  _buildStepWrapper(4, cat),
                  _buildStepWrapper(5, cat),
                  _buildStepWrapper(6, cat),
                  _buildStepWrapper(7, cat),
                  _buildStepWrapper(8, cat),
                ],
              ),
            ),
          ),
          StepperBottomWidget(
            currentStep: currentStep,
            onNextStep: currentStep == 8
                ? _handleSubmit
                : () => _goToNextStep(step: currentStep),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubmit() async {
    final currentState = _bloc.state;
    if (currentState is CatCreateLoadedState) {
      _bloc.add(CatCreateCatEvent(cat: currentState.cat, context: context));
    }
  }

  Widget _buildStepWrapper(int stepIndex, CatCreateModel cat) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight:
              MediaQuery.of(context).size.height -
              kToolbarHeight * 1.5 -
              MediaQuery.of(context).padding.top -
              MediaQuery.of(context).padding.bottom -
              100, // Approximate space for bottom button
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStepContent(stepIndex, cat),
            SizedBox(height: DSDimens.sizeXl),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent(int stepIndex, CatCreateModel cat) {
    switch (stepIndex) {
      case 0:
        return CatNameStep(
          key: const ValueKey('step_0'),
          nameController: _nameController,
          nameFieldKey: _nameFieldKey,
        );
      case 1:
        return ProfilePhotoStep(
          key: const ValueKey('step_1'),
          profilePhoto: cat.profileImageFile,
          useDefaultPhoto: _useDefaultPhoto,
          imagePicker: _imagePicker,
          onPhotoSelected: (file) {
            setState(() {
              _useDefaultPhoto = false;
            });
            final currentState = _bloc.state;
            if (currentState is CatCreateLoadedState) {
              final updatedCat = currentState.cat.copyWith(
                profileImageFile: file,
              );
              _bloc.add(CatCreateUpdateCatEvent(cat: updatedCat));
            }
          },
          onUseDefault: () {
            setState(() {
              _useDefaultPhoto = true;
            });
            final currentState = _bloc.state;
            if (currentState is CatCreateLoadedState) {
              final updatedCat = currentState.cat.copyWith(
                profileImageFile: null,
              );
              _bloc.add(CatCreateUpdateCatEvent(cat: updatedCat));
            }
          },
          onRemovePhoto: () {
            setState(() {
              _useDefaultPhoto = false;
            });
            final currentState = _bloc.state;
            if (currentState is CatCreateLoadedState) {
              final updatedCat = currentState.cat.copyWith(
                profileImageFile: null,
              );
              _bloc.add(CatCreateUpdateCatEvent(cat: updatedCat));
            }
          },
        );
      case 2:
        return GenderStep(
          key: const ValueKey('step_3'),
          gender: cat.gender,
          onGenderChanged: (value) {
            final currentState = _bloc.state;
            if (currentState is CatCreateLoadedState) {
              final updatedCat = currentState.cat.copyWith(gender: value);
              _bloc.add(CatCreateUpdateCatEvent(cat: updatedCat));
            }
          },
        );
      case 3:
        return AgeStep(
          key: const ValueKey('step_2'),
          age: cat.age,
          onAgeChanged: (value) {
            final currentState = _bloc.state;
            if (currentState is CatCreateLoadedState) {
              final updatedCat = currentState.cat.copyWith(age: value);
              _bloc.add(CatCreateUpdateCatEvent(cat: updatedCat));
            }
          },
        );
      case 4:
        return ActivityStep(
          key: const ValueKey('step_4'),
          activityLevel: cat.activityLevel,
          onActivityLevelChanged: (value) {
            final currentState = _bloc.state;
            if (currentState is CatCreateLoadedState) {
              final updatedCat = currentState.cat.copyWith(
                activityLevel: value,
              );
              _bloc.add(CatCreateUpdateCatEvent(cat: updatedCat));
            }
          },
        );
      case 5:
        return NeuteredStatusStep(
          key: const ValueKey('step_5'),
          status: cat.neuteredStatus,
          onStatusChanged: (value) {
            final currentState = _bloc.state;
            if (currentState is CatCreateLoadedState) {
              final updatedCat = currentState.cat.copyWith(
                neuteredStatus: value,
                neutered: value == 'neutered',
              );
              _bloc.add(CatCreateUpdateCatEvent(cat: updatedCat));
            }
          },
        );
      case 6:
        return CoatStep(
          key: const ValueKey('step_6'),
          coatType: cat.coatType,
          onCoatTypeChanged: (value) {
            final currentState = _bloc.state;
            if (currentState is CatCreateLoadedState) {
              final updatedCat = currentState.cat.copyWith(coatType: value);
              _bloc.add(CatCreateUpdateCatEvent(cat: updatedCat));
            }
          },
        );
      case 7:
        return HealthConditionsStep(
          key: const ValueKey('step_7'),
          selectedHealthConditions: cat.healthConditions,
          onHealthConditionsChanged: (value) {
            final currentState = _bloc.state;
            if (currentState is CatCreateLoadedState) {
              final updatedCat = currentState.cat.copyWith(
                healthConditions: value,
              );
              _bloc.add(CatCreateUpdateCatEvent(cat: updatedCat));
            }
          },
        );
      case 8:
        return BreedStep(
          key: const ValueKey('step_8'),
          selectedBreed: cat.breed ?? 'Other',
          breeds: _breeds,
          onBreedSelected: (breed) {
            final currentState = _bloc.state;
            if (currentState is CatCreateLoadedState) {
              final updatedCat = currentState.cat.copyWith(breed: breed);
              _bloc.add(CatCreateUpdateCatEvent(cat: updatedCat));
            }
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
