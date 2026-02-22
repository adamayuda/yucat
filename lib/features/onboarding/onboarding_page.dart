import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/onboarding/bloc/onboarding_bloc.dart';
import 'package:yucat/features/onboarding/widgets/onboarding_content.dart';

@RoutePage()
class OnBoardingPage extends StatefulWidget {
  const OnBoardingPage({super.key});

  @override
  State<OnBoardingPage> createState() => _OnBoardingPage();
}

class _OnBoardingPage extends State<OnBoardingPage> {
  late OnBoardingBloc _bloc;

  final PageController _pageController = PageController();

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
      builder: (context, state) => _onStateChangeBuilder(state),
    );
  }

  Widget _onStateChangeBuilder(OnBoardingState state) {
    switch (state) {
      case OnBoardingLoadingState():
        return const SizedBox.shrink();
      case OnBoardingReadyState(:final currentPage):
        return _buildOnboarding(currentPage);
    }
  }

  Future<void> _onGetStarted() async {
    _bloc.add(OnBoardingCompletedEvent(context: context));
  }

  void _onSkip() {
    _bloc.add(OnBoardingSkipEvent(context: context));
  }

  void _onPageChanged(int page) {
    const pageNames = [
      'welcome',
      'cat_product_scanner',
      'join_community',
      'add_new_cat',
    ];
    final pageName = page < pageNames.length
        ? pageNames[page]
        : 'onboarding_$page';
    _bloc.add(OnBoardingPageChangedEvent(page, pageName));
  }

  Widget _buildOnboarding(int currentPage) {
    final theme = Theme.of(context);

    final pages = [
      const OnboardingContent(
        image: 'assets/images/boarding1.png',
        title: 'Hey, welcome!',
        subtitle:
            'Scan any cat food barcode to instantly see ingredients and nutrition quality.',
      ),
      const OnboardingContent(
        image: 'assets/images/boarding2.png',
        title: 'Cat product scanner',
        subtitle: "Scan any cat food barcode and see what's inside",
      ),
      const OnboardingContent(
        image: 'assets/images/boarding3.png',
        title: 'Join the Community',
        subtitle:
            "Create your cat's profile to explore trusted product ratings and connect with passionate cat owners.",
      ),
      const OnboardingContent(
        image: 'assets/images/boarding4.png',
        title: 'Add New Cat',
        subtitle: "Let's create your profile. This will ony take a minute!",
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (page) => _onPageChanged(page),
                    children: pages,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: DSDimens.sizeL),
                  child: SizedBox(
                    height: 60,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (currentPage == pages.length - 1)
                          SizedBox(
                            width: double.infinity,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: DSDimens.sizeL,
                              ),
                              child: ElevatedButton(
                                onPressed: _onGetStarted,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: DSColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: DSDimens.sizeS,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      DSDimens.sizeXxs,
                                    ),
                                  ),
                                ),
                                child: const Text(
                                  'Start',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          )
                        else
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SmoothPageIndicator(
                                controller: _pageController,
                                count: pages.length,
                                effect: const WormEffect(
                                  dotColor: Color(0xFFF9E9F5),
                                  activeDotColor: DSColors.primary,
                                  dotHeight: 14,
                                  dotWidth: 14,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (currentPage == pages.length - 1)
              Positioned(
                top: DSDimens.sizeS,
                right: DSDimens.sizeL,
                child: TextButton(
                  onPressed: _onSkip,
                  child: Text(
                    'Skip',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 16,
                      color: const Color(0xFF686868),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
