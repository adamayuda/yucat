import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/cat_listing/widgets/cat_listing_error_page.dart';
import 'package:yucat/features/paywall/widgets/paywall_error_widget.dart';
import 'package:yucat/presentation/top_app_bar/top_app_bar.dart';

void main() {
  runApp(const ErrorScreensPreviewApp());
}

class ErrorScreensPreviewApp extends StatelessWidget {
  const ErrorScreensPreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const ErrorScreensGallery(),
    );
  }
}

class ErrorScreensGallery extends StatelessWidget {
  const ErrorScreensGallery({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _ScreenFrame(
              label: 'Home Error',
              child: _HomeErrorScreen(),
            ),
            _ScreenFrame(
              label: 'Cat Listing Error',
              child: CatListingErrorWidget(
                message: 'Failed to load cats',
                onPressed: () {},
              ),
            ),
            _ScreenFrame(
              label: 'Product Detail Error',
              child: _ProductDetailErrorScreen(),
            ),
            _ScreenFrame(
              label: 'Search Error',
              child: _SearchErrorScreen(),
            ),
            _ScreenFrame(
              label: 'Paywall Error',
              child: const PaywallErrorWidget(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScreenFrame extends StatelessWidget {
  final String label;
  final Widget child;

  const _ScreenFrame({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Container(
            width: 390,
            height: 844,
            decoration: BoxDecoration(
              border: Border.all(color: DSColors.border),
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
            child: child,
          ),
        ],
      ),
    );
  }
}

class _HomeErrorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/Illustrations/Error.gif',
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 16),
            const Text('Error: Failed to initialize scanner'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductDetailErrorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: TopAppBar(title: ''),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/Illustrations/Error.gif',
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 16),
            const Text('Error loading product'),
          ],
        ),
      ),
    );
  }
}

class _SearchErrorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(DSDimens.sizeS),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search for a cat food',
                filled: true,
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/Illustrations/Error.gif',
                    width: 200,
                    height: 200,
                  ),
                  const SizedBox(height: 16),
                  const Text('Error occurred. Please try again.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
