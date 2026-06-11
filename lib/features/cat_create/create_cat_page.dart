import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yucat/features/cat_create/bloc/cat_create_bloc.dart';
import 'package:yucat/features/cat_create/mappers/cat_model_to_create_mapper.dart';
import 'package:yucat/features/cat_create/presentation/models/cat_create_model.dart';
import 'package:yucat/features/cat_create/presentation/models/cat_summary.dart';
import 'package:yucat/features/cat_listing/models/cat_model.dart';
import 'package:yucat/features/cat/domain/entities/cat_entity.dart';
import 'package:yucat/features/cat_create/widgets/steps/activity_step.dart';
import 'package:yucat/features/cat_create/widgets/steps/age_step.dart';
import 'package:yucat/features/cat_create/widgets/steps/body_condition_step.dart';
import 'package:yucat/features/cat_create/widgets/steps/breed_step.dart';
import 'package:yucat/features/cat_create/widgets/steps/cat_name_step.dart';
import 'package:yucat/features/cat_create/widgets/steps/coat_step.dart';
import 'package:yucat/features/cat_create/widgets/steps/gender_step.dart';
import 'package:yucat/features/cat_create/widgets/steps/health_conditions_step.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:yucat/features/cat_create/widgets/steps/coat_fact_step.dart';
import 'package:yucat/features/cat_create/widgets/steps/neutered_status_step.dart';
import 'package:yucat/features/cat_create/widgets/steps/profile_photo_step.dart';
import 'package:yucat/features/cat_create/widgets/steps/water_intake_fact_step.dart';
import 'package:yucat/features/cat_create/widgets/medical_disclaimer_sheet.dart';
import 'package:yucat/presentation/components/wizard_step_shell.dart';
import 'package:yucat/service_locator.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/l10n/app_localizations.dart';

const _totalSteps = 12;

/// Step indices that are non-input "did you know" interstitials.
const _factSteps = {6, 9};

/// The full-bleed hydration interstitial — its glasses band paints edge-to-edge
/// (no shell padding), so it is excluded from the per-step horizontal inset.
const _waterFactStep = 6;

@RoutePage()
class CreateCatPage extends StatefulWidget {
  final CatModel? cat;
  final String? seededName;
  final String? seededPhotoPath;

  /// When set, called on successful creation INSTEAD of popping with the
  /// result. Onboarding uses it to push the success screen *over* the wizard
  /// (a forward slide) rather than have the wizard pop to reveal it.
  final void Function(BuildContext context, CatSummary summary)? onCreated;

  const CreateCatPage({
    super.key,
    this.cat,
    this.seededName,
    this.seededPhotoPath,
    this.onCreated,
  });

  @override
  State<CreateCatPage> createState() => _CreateCatPageState();
}

class _CreateCatPageState extends State<CreateCatPage> {
  final _nameController = TextEditingController();
  final _nameFieldKey = GlobalKey<FormFieldState<String>>();
  late final PageController _pageController;

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

  /// Whether the wizard was launched from onboarding with the name already
  /// collected. When true the wizard starts at the gender step and the name
  /// step is not part of the journey (the photo step still follows gender).
  bool get _seededFromOnboarding =>
      widget.cat == null &&
      widget.seededName != null &&
      widget.seededName!.isNotEmpty;

  /// First step the user sees. Skip the name step if it was already collected
  /// in onboarding; the photo step (after gender) is always part of the flow.
  int get _initialStep => _seededFromOnboarding ? 1 : 0;

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

