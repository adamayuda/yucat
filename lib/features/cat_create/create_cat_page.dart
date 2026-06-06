import 'dart:io';

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
import 'package:yucat/features/cat_create/widgets/steps/interstitial_fact_step.dart';
import 'package:yucat/features/cat_create/widgets/steps/neutered_status_step.dart';
import 'package:yucat/features/cat_create/widgets/steps/profile_photo_step.dart';
import 'package:yucat/features/cat_create/widgets/steps/water_intake_fact_step.dart';
import 'package:yucat/features/cat_create/widgets/medical_disclaimer_sheet.dart';
import 'package:yucat/presentation/components/wizard_step_shell.dart';
import 'package:yucat/service_locator.dart';
import 'package:yucat/config/themes/theme.dart';

const _totalSteps = 11;

/// Step indices that are non-input "did you know" interstitials.
const _factSteps = {5, 8};

@RoutePage()
class CreateCatPage extends StatefulWidget {
  final CatModel? cat;
  final String? seededName;
  final String? seededPhotoPath;

  const CreateCatPage({
    super.key,
    this.cat,
    this.seededName,
    this.seededPhotoPath,
  });

  @override
  State<CreateCatPage> createState() => _CreateCatPageState();
}

class _CreateCatPageState extends State<CreateCatPage> {
  final _nameController = TextEditingController();
  final _nameFieldKey = GlobalKey<FormFieldState<String>>();
  late final PageController _pageController;

  bool _useDefaultPhoto = false;
  bool _disclaimerShown = false;
  final ImagePicker _imagePicker = ImagePicker();

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

  /// Whether the wizard was launched from onboarding with name (and
  /// optionally photo) already collected. When true the wizard starts at
  /// the gender step and the name/photo steps are not part of the journey.
  bool get _seededFromOnboarding =>
      widget.cat == null &&
      widget.seededName != null &&
      widget.seededName!.isNotEmpty;

  /// First step the user sees. Skip the name + photo steps if those values
  /// were already collected in onboarding.
  int get _initialStep => _seededFromOnboarding ? 2 : 0;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<CatCreateBloc>();
    _pageController = PageController(initialPage: _initialStep);

    // Convert CatModel to CatCreateModel if editing
    CatCreateModel? catCreateModel;
    if (widget.cat != null) {
      final mapper = sl<CatModelToCreateMapper>();
      catCreateModel = mapper(widget.cat!);
      _nameController.text = catCreateModel.name;
    } else if (_seededFromOnboarding) {
      catCreateModel = CatCreateModel(
        name: widget.seededName!,
        profileImageFile: widget.seededPhotoPath != null
            ? File(widget.seededPhotoPath!)
            : null,
      );
      _nameController.text = catCreateModel.name;
    }

    _bloc.add(CatCreateInitialEvent(cat: catCreateModel));
    _bloc.add(CatCreateStepChangedEvent(step: _initialStep));
    // Listen to name field changes to update swipe physics
    _nameController.addListener(_onNameChanged);
  }

  void _onNameChanged() {
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
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _goToNextStep({required int step}) async {
    // Dismiss keyboard when navigating to next step
    FocusScope.of(context).unfocus();

    // Ensure the cat name is provided before leaving step 0
    if (step == 0) {
      final isValid = _nameFieldKey.currentState?.validate() ?? false;
      if (!isValid) {
        return;
      }
    }

    // Surface the medical disclaimer once, right after health conditions.
    if (step == 9 && !_disclaimerShown) {
      _disclaimerShown = true;
      await showMedicalDisclaimerSheet(context);
      if (!mounted) return;
    }

    _bloc.add(CatCreateGoToNextStepEvent(step: step));
  }

  void _goToPreviousStep(int currentStep) {
    if (currentStep > _initialStep) {
      _bloc.add(CatCreateStepChangedEvent(step: currentStep - 1));
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CatCreateBloc, CatCreateState>(
      bloc: _bloc,
      listenWhen: (previous, current) =>
          previous is CatCreateLoadedState &&
          current is CatCreateLoadedState &&
          previous.currentStep != current.currentStep,
      listener: (context, state) {
        if (state is! CatCreateLoadedState) return;
        if (!_pageController.hasClients) return;
        _pageController.animateToPage(
          state.currentStep,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOutCubic,
        );
      },
      builder: (context, state) => _onStateChangeBuilder(state),
    );
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
    final isPhotoStep = currentStep == 1;
    final isHealthStep = currentStep == 9;
    final isBreedStep = currentStep == 10;
    final isFactStep = _factSteps.contains(currentStep);
    final isEditing = widget.cat != null;
    final hasHealthSelection = cat.healthConditions.isNotEmpty;
    final hasPhoto = cat.profileImageFile != null;
    final finalCtaLabel = isEditing ? 'Save changes' : 'Create profile';
    return WizardStepShell(
      currentStep: currentStep - _initialStep,
      totalSteps: _totalSteps - _initialStep,
      background: _seededFromOnboarding
          ? DSColors.tintSky
          : DSColors.tintLavender,
      backgroundGradient: currentStep == 5
          ? const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFA5CAFF), Color(0xFFEFEEF5)],
            )
          : null,
      ctaLabel: isLast
          ? finalCtaLabel
          : isFactStep
              ? 'Got it'
              : 'Next',
      altCtaLabel: isHealthStep
          ? 'None of these'
          : isPhotoStep
              ? 'Skip'
              : null,
      hasSelection: isHealthStep
          ? hasHealthSelection
          : isPhotoStep
              ? hasPhoto
              : true,
      isSubmitting: isSubmitting,
      useCloseIcon: !_seededFromOnboarding && currentStep == _initialStep,
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
          key: const ValueKey('step_2'),
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
          key: const ValueKey('step_3'),
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
        return const WaterIntakeFactStep(key: ValueKey('step_5'));
      case 6:
        return NeuteredStatusStep(
          key: const ValueKey('step_6'),
          status: cat.neuteredStatus,
          gender: cat.gender,
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
      case 7:
        return CoatStep(
          key: const ValueKey('step_7'),
          coatType: cat.coatType,
          onCoatTypeChanged: (value) {
            final currentState = _bloc.state;
            if (currentState is CatCreateLoadedState) {
              final updatedCat = currentState.cat.copyWith(coatType: value);
              _bloc.add(CatCreateUpdateCatEvent(cat: updatedCat));
            }
          },
        );
      case 8:
        return const InterstitialFactStep(
          key: ValueKey('step_8'),
          icon: Icons.brush_rounded,
          accent: DSColors.accentDanger,
          headline: 'Long-haired cats need more omega-3 for a healthy coat',
          highlight: 'more omega-3',
          body:
              'We flag foods with the right balance of fatty acids — and warn when hairball risk is high.',
          citation: '[Veterinary nutrition source]',
        );
      case 9:
        return HealthConditionsStep(
          key: const ValueKey('step_9'),
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
      case 10:
        return BreedStep(
          key: const ValueKey('step_10'),
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
