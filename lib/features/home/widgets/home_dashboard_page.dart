import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/home/widgets/dashboard_link_card.dart';
import 'package:yucat/features/home/widgets/greeting_card.dart';
import 'package:yucat/features/home/widgets/scan_counter_card.dart';
import 'package:yucat/features/home/widgets/scan_hero_card.dart';

class HomeDashboardPage extends StatelessWidget {
  final int? scansRemaining;
  final int? maxFreeScans;
  final bool isPremium;
  final String? primaryCatName;
  final String? primaryCatPhotoUrl;
  final VoidCallback onScanTap;
  final VoidCallback onSearchTap;
  final VoidCallback onUpgradeTap;

  const HomeDashboardPage({
    super.key,
    required this.scansRemaining,
    required this.maxFreeScans,
    required this.isPremium,
    required this.primaryCatName,
    required this.primaryCatPhotoUrl,
    required this.onScanTap,
    required this.onSearchTap,
    required this.onUpgradeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DSColors.tintLavender,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            DSDimens.sizeL,
            DSDimens.sizeS,
            DSDimens.sizeL,
            DSDimens.sizeL,
          ),
          children: [
            GreetingCard(
              primaryCatName: primaryCatName,
              primaryCatPhotoUrl: primaryCatPhotoUrl,
            ),
            const SizedBox(height: DSDimens.sizeS),
            ScanHeroCard(onTap: onScanTap),
            const SizedBox(height: DSDimens.sizeS),
            ScanCounterCard(
              scansRemaining: scansRemaining,
              maxFreeScans: maxFreeScans,
              isPremium: isPremium,
              onUpgradeTap: isPremium ? null : onUpgradeTap,
            ),
            const SizedBox(height: DSDimens.sizeS),
            DashboardLinkCard(
              icon: Icons.search_rounded,
              title: 'Browse the catalog',
              subtitle: 'Search thousands of products',
              onTap: onSearchTap,
              iconBackground: DSColors.tintSky,
              iconColor: DSColors.accentInfo,
            ),
          ],
        ),
      ),
    );
  }
}
