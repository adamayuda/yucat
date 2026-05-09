import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/onboarding/bloc/onboarding_bloc.dart';
import 'package:yucat/features/onboarding/widgets/add_cat_intro_screen.dart';
import 'package:yucat/features/onboarding/widgets/attribution_details_screen.dart';
import 'package:yucat/features/onboarding/widgets/attribution_screen.dart';
import 'package:yucat/features/onboarding/widgets/domain_pitch_screen.dart';
import 'package:yucat/features/onboarding/widgets/social_proof_screen.dart';
import 'package:yucat/features/onboarding/widgets/success_screen.dart';
import 'package:yucat/features/onboarding/widgets/value_prop_slide.dart';
import 'package:yucat/features/onboarding/widgets/welcome_screen.dart';
import 'package:yucat/features/onboarding/widgets/why_yucat_screen.dart';
import 'package:yucat/presentation/components/ds_dot_indicator.dart';
import 'package:yucat/presentation/components/ds_pill_button.dart';
import 'package:yucat/presentation/components/onboarding_scaffold.dart';

@RoutePage()
class OnBoardingPage extends StatefulWidget {
  const OnBoardingPage({super.key});

  @override
  State<OnBoardingPage> createState() => _OnBoardingPage();
}

class _OnBoardingPage extends State<OnBoardingPage> {
  late OnBoardingBloc _bloc;
  final PageController _pageController = PageController();

  static const _carouselNames = [
    'cat_product_scanner',
    'personalized_for_your_cat',
    'browse_catalog',
  ];

  @override
  void initState() {
    super.initState();
    _bloc = context.read<OnBoardingBloc>();
    _bloc.add(OnBoardingInitialEvent(context: context));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
    _bloc.close();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnBoardingBloc, OnBoardingState>(
      bloc: _bloc,
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) => switch (state) {
        OnBoardingLoadingState() => const SizedBox.shrink(),
        OnBoardingReadyState(
          :final phase,
          :final currentPage,
          :final selectedSource,
        ) =>
          _buildPhase(phase, currentPage, selectedSource),
      },
    );
  }

  Widget _buildPhase(
    OnBoardingPhase phase,
    int currentPage,
    String? selectedSource,
  ) {
    switch (phase) {
      case OnBoardingPhase.welcome:
        return WelcomeScreen(
          onGetStarted: () => _bloc.add(const OnBoardingGetStartedEvent()),
          onRestorePurchases: () =>
              _bloc.add(const OnBoardingRestorePurchasesEvent()),
        );
      case OnBoardingPhase.valueCarousel:
        return _buildCarousel(currentPage);
      case OnBoardingPhase.attribution:
        return AttributionScreen(
          initialSelection: selectedSource,
          onSelect: (source) =>
              _bloc.add(OnBoardingAttributionSelectedEvent(source)),
          onSkip: () => _bloc.add(const OnBoardingAttributionSkippedEvent()),
          onBack: () => _bloc.add(const OnBoardingPreviousPhaseEvent()),
        );
      case OnBoardingPhase.attributionDetails:
        return AttributionDetailsScreen(
          onSubmit: (text) =>
              _bloc.add(OnBoardingAttributionDetailsSubmittedEvent(text)),
          onBack: () => _bloc.add(const OnBoardingPreviousPhaseEvent()),
        );
      case OnBoardingPhase.socialProof:
        return SocialProofScreen(
          onNext: () => _bloc.add(const OnBoardingAdvancePhaseEvent()),
          onBack: () => _bloc.add(const OnBoardingPreviousPhaseEvent()),
        );
      case OnBoardingPhase.whyYucat:
        return WhyYucatScreen(
          onNext: () => _bloc.add(const OnBoardingAdvancePhaseEvent()),
          onBack: () => _bloc.add(const OnBoardingPreviousPhaseEvent()),
        );
      case OnBoardingPhase.domainPitch:
        return DomainPitchScreen(
          onNext: () => _bloc.add(const OnBoardingAdvancePhaseEvent()),
          onBack: () => _bloc.add(const OnBoardingPreviousPhaseEvent()),
        );
      case OnBoardingPhase.addCatIntro:
        return AddCatIntroScreen(
          onAddCat: () =>
              _bloc.add(OnBoardingCompletedEvent(context: context)),
          onBack: () => _bloc.add(const OnBoardingPreviousPhaseEvent()),
        );
      case OnBoardingPhase.success:
        return SuccessScreen(
          onStart: () =>
              _bloc.add(OnBoardingFinalizedEvent(context: context)),
        );
    }
  }

  Widget _buildCarousel(int currentPage) {
    final isLast = currentPage == _carouselNames.length - 1;

    final slides = [
      const ValuePropSlide(
        image: 'assets/images/Illustrations/Scanning barcode_1.gif',
        title: 'Scan any cat food',
        subtitle: 'Point your camera at any barcode and see what\'s inside.',
        tint: DSColors.tintAsh,
      ),
      const ValuePropSlide(
        image: 'assets/images/Illustrations/Join the Community.gif',
        title: 'Personalized\nto your cat',
        subtitle:
            'Assessment matches your cat\'s age, weight, breed, and health.',
        tint: DSColors.tintMint,
      ),
      const ValuePropSlide(
        image: 'assets/images/Illustrations/Add new cat.gif',
        title: 'Or browse\nthe catalog',
        subtitle: 'Search thousands of products by brand or name.',
        tint: DSColors.tintSand,
      ),
    ];

    final activeTint = [
      DSColors.tintAsh,
      DSColors.tintMint,
      DSColors.tintSand,
    ][currentPage];

    return AnimatedContainer(
      duration: DSMotion.durMed,
      curve: DSMotion.curveStandard,
      color: activeTint,
      child: OnboardingScaffold(
        background: activeTint,
        onBack: currentPage == 0
            ? () => _bloc.add(const OnBoardingBackToWelcomeEvent())
            : () => _pageController.previousPage(
                  duration: DSMotion.durMed,
                  curve: DSMotion.curveStandard,
                ),
        footer: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DSDotIndicator(
              controller: _pageController,
              count: slides.length,
            ),
            const SizedBox(height: DSDimens.sizeL),
            DSPillButton(
              label: isLast ? 'Continue' : 'Next',
              onPressed: () {
                if (isLast) {
                  _bloc.add(const OnBoardingValueCarouselCompletedEvent());
                } else {
                  _pageController.nextPage(
                    duration: DSMotion.durMed,
                    curve: DSMotion.curveStandard,
                  );
                }
              },
            ),
          ],
        ),
        child: PageView(
          controller: _pageController,
          onPageChanged: (page) => _bloc.add(
            OnBoardingPageChangedEvent(page, _carouselNames[page]),
          ),
          children: slides,
        ),
      ),
    );
  }
}