    _bloc.add(
      CatCreateInitialEvent(cat: catCreateModel, initialStep: _initialStep),
    );
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
    if (step == 10 && !_disclaimerShown) {
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
          (previous.currentStep != current.currentStep ||
              previous.errorTick != current.errorTick),
      listener: (context, state) {
        if (state is! CatCreateLoadedState) return;
        final error = state.transientError;
        if (error != null) {
          final l10n = AppLocalizations.of(context);
          final message = switch (error) {
            CatCreateError.create => l10n.catCreateErrorCreate,
            CatCreateError.save => l10n.catCreateErrorSave,
          };
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(message)));
        }
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
    final isPhotoStep = currentStep == 2;
    final isHealthStep = currentStep == 10;
    final isBreedStep = currentStep == 11;
    final isFactStep = _factSteps.contains(currentStep);
    final isEditing = widget.cat != null;
    final hasHealthSelection = cat.healthConditions.isNotEmpty;
    final hasPhoto = cat.profileImageFile != null;
    final l10n = AppLocalizations.of(context);
    final finalCtaLabel = isEditing
        ? l10n.catCreateCtaSaveChanges
        : l10n.catCreateCtaCreateProfile;
    return WizardStepShell(
      currentStep: currentStep - _initialStep,
      totalSteps: _totalSteps - _initialStep,
      background: DSColors.tintCloud,
      backgroundChild: _buildFactBackdrop(context),
      backgroundGradient:
          currentStep == 6 ? DSGradients.catCreateBackground : null,
      ctaLabel: isLast
          ? finalCtaLabel
          : isFactStep
              ? l10n.commonGotIt
              : l10n.commonNext,
      altCtaLabel: isHealthStep
          ? l10n.catCreateCtaNoneOfThese
          : isPhotoStep
              ? l10n.commonSkip
              : null,
      hasSelection: isHealthStep
          ? hasHealthSelection
          : isPhotoStep
              ? hasPhoto
              : true,
      isSubmitting: isSubmitting,
      useCloseIcon: !_seededFromOnboarding && currentStep == _initialStep,
      showProgress: !isFactStep,
      floatingNext: isHealthStep || isBreedStep,
      onBack: () => _goToPreviousStep(currentStep),
      onNext: isLast ? _handleSubmit : () => _goToNextStep(step: currentStep),
      child: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // The shell no longer pads the content, so each step gets its own
          // horizontal inset — except the water fact step, which paints its
          // glasses band edge-to-edge and insets its own text.
          for (var i = 0; i < _totalSteps; i++)
            if (i == _waterFactStep)
              _buildStepContent(i, cat)
            else
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: DSDimens.sizeL),
                child: _buildStepContent(i, cat),
              ),
        ],
      ),
    );
  }

  Future<void> _handleSubmit() async {
    final currentState = _bloc.state;
    if (currentState is CatCreateLoadedState) {
      _bloc.add(CatCreateCatEvent(
        cat: currentState.cat,
        context: context,
        onCreated: widget.onCreated,
      ));
    }
  }

  /// Full-screen sunburst backdrop for the coat fact step (step 8), driven by
  /// the [PageController] so it slides in/out edge-to-edge in lock-step with
  /// that page — behind the status bar, nav row and CTA — and stays off-screen
  /// (so it never tints the neighbouring steps) the rest of the time.
  Widget _buildFactBackdrop(BuildContext context) {
    const factIndex = 9;
    final width = MediaQuery.sizeOf(context).width;
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, _) {
        var page = _initialStep.toDouble();
        if (_pageController.hasClients &&
            _pageController.position.haveDimensions) {
          page = _pageController.page ?? page;
        }
        final delta = page - factIndex;
        if (delta.abs() >= 1) return const SizedBox.shrink();
        return ClipRect(
          child: Transform.translate(
            offset: Offset(-delta * width, 0),
            child: ColoredBox(
              color: const Color(0xFFFBEAC2),
              child: SvgPicture.asset(
                'assets/images/bg-light.svg',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
        );
      },
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
        return GenderStep(
          key: const ValueKey('step_1'),
          gender: cat.gender,
          onGenderChanged: (value) {
            final currentState = _bloc.state;
            if (currentState is CatCreateLoadedState) {
              final updatedCat = currentState.cat.copyWith(gender: value);
              _bloc.add(CatCreateUpdateCatEvent(cat: updatedCat));
            }
          },
        );
      case 2:
        return ProfilePhotoStep(
          key: const ValueKey('step_2'),
          profilePhoto: cat.profileImageFile,
          imagePicker: _imagePicker,
          onPhotoSelected: (file) {
            final currentState = _bloc.state;
            if (currentState is CatCreateLoadedState) {
              final updatedCat = currentState.cat.copyWith(
                profileImageFile: file,
              );
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
              final updatedCat = currentState.cat.copyWith(
                age: value,
                ageGroup: ageGroupFromMonths(value),
              );
              _bloc.add(CatCreateUpdateCatEvent(cat: updatedCat));
            }
          },
        );
      case 4:
        return BodyConditionStep(
          key: const ValueKey('step_4'),
          weightCategory: cat.weightCategory,
          onWeightCategoryChanged: (value) {
            final currentState = _bloc.state;
            if (currentState is CatCreateLoadedState) {
              final updatedCat = currentState.cat.copyWith(
                weightCategory: value,
              );
              _bloc.add(CatCreateUpdateCatEvent(cat: updatedCat));
            }
          },
        );
      case 5:
        return ActivityStep(
          key: const ValueKey('step_5'),
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
      case 6:
        return const WaterIntakeFactStep(key: ValueKey('step_6'));
      case 7:
        return NeuteredStatusStep(
          key: const ValueKey('step_7'),
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
      case 8:
        return CoatStep(
          key: const ValueKey('step_8'),
          coatType: cat.coatType,
          onCoatTypeChanged: (value) {
            final currentState = _bloc.state;
            if (currentState is CatCreateLoadedState) {
              final updatedCat = currentState.cat.copyWith(coatType: value);
              _bloc.add(CatCreateUpdateCatEvent(cat: updatedCat));
            }
          },
        );
      case 9:
        return const CoatFactStep(key: ValueKey('step_9'));
      case 10:
        return HealthConditionsStep(
          key: const ValueKey('step_10'),
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
      case 11:
        return BreedStep(
          key: const ValueKey('step_11'),
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
