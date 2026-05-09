import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yucat/features/cat_create/bloc/cat_create_bloc.dart';
import 'package:yucat/features/cat_create/mappers/cat_model_to_create_mapper.dart';
import 'package:yucat/features/cat_create/presentation/models/cat_create_model.dart';
import 'package:yucat/features/cat_listing/models/cat_model.dart';
import 'package:yucat/features/cat_create/widgets/steps/activity_step.dart';
import 'package:yucat/features/cat_create/widgets/steps/age_step.dart';
import 'package:yucat/features/cat_create/widgets/steps/breed_step.dart';
import 'package:yucat/features/cat_create/widgets/steps/cat_name_step.dart';
import 'package:yucat/features/cat_create/widgets/steps/coat_step.dart';
import 'package:yucat/features/cat_create/widgets/steps/gender_step.dart';
import 'package:yucat/features/cat_create/widgets/steps/health_conditions_step.dart';
import 'package:yucat/features/cat_create/widgets/steps/neutered_status_step.dart';
import 'package:yucat/features/cat_create/widgets/steps/profile_photo_step.dart';
import 'package:yucat/presentation/components/wizard_step_shell.dart';
import 'package:yucat/service_locator.dart';

const _totalSteps = 9;

@RoutePage()
class CreateCatPage extends StatefulWidget {
  final CatModel? cat;

  const CreateCatPage({super.key, this.cat});

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

  @override
  void initState() {
    super.initState();
    _bloc = context.read<CatCreateBloc>();

    // Convert CatModel to CatCreateModel if editing
    CatCreateModel? catCreateModel;
    if (widget.cat != null) {
      final mapper = sl<CatModelToCreateMapper>();
      catCreateModel = mapper(widget.cat!);
      _nameController.text = catCreateModel.name;
    }

    _bloc.add(CatCreateInitialEvent(cat: catCreateModel));
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
      case CatCreateLoadedState(:final currentStep, :final cat, :final isSubmitting):
        return _buildPageView(currentStep: currentStep, cat: cat, isSubmitting: isSubmitting);
    }
  }

  Widget _buildPageView({
    required int currentStep,
    required CatCreateModel cat,
    required bool isSubmitting,
  }) {
    final isLast = currentStep == _totalSteps - 1;
    final isHealthStep = currentStep == 7;
    final isBreedStep = currentStep == 8;
    final isEditing = widget.cat != null;
    final hasHealthSelection = cat.healthConditions.isNotEmpty;
    final finalCtaLabel = isEditing ? 'Save changes' : 'Create profile';
    return WizardStepShell(
      currentStep: currentStep,
      totalSteps: _totalSteps,
      ctaLabel: isLast ? finalCtaLabel : 'Next',
      altCtaLabel: isHealthStep ? 'None of these' : null,
      hasSelection: isHealthStep ? hasHealthSelection : true,
      isSubmitting: isSubmitting,
      useCloseIcon: currentStep == 0,
      floatingNext: isHealthStep || isBreedStep,
      onBack: () => _goToPreviousStep(currentStep),
      onNext: isLast ? _handleSubmit : () => _goToNextStep(step: currentStep),
      child: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          for (var i = 0; i < _totalSteps; i++) _buildStepContent(i, cat),
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
