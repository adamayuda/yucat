import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:yucat/config/routes/router.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/home/bloc/home_bloc.dart';
import 'package:yucat/features/home/bloc/home_event.dart';
import 'package:yucat/features/home/bloc/home_state.dart';
import 'package:yucat/features/product_detail/presentation/models/product_model.dart';
import 'package:yucat/services/scan_tracking_service.dart';
import 'package:yucat/service_locator.dart';

@RoutePage()
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  late HomeBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<HomeBloc>();
    _bloc.add(HomeInitialEvent());
  }

  @override
  void dispose() {
    super.dispose();
    _bloc.close();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeBloc, HomeState>(
      bloc: _bloc,
      listenWhen: (previous, current) =>
          current is HomeNavigateToProductDetailState,
      listener: (context, state) {
        if (state is HomeNavigateToProductDetailState) {
          context.router.push(ProductDetailRoute(product: state.product)).then((
            _,
          ) {
            // Reset to loaded state when user returns from product detail
            _bloc.add(HomeInitialEvent());
          });
        }
      },
      child: BlocBuilder<HomeBloc, HomeState>(
        bloc: _bloc,
        buildWhen: (previous, current) =>
            previous != current && current is! HomeNavigateToProductDetailState,
        builder: (context, state) => _onStateChangeBuilder(state),
      ),
    );
  }

  Widget _onStateChangeBuilder(HomeState state) {
    switch (state) {
      case HomeLoadingState():
        return Scaffold(
          // appBar: PreferredSize(
          //   preferredSize: Size.fromHeight(kToolbarHeight),
          //   child: TopAppBar(
          //     title: state.user.welcomeMessage,
          //     hideBackButton: true,
          //   ),
          // ),
          body: Center(child: Text('Loading')),
        );
      case HomeLoadedState():
        return _HomeLoadedState(
          onTap: (countryCode) => _dispatch(
            CountryTapEvent(countryCode: countryCode, context: context),
          ),
          onBarcodeScanned: (barcode) {
            _dispatch(SearchByBarcodeEvent(barcode: barcode));
          },
        );
      case HomeSearchResultsState():
        return _HomeLoadedState(
          onTap: (countryCode) => _dispatch(
            CountryTapEvent(countryCode: countryCode, context: context),
          ),
          onBarcodeScanned: (barcode) {
            _dispatch(SearchByBarcodeEvent(barcode: barcode));
          },
          searchResults: state.products,
        );
      case HomeErrorState():
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${state.message}'),
                ElevatedButton(
                  onPressed: () => _dispatch(HomeInitialEvent()),
                  child: Text('Retry'),
                ),
              ],
            ),
          ),
        );
      default:
        return const Text('Default');
    }
  }

  void _dispatch(HomeEvent event) => _bloc.add(event);
}

class _HomeLoadedState extends StatefulWidget {
  final void Function(String) onTap;
  final void Function(String)? onBarcodeScanned;
  final List<ProductModel>? searchResults;

  const _HomeLoadedState({
    required this.onTap,
    this.onBarcodeScanned,
    this.searchResults,
  });

  @override
  State<_HomeLoadedState> createState() => __HomeLoadedState();
}

class __HomeLoadedState extends State<_HomeLoadedState> {
  // Create controller with autoStart enabled - the MobileScanner widget will handle initialization
  final MobileScannerController _scannerController = MobileScannerController();
  bool _hasScanned = false;
  bool _isRestarting = false;
  bool _isLoading = false;
  late final ScanTrackingService _scanTrackingService;

  // TODO: Replace with your actual entitlement ID from RevenueCat dashboard
  static const String entitlementID = 'yucat Pro';

  @override
  void initState() {
    super.initState();
    _scanTrackingService = sl<ScanTrackingService>();
  }

