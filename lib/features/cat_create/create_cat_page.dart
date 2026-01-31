import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/auth/domain/usecase/current_user_usecase.dart';
import 'package:yucat/features/cat_create/bloc/cat_create_bloc.dart';
import 'package:yucat/features/cat_create/presentation/models/cat_create_model.dart';
import 'package:yucat/features/cat_create/widgets/activity_step.dart';
import 'package:yucat/features/cat_create/widgets/age_step.dart';
import 'package:yucat/features/cat_create/widgets/breed_step.dart';
import 'package:yucat/features/cat_create/widgets/cat_name_step.dart';
import 'package:yucat/features/cat_create/widgets/coat_step.dart';
import 'package:yucat/features/cat_create/widgets/gender_step.dart';
import 'package:yucat/features/cat_create/widgets/health_conditions_step.dart';
import 'package:yucat/features/cat_create/widgets/neutered_status_step.dart';
import 'package:yucat/features/cat_create/widgets/profile_photo_step.dart';
import 'package:yucat/services/cat_tracking_service.dart';
import 'package:yucat/service_locator.dart';

class ConditionalScrollPhysics extends ScrollPhysics {
  final bool canScrollForward;
  final int currentPage;

  const ConditionalScrollPhysics({
    required this.canScrollForward,
    required this.currentPage,
    super.parent,
  });

  @override
  ConditionalScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return ConditionalScrollPhysics(
      canScrollForward: canScrollForward,
      currentPage: currentPage,
      parent: buildParent(ancestor),
    );
  }

  @override
  bool shouldAcceptUserOffset(ScrollMetrics position) {
    // Only prevent user gestures (swipes), not programmatic navigation
    if (!canScrollForward && currentPage == 0) {
      return false;
    }
    return super.shouldAcceptUserOffset(position);
  }
}

@RoutePage()
class CreateCatPage extends StatefulWidget {
  const CreateCatPage({super.key});

  @override
  State<CreateCatPage> createState() => _CreateCatPageState();
}

class _CreateCatPageState extends State<CreateCatPage> {
  final _nameController = TextEditingController();
  final _nameFieldKey = GlobalKey<FormFieldState<String>>();

  bool _neutered = false;
  String? _neuteredStatus;
  String? _breed = 'Other';
  String? _ageGroup;
  int _years = 0;
  int _months = 0;
  String? _gender;
  String? _weightCategory;
  String? _activityLevel;
  String? _coatType;
  List<String> _healthConditions = [];
  File? _profilePhoto;
  bool _useDefaultPhoto = false;
  bool _isLoading = false;
  int _currentStep = 0;
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
  late CatTrackingService _catTrackingService;
  late CurrentUserUsecase _currentUserUsecase;
  static const String _entitlementID = 'yucat Pro';

  @override
  void initState() {
    super.initState();
    _bloc = context.read<CatCreateBloc>();
    _catTrackingService = sl<CatTrackingService>();
    _currentUserUsecase = sl<CurrentUserUsecase>();
    // Listen to name field changes to update swipe physics
    _nameController.addListener(_onNameChanged);
  }

  void _onNameChanged() {
    // Rebuild to update PageView physics when name changes
    setState(() {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentStep = page;
    });
  }

  bool _canSwipeForward() {
    // Can't swipe forward from step 0 if name is empty
    if (_currentStep == 0) {
      return _nameController.text.trim().isNotEmpty;
    }
    return true;
  }

