import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/onboarding/bloc/onboarding_bloc.dart';

@RoutePage()
class OnBoardingPage extends StatefulWidget {
  const OnBoardingPage({super.key});

  @override
  State<OnBoardingPage> createState() => _OnBoardingPage();
}

class _OnBoardingPage extends State<OnBoardingPage> {
  late OnBoardingBloc _bloc;
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  // TODO: Replace with your actual entitlement ID from RevenueCat dashboard
  static const String entitlementID = 'yucat Pro';

  @override
  void initState() {
    print('OnBoardingPage initState');
    super.initState();
    _bloc = context.read<OnBoardingBloc>();
    _bloc.add(OnBoardingInitialEvent(context: context));
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  Future<void> _onGetStarted() async {
    // Show paywall before completing onboarding
    await _showPaywall();

    // After paywall is dismissed, complete onboarding and redirect to home
    if (mounted) {
      _bloc.add(OnBoardingCompletedEvent(context: context));
    }
  }

  Future<void> _showPaywall() async {
    // Only show paywall on iOS
    if (!Platform.isIOS) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();

      if (customerInfo.entitlements.all[entitlementID] != null &&
          customerInfo.entitlements.all[entitlementID]?.isActive == true) {
        // User already has active subscription, no need to show paywall
        if (mounted) {
          debugPrint('User already has active subscription');
        }
      } else {
        Offerings? offerings;
        try {
          offerings = await Purchases.getOfferings();
        } on PlatformException catch (e) {
          if (mounted) {
            await showDialog(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: const Text('Error'),
                content: Text(e.message ?? 'Unknown error'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
        }

        if (offerings == null || offerings.current == null) {
          // Offerings are empty, show a message to your user
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No offerings available at this time'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        } else if (offerings.current!.availablePackages.isEmpty) {
          // Offering exists but has no packages/products configured
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'No subscription packages available. Please configure products in RevenueCat dashboard.',
                ),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 4),
              ),
            );
          }
        } else {
          // Current offering is available with packages, show paywall
          final paywallResult = await RevenueCatUI.presentPaywall();
          debugPrint('Paywall result: $paywallResult');
        }
      }
    } catch (e) {
      debugPrint('Error showing paywall: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
      case OnBoardingReadyState():
        return _buildOnboarding();
    }
  }

  void _onSkip() {
    _bloc.add(OnBoardingSkipEvent(context: context));
  }

  Widget _buildOnboarding() {
    final theme = Theme.of(context);

    final pages = [
      const _OnboardingView(
        image: 'assets/images/boarding1.png',
        title: 'Hey, welcome!',
        subtitle:
            'Scan any cat food barcode to instantly see ingredients and nutrition quality.',
      ),
      const _OnboardingView(
        image: 'assets/images/boarding2.png',
        title: 'Cat product scanner',
        subtitle: "Scan any cat food barcode and see what's inside",
      ),
      const _OnboardingView(
        image: 'assets/images/boarding3.png',
        title: 'Join the Community',
        subtitle:
            "Create your cat's profile to explore trusted product ratings and connect with passionate cat owners.",
      ),
      const _OnboardingView(
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
                    onPageChanged: _onPageChanged,
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
                        if (_currentPage == pages.length - 1)
                          SizedBox(
                            width: double.infinity,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: DSDimens.sizeL,
                              ),
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _onGetStarted,
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
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                    : const Text(
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
            if (_currentPage == pages.length - 1)
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

class _OnboardingView extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;

  const _OnboardingView({
    required this.image,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 342,
              height: 198,
              child: Image.asset(image, fit: BoxFit.contain),
            ),
            const SizedBox(height: 50),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontSize: 29,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: DSDimens.sizeS),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 16,
                color: const Color(0xFF686868),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
