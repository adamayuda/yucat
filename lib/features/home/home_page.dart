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
import 'package:yucat/features/home/widgets/home_loaded_page.dart';
import 'package:yucat/features/home/widgets/home_loading_page.dart';
import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';
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
    return BlocBuilder<HomeBloc, HomeState>(
      bloc: _bloc,
      builder: (context, state) => _onStateChangeBuilder(state),
    );
  }

  Widget _onStateChangeBuilder(HomeState state) {
    switch (state) {
      case HomeLoadingState():
        return Scaffold(
          backgroundColor: DSColors.lightGrey,
          body: const HomeLoadingWidget(),
        );
      case HomeLoadedState(:final hasScanned):
        return HomeLoadedPage(
          onBarcodeDetected: (barcode) {
            _bloc.add(BarcodeDetectedEvent(barcode: barcode, context: context));
          },
          hasScanned: hasScanned,
        );
      // return _HomeLoadedState(bloc: _bloc);
      // case HomeSearchResultsState():
      //   return _HomeLoadedState(bloc: _bloc, searchResults: state.products);
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

// Future<void> _showPaywallAndHandleResult(String barcode) async {
//   final purchasedSubscription = await _showPaywall();
//   _bloc.add(
//     PaywallDismissedEvent(purchasedSubscription: purchasedSubscription),
//   );
// }

// Future<bool> _showPaywall() async {
//   try {
//     CustomerInfo customerInfo = await Purchases.getCustomerInfo();

//     if (customerInfo.entitlements.all['yucat pro'] != null &&
//         customerInfo.entitlements.all['yucat pro']?.isActive == true) {
//       // User already has active subscription
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('You already have an active subscription'),
//           duration: Duration(seconds: 2),
//         ),
//       );
//       return true;
//     } else {
//       Offerings? offerings;
//       try {
//         offerings = await Purchases.getOfferings();
//       } on PlatformException catch (e) {
//         await showDialog(
//           context: context,
//           builder: (BuildContext context) => AlertDialog(
//             title: const Text('Error'),
//             content: Text(e.message ?? 'Unknown error'),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.of(context).pop(),
//                 child: const Text('OK'),
//               ),
//             ],
//           ),
//         );
//       }

//       if (offerings == null || offerings.current == null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('No offerings available at this time'),
//             duration: Duration(seconds: 2),
//           ),
//         );
//         return false;
//       } else if (offerings.current!.availablePackages.isEmpty) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text(
//               'No subscription packages available. Please configure products in RevenueCat dashboard.',
//             ),
//             backgroundColor: Colors.orange,
//             duration: Duration(seconds: 4),
//           ),
//         );
//         return false;
//       } else {
//         // Current offering is available with packages, show paywall
//         final paywallResult = await RevenueCatUI.presentPaywall();
//         debugPrint('Paywall result: $paywallResult');

//         // After paywall is dismissed, sync and check if user purchased subscription
//         if (mounted) {
//           try {
//             await Purchases.syncPurchases();
//             await Future.delayed(const Duration(milliseconds: 500));

//             final updatedCustomerInfo = await Purchases.getCustomerInfo();
//             final hasActiveSubscription =
//                 updatedCustomerInfo.entitlements.all['yucat pro']?.isActive ==
//                 true;
//             if (hasActiveSubscription) {
//               final scanTrackingService = sl<ScanTrackingService>();
//               await scanTrackingService.resetFreeScansCount();
//               return true;
//             }
//           } catch (e) {
//             debugPrint('Error checking subscription after paywall: $e');
//             try {
//               final updatedCustomerInfo = await Purchases.getCustomerInfo();
//               final hasActiveSubscription =
//                   updatedCustomerInfo.entitlements.all['yucat pro']?.isActive ==
//                   true;
//               if (hasActiveSubscription) {
//                 final scanTrackingService = sl<ScanTrackingService>();
//                 await scanTrackingService.resetFreeScansCount();
//                 return true;
//               }
//             } catch (e2) {
//               debugPrint('Error getting customer info: $e2');
//             }
//           }
//         }
//         return false;
//       }
//     }
//   } catch (e) {
//     debugPrint('Error showing paywall: $e');
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Error: ${e.toString()}'),
//         backgroundColor: Colors.red,
//         duration: const Duration(seconds: 3),
//       ),
//     );
//     return false;
//   }
// }

// class _HomeLoadedState extends StatefulWidget {
//   final HomeBloc bloc;
//   final List<ProductDisplayModel>? searchResults;

//   const _HomeLoadedState({required this.bloc, this.searchResults});

//   @override
//   State<_HomeLoadedState> createState() => __HomeLoadedState();
// }

// class __HomeLoadedState extends State<_HomeLoadedState> {
//   // Create controller with autoStart enabled - the MobileScanner widget will handle initialization
//   final MobileScannerController _scannerController = MobileScannerController();
//   bool _hasScanned = false;
//   bool _isRestarting = false;

//   Future<void> _restartScanner() async {
//     if (_isRestarting) return;
//     if (!mounted) return;

//     _isRestarting = true;
//     try {
//       await _scannerController.stop();
//       // Wait for controller to fully stop before restarting
//       await Future.delayed(const Duration(milliseconds: 500));

//       // Start the scanner again
//       if (mounted) {
//         await _scannerController.start();
//       }
//     } catch (e) {
//       debugPrint('Error restarting scanner: $e');
//       // If restart fails, try to start anyway after a delay
//       if (mounted) {
//         await Future.delayed(const Duration(milliseconds: 1000));
//         try {
//           await _scannerController.start();
//         } catch (e2) {
//           debugPrint('Error starting scanner after failed restart: $e2');
//         }
//       }
//     } finally {
//       if (mounted) {
//         _isRestarting = false;
//       }
//     }
//   }

//   @override
//   void didUpdateWidget(_HomeLoadedState oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     // Handle search results when they change (new scan completed)
//     if (oldWidget.searchResults != widget.searchResults) {
//       if (widget.searchResults != null) {
//         if (widget.searchResults!.isNotEmpty) {
//           // Product found - navigate to detail page
//           final product = widget.searchResults!.first;
//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             context.router.push(ProductDetailRoute(product: product));
//           });
//         } else {
//           // No product found - show error
//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(
//                 content: Text('Product not found'),
//                 backgroundColor: Colors.red,
//                 duration: Duration(seconds: 3),
//               ),
//             );
//           });
//         }
//         // Reset scanner for next scan
//         _hasScanned = false;
//         _restartScanner();
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocListener<HomeBloc, HomeState>(
//       bloc: widget.bloc,
//       listenWhen: (previous, current) => current is HomeScanResetState,
//       listener: (context, state) {
//         if (state is HomeScanResetState) {
//           // Reset scanner for next scan
//           _hasScanned = false;
//           _restartScanner();
//         }
//       },
//       child: _buildScannerView(),
//     );
//   }

//   Widget _buildScannerView() {
//     return Scaffold(
//       backgroundColor: DSColors.lightGrey,
//       body: Stack(
//         children: [
//           // camera
//           MobileScanner(
//             controller: _scannerController,
//             onDetect: (capture) async {
//               if (_hasScanned) return; // Prevent multiple scans

//               final List<Barcode> barcodes = capture.barcodes;
//               for (final barcode in barcodes) {
//                 if (barcode.rawValue != null) {
//                   debugPrint('Scanned barcode: ${barcode.rawValue}');
//                   _hasScanned = true;
//                   // Stop scanning to prevent multiple calls
//                   _scannerController.stop();

//                   // Dispatch event to bloc
//                   widget.bloc.add(
//                     BarcodeDetectedEvent(barcode: barcode.rawValue!),
//                   );
//                   break;
//                 }
//               }
//             },
//           ),
//           // scan frame overlay
//           IgnorePointer(
//             child: Center(
//               child: LayoutBuilder(
//                 builder: (context, constraints) {
//                   final double side = constraints.maxWidth * 0.75;
//                   return Container(
//                     width: side,
//                     height: side,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(16),
//                       border: Border.all(
//                         color: Colors.white.withOpacity(0.9),
//                         width: 4,
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ),
//           // Paywall button overlay
//           // if (Platform.isIOS)
//           //   Positioned(
//           //     top: MediaQuery.of(context).padding.top + 16,
//           //     right: 16,
//           //     child: _isLoading
//           //         ? const CircularProgressIndicator()
//           //         : ElevatedButton.icon(
//           //             onPressed: _showPaywall,
//           //             icon: const Icon(Icons.star),
//           //             label: const Text('Premium'),
//           //             style: ElevatedButton.styleFrom(
//           //               backgroundColor: Colors.white,
//           //               foregroundColor: Colors.black87,
//           //               padding: const EdgeInsets.symmetric(
//           //                 horizontal: 16,
//           //                 vertical: 12,
//           //               ),
//           //             ),
//           //           ),
//           //   ),
//           // Test button overlay
//           // Positioned(
//           //   bottom: 32,
//           //   left: 16,
//           //   right: 16,
//           //   child: ElevatedButton(
//           //     onPressed: () {
//           //       widget.bloc.add(SearchByBarcodeEvent(barcode: '6970117126389'));
//           //     },
//           //     style: ElevatedButton.styleFrom(
//           //       backgroundColor: Colors.blue,
//           //       foregroundColor: Colors.white,
//           //       padding: const EdgeInsets.symmetric(
//           //         horizontal: 24,
//           //         vertical: 16,
//           //       ),
//           //     ),
//           //     child: const Text('Test Barcode Search'),
//           //   ),
//           // ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _scannerController.dispose();
//     super.dispose();
//   }
// }