  void _goToNextStep() {
    switch (_currentStep) {
      case 0:
        if (!(_nameFieldKey.currentState?.validate() ?? false)) return;
        break;
    }

    if (_currentStep < 8) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToPreviousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // If on first step, exit the page
      Navigator.of(context).pop();
    }
  }

  Future<void> _handleSubmit() async {
    // The name field is already validated on step 0 via `_goToNextStep`.
    // At this point the field widget may not be mounted anymore, so we
    // cannot rely on `_nameFieldKey.currentState`. Just make sure the
    // controller still has a non-empty value.
    if (_nameController.text.trim().isEmpty) {
      _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      return;
    }

    // Check if user can create a cat
    final user = _currentUserUsecase();
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be signed in to create a cat.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // final canCreateCat = await _catTrackingService.canCreateCat(
    //   userId: user.uid,
    // );
    // if (!canCreateCat) {
    //   // User has reached free cat limit, show paywall
    //   await _showPaywall();

    //   // After paywall is dismissed, check again if user can create (in case they subscribed)
    //   final canCreateAfterPaywall = await _catTrackingService.canCreateCat(
    //     userId: user.uid,
    //   );
    //   if (!canCreateAfterPaywall) {
    //     // User still can't create, don't proceed
    //     return;
    //   }
    // }

    setState(() => _isLoading = true);

    _bloc.add(
      CatCreateCatEvent(
        cat: CatCreateModel(
          name: _nameController.text.trim(),
          age: null,
          ageGroup: _ageGroup,
          weight: null,
          neutered: _neutered,
          profileImageFile: _profilePhoto,
          neuteredStatus: _neuteredStatus,
          breed: _breed,
          gender: _gender,
          weightCategory: _weightCategory,
          activityLevel: _activityLevel,
          coatType: _coatType,
          healthConditions: _healthConditions,
        ),
      ),
    );
  }

  // Future<void> _showPaywall() async {
  //   setState(() {
  //     _isLoading = true;
  //   });

  //   try {
  //     CustomerInfo customerInfo = await Purchases.getCustomerInfo();

  //     if (customerInfo.entitlements.all[_entitlementID] != null &&
  //         customerInfo.entitlements.all[_entitlementID]?.isActive == true) {
  //       // User already has active subscription
  //       if (mounted) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(
  //             content: Text('You already have an active subscription'),
  //             duration: Duration(seconds: 2),
  //           ),
  //         );
  //       }
  //     } else {
  //       Offerings? offerings;
  //       try {
  //         offerings = await Purchases.getOfferings();
  //       } on PlatformException catch (e) {
  //         if (mounted) {
  //           await showDialog(
  //             context: context,
  //             builder: (BuildContext context) => AlertDialog(
  //               title: const Text('Error'),
  //               content: Text(e.message ?? 'Unknown error'),
  //               actions: [
  //                 TextButton(
  //                   onPressed: () => Navigator.of(context).pop(),
  //                   child: const Text('OK'),
  //                 ),
  //               ],
  //             ),
  //           );
  //         }
  //       }

  //       if (offerings == null || offerings.current == null) {
  //         // Offerings are empty, show a message to your user
  //         if (mounted) {
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             const SnackBar(
  //               content: Text('No offerings available at this time'),
  //               duration: Duration(seconds: 2),
  //             ),
  //           );
  //         }
  //       } else if (offerings.current!.availablePackages.isEmpty) {
  //         // Offering exists but has no packages/products configured
  //         if (mounted) {
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             const SnackBar(
  //               content: Text(
  //                 'No subscription packages available. Please configure products in RevenueCat dashboard.',
  //               ),
  //               backgroundColor: Colors.orange,
  //               duration: Duration(seconds: 4),
  //             ),
  //           );
  //         }
  //       } else {
  //         // Current offering is available with packages, show paywall
  //         final paywallResult = await RevenueCatUI.presentPaywall();
  //         debugPrint('Paywall result: $paywallResult');
  //       }
  //     }
  //   } catch (e) {
  //     debugPrint('Error showing paywall: $e');
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Error: ${e.toString()}'),
  //           backgroundColor: Colors.red,
  //           duration: const Duration(seconds: 3),
  //         ),
  //       );
  //     }
  //   } finally {
  //     if (mounted) {
  //       setState(() {
  //         _isLoading = false;
  //       });
  //     }
  //   }
  // }

  Widget _buildStepWrapper(int stepIndex) {
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
            _buildStepContent(stepIndex),
            SizedBox(height: DSDimens.sizeXl),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent(int stepIndex) {
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
          profilePhoto: _profilePhoto,
          useDefaultPhoto: _useDefaultPhoto,
          imagePicker: _imagePicker,
          onPhotoSelected: (file) {
            setState(() {
              _profilePhoto = file;
              _useDefaultPhoto = false;
            });
          },
          onUseDefault: () {
            setState(() {
              _useDefaultPhoto = true;
              _profilePhoto = null;
            });
          },
          onRemovePhoto: () {
            setState(() {
              _profilePhoto = null;
              _useDefaultPhoto = false;
            });
          },
        );
      case 2:
        return GenderStep(
          key: const ValueKey('step_3'),
          gender: _gender,
          onGenderChanged: (value) {
            setState(() {
              _gender = value;
            });
          },
        );
      case 3:
        return AgeStep(
          key: const ValueKey('step_2'),
          ageGroup: _ageGroup,
          onAgeGroupChanged: (value) {
            setState(() {
              _ageGroup = value;
            });
          },
          years: _years,
          months: _months,
          onYearsChanged: (value) {
            setState(() {
              _years = value;
            });
          },
          onMonthsChanged: (value) {
            setState(() {
              _months = value;
            });
          },
        );
      case 4:
        return ActivityStep(
          key: const ValueKey('step_4'),
          activityLevel: _activityLevel,
          onActivityLevelChanged: (value) {
            setState(() {
              _activityLevel = value;
            });
          },
        );
      case 5:
        return NeuteredStatusStep(
          key: const ValueKey('step_5'),
          status: _neuteredStatus,
          onStatusChanged: (value) {
            setState(() {
              _neuteredStatus = value;
              _neutered = value == 'neutered';
            });
          },
        );
      case 6:
        return CoatStep(
          key: const ValueKey('step_6'),
          coatType: _coatType,
          onCoatTypeChanged: (value) {
            setState(() {
              _coatType = value;
            });
          },
        );
      case 7:
        return HealthConditionsStep(
          key: const ValueKey('step_7'),
          selectedHealthConditions: _healthConditions,
          onHealthConditionsChanged: (value) {
            setState(() {
              _healthConditions = value;
            });
          },
        );
      case 8:
        return BreedStep(
          key: const ValueKey('step_8'),
          selectedBreed: _breed,
          breeds: _breeds,
          onBreedSelected: (breed) {
            setState(() {
              _breed = breed;
            });
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStepperBar() {
    const totalSteps = 9;
    final currentStepNumber = _currentStep + 1;
    final progress = currentStepNumber / totalSteps;

    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 0, 40, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              TextButton.icon(
                onPressed: _goToPreviousStep,
                icon: Icon(
                  Icons.chevron_left,
                  size: 24,
                  color: const Color(0xFF686868),
                ),
                label: Text(
                  'Back',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF686868),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 12,
            width: double.infinity,
            child: Stack(
              children: [
                // Background (uncompleted portion)
                Container(
                  width: double.infinity,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFFF5E8FF,
                    ), // Light lavender/pale purple
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                // Progress (completed portion)
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: Color(0xFFFF5FC9), // Pink/vibrant color
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Step $currentStepNumber of $totalSteps',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF686868),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CatCreateBloc, CatCreateState>(
      bloc: _bloc,
      listener: (context, state) {
        if (state is CatCreateErrorState) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is CatCreateLoadedState && _isLoading) {
          // Cat was successfully created, navigate back
          setState(() => _isLoading = false);
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
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
                child: _buildStepperBar(),
              ),
            ),
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : LayoutBuilder(
                builder: (context, constraints) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 62),
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: _onPageChanged,
                      physics: ConditionalScrollPhysics(
                        canScrollForward: _canSwipeForward(),
                        currentPage: _currentStep,
                        parent: const BouncingScrollPhysics(),
                      ),
                      children: [
                        _buildStepWrapper(0),
                        _buildStepWrapper(1),
                        _buildStepWrapper(2),
                        _buildStepWrapper(3),
                        _buildStepWrapper(4),
                        _buildStepWrapper(5),
                        _buildStepWrapper(6),
                        _buildStepWrapper(7),
                        _buildStepWrapper(8),
                      ],
                    ),
                  );
                },
              ),
        bottomNavigationBar: _isLoading
            ? null
            : Padding(
                padding: EdgeInsets.only(
                  left: 40,
                  right: 40,
                  // top: DSDimens.sizeS,
                  bottom: 50,
                ),
                child: _currentStep == 1
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _goToNextStep,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFF3F4F6),
                                    foregroundColor: DSColors.white,
                                    disabledBackgroundColor: const Color(
                                      0xFFEDAFDD,
                                    ),
                                    disabledForegroundColor: DSColors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: DSDimens.sizeS,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        DSDimens.sizeXxs,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    'Skip for now',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: const Color(0xFF475567),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: DSDimens.sizeS),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _isLoading
                                      ? null
                                      : _profilePhoto == null
                                      ? null
                                      : _goToNextStep,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: DSColors.primary,
                                    foregroundColor: DSColors.white,
                                    disabledBackgroundColor: const Color(
                                      0xFFEDAFDD,
                                    ),
                                    disabledForegroundColor: DSColors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: DSDimens.sizeS,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        DSDimens.sizeXxs,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    'Next',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isLoading
                                  ? null
                                  : _currentStep == 0 &&
                                        _nameController.text.trim().isEmpty
                                  ? null
                                  : _currentStep == 8
                                  ? () => _handleSubmit()
                                  : _goToNextStep,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: DSColors.primary,
                                foregroundColor: DSColors.white,
                                disabledBackgroundColor: const Color(
                                  0xFFEDAFDD,
                                ),
                                disabledForegroundColor: DSColors.white,
                                // padding: EdgeInsets.symmetric(
                                //   vertical: DSDimens.sizeM,
                                // ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: DSDimens.sizeS,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    DSDimens.sizeXxs,
                                  ),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              DSColors.white,
                                            ),
                                      ),
                                    )
                                  : Text(
                                      _currentStep == 8
                                          ? 'Create Profile'
                                          : 'Next',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
              ),
      ),
    );
  }
}
