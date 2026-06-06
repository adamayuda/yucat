import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/onboarding/bloc/onboarding_bloc.dart';
import 'package:yucat/features/onboarding/widgets/attribution_details_screen.dart';
import 'package:yucat/features/onboarding/widgets/attribution_screen.dart';
import 'package:yucat/features/onboarding/widgets/health_intro_screen.dart';
import 'package:yucat/features/onboarding/widgets/notif_primer_screen.dart';
import 'package:yucat/features/onboarding/widgets/nutrition_fact_screen.dart';
import 'package:yucat/features/onboarding/widgets/profile_intro_screen.dart';
import 'package:yucat/features/onboarding/widgets/profile_name_screen.dart';
import 'package:yucat/features/onboarding/widgets/profile_photo_screen.dart';
import 'package:yucat/features/onboarding/widgets/proof_chart_screen.dart';
import 'package:yucat/features/onboarding/widgets/rating_screen.dart';
import 'package:yucat/features/onboarding/widgets/reminders_screen.dart';
import 'package:yucat/features/onboarding/widgets/scan_demo_screen.dart';
import 'package:yucat/features/onboarding/widgets/success_screen.dart';
import 'package:yucat/features/onboarding/widgets/welcome_screen.dart';
import 'package:yucat/features/onboarding/widgets/why_yucat_screen.dart';
import 'package:yucat/presentation/components/onboarding_scaffold.dart';

@RoutePage()
class OnBoardingPage extends StatefulWidget {
  const OnBoardingPage({super.key});

  @override
  State<OnBoardingPage> createState() => _OnBoardingPage();
}

class _OnBoardingPage extends State<OnBoardingPage> {
  late OnBoardingBloc _bloc;
  late final PageController _pageController;
  bool _assetsWarmed = false;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<OnBoardingBloc>();
    _pageController = PageController();
    _bloc.add(OnBoardingInitialEvent(context: context));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_assetsWarmed) return;
    _assetsWarmed = true;

    // Warm the flutter_svg compile cache so the proof-chart graph doesn't
    // compile on the frame the page slides in (which caused visible jank).
    const loader = SvgAssetLoader('assets/images/onboarding-graph.svg');
    svg.cache.putIfAbsent(loader.cacheKey(null), () => loader.loadBytes(null));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
    _bloc.close();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OnBoardingBloc, OnBoardingState>(
      bloc: _bloc,
      buildWhen: (previous, current) =>
          current is OnBoardingReadyState && previous != current,
      listenWhen: (previous, current) =>
          current is OnBoardingReadyState && previous != current,
      listener: (context, state) {
        if (state is! OnBoardingReadyState) return;
        if (!_pageController.hasClients) return;
        final targetIndex = OnBoardingPhase.values.indexOf(state.phase);
        _pageController.animateToPage(
          targetIndex,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOutCubic,
        );
      },
      builder: (context, state) {
        if (state is! OnBoardingReadyState) {
          return const SizedBox.shrink();
        }
        final showBack = state.phase != OnBoardingPhase.welcome &&
            state.phase != OnBoardingPhase.success;
        return Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: OnBoardingPhase.values.length,
              itemBuilder: (context, index) => _buildPhase(
                OnBoardingPhase.values[index],
                state.selectedSource,
                state.seededName,
                state.seededPhotoPath,
                state.catSummary,
              ),
            ),
            if (showBack)
              Positioned(
                top: 0,
                left: DSDimens.sizeL,
                child: SafeArea(
                  child: SizedBox(
                    height: 48,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: BackChip(
                        onTap: () => _bloc
                            .add(const OnBoardingPreviousPhaseEvent()),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildPhase(
    OnBoardingPhase phase,
    String? selectedSource,
    String? seededName,
    String? seededPhotoPath,
    List<String> catSummary,
  ) {
    switch (phase) {
      case OnBoardingPhase.welcome:
        return WelcomeScreen(
          onGetStarted: () => _bloc.add(const OnBoardingGetStartedEvent()),
          onRestorePurchases: () =>
              _bloc.add(const OnBoardingRestorePurchasesEvent()),
        );
      case OnBoardingPhase.scanDemo:
        return ScanDemoScreen(
          onNext: () => _bloc.add(const OnBoardingAdvancePhaseEvent()),
        );
      case OnBoardingPhase.attribution:
        return AttributionScreen(
          initialSelection: selectedSource,
          onSelect: (source) =>
              _bloc.add(OnBoardingAttributionSelectedEvent(source)),
          onSkip: () => _bloc.add(const OnBoardingAttributionSkippedEvent()),
        );
      case OnBoardingPhase.attributionDetails:
        return AttributionDetailsScreen(
          onSubmit: (text) =>
              _bloc.add(OnBoardingAttributionDetailsSubmittedEvent(text)),
        );
      case OnBoardingPhase.proofChart:
        return ProofChartScreen(
          onNext: () => _bloc.add(const OnBoardingAdvancePhaseEvent()),
        );
      case OnBoardingPhase.whyYucat:
        return WhyYucatScreen(
          onNext: () => _bloc.add(const OnBoardingAdvancePhaseEvent()),
        );
      case OnBoardingPhase.nutritionFact:
        return NutritionFactScreen(
          onNext: () => _bloc.add(const OnBoardingAdvancePhaseEvent()),
        );
      case OnBoardingPhase.profileIntro:
        return ProfileIntroScreen(
          onNext: () => _bloc.add(const OnBoardingAdvancePhaseEvent()),
        );
      case OnBoardingPhase.profilePhoto:
        return ProfilePhotoScreen(
          photoPath: seededPhotoPath,
          onPhotoSelected: (path) =>
              _bloc.add(OnBoardingPhotoSeededEvent(path)),
          onNext: () => _bloc.add(const OnBoardingAdvancePhaseEvent()),
          onSkip: () => _bloc.add(const OnBoardingAdvancePhaseEvent()),
        );
      case OnBoardingPhase.profileName:
        return ProfileNameScreen(
          initialName: seededName,
          onNext: (name) {
            _bloc.add(OnBoardingNameSeededEvent(name));
            _bloc.add(const OnBoardingAdvancePhaseEvent());
          },
        );
      case OnBoardingPhase.rating:
        return RatingScreen(
          onNext: () => _bloc.add(const OnBoardingAdvancePhaseEvent()),
        );
      case OnBoardingPhase.notifPrimer:
        return NotifPrimerScreen(
          onNext: () => _bloc.add(const OnBoardingAdvancePhaseEvent()),
        );
      case OnBoardingPhase.reminders:
        return RemindersScreen(
          onNext: () => _bloc.add(const OnBoardingAdvancePhaseEvent()),
        );
      case OnBoardingPhase.healthIntro:
        return HealthIntroScreen(
          onAddCat: () =>
              _bloc.add(OnBoardingCompletedEvent(context: context)),
        );
      case OnBoardingPhase.success:
        return SuccessScreen(
          summary: catSummary,
          onStart: () =>
              _bloc.add(OnBoardingFinalizedEvent(context: context)),
        );
    }
  }
}