  Future<void> _restartScanner() async {
    if (_isRestarting) return;
    if (!mounted) return;

    _isRestarting = true;
    try {
      await _scannerController.stop();
      // Wait for controller to fully stop before restarting
      await Future.delayed(const Duration(milliseconds: 500));

      // Start the scanner again
      if (mounted) {
        await _scannerController.start();
      }
    } catch (e) {
      debugPrint('Error restarting scanner: $e');
      // If restart fails, try to start anyway after a delay
      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 1000));
        try {
          await _scannerController.start();
        } catch (e2) {
          debugPrint('Error starting scanner after failed restart: $e2');
        }
      }
    } finally {
      if (mounted) {
        _isRestarting = false;
      }
    }
  }

  @override
  void didUpdateWidget(_HomeLoadedState oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Handle search results when they change (new scan completed)
    if (oldWidget.searchResults != widget.searchResults) {
      if (widget.searchResults != null) {
        if (widget.searchResults!.isNotEmpty) {
          // Product found - navigate to detail page
          final product = widget.searchResults!.first;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.router.push(ProductDetailRoute(product: product));
          });
        } else {
          // No product found - show error
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Product not found'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 3),
              ),
            );
          });
        }
        // Reset scanner for next scan
        _hasScanned = false;
        _restartScanner();
      }
    }
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _showPaywall() async {
    setState(() {
      _isLoading = true;
    });

    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();

      if (customerInfo.entitlements.all[entitlementID] != null &&
          customerInfo.entitlements.all[entitlementID]?.isActive == true) {
        // User already has active subscription
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You already have an active subscription'),
              duration: Duration(seconds: 2),
            ),
          );
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

          // After paywall is dismissed, check if user purchased subscription
          // and reset free scan count if they did
          if (mounted) {
            final updatedCustomerInfo = await Purchases.getCustomerInfo();
            final hasActiveSubscription =
                updatedCustomerInfo.entitlements.all[entitlementID]?.isActive ==
                true;
            if (hasActiveSubscription) {
              await _scanTrackingService.resetFreeScansCount();
            }
          }
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DSColors.lightGrey,
      body: Stack(
        children: [
          // camera
          MobileScanner(
            controller: _scannerController,
            onDetect: (capture) async {
              if (_hasScanned) return; // Prevent multiple scans

              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  debugPrint('Scanned barcode: ${barcode.rawValue}');
                  _hasScanned = true;
                  // Stop scanning to prevent multiple calls
                  _scannerController.stop();

                  // Check if user can perform scan
                  final canScan = await _scanTrackingService.canPerformScan();

                  if (!canScan) {
                    // User has reached free scan limit, show paywall
                    if (mounted) {
                      await _showPaywall();
                      // Reset scanner after paywall is shown
                      _hasScanned = false;
                      _restartScanner();
                    }
                    return;
                  }

                  // User can scan - increment count if they don't have subscription
                  final hasSubscription = await _scanTrackingService
                      .hasActiveSubscription();
                  if (!hasSubscription) {
                    await _scanTrackingService.incrementFreeScansCount();
                  }

                  // Dispatch search event
                  widget.onBarcodeScanned?.call(barcode.rawValue!);
                  break;
                }
              }
            },
          ),
          // scan frame overlay
          IgnorePointer(
            child: Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final double side = constraints.maxWidth * 0.75;
                  return Container(
                    width: side,
                    height: side,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.9),
                        width: 4,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // Paywall button overlay
          // if (Platform.isIOS)
          //   Positioned(
          //     top: MediaQuery.of(context).padding.top + 16,
          //     right: 16,
          //     child: _isLoading
          //         ? const CircularProgressIndicator()
          //         : ElevatedButton.icon(
          //             onPressed: _showPaywall,
          //             icon: const Icon(Icons.star),
          //             label: const Text('Premium'),
          //             style: ElevatedButton.styleFrom(
          //               backgroundColor: Colors.white,
          //               foregroundColor: Colors.black87,
          //               padding: const EdgeInsets.symmetric(
          //                 horizontal: 16,
          //                 vertical: 12,
          //               ),
          //             ),
          //           ),
          //   ),
        ],
      ),
    );
  }
}
