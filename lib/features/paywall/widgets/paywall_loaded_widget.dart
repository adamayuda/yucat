import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/paywall/bloc/paywall_bloc.dart';
import 'package:yucat/features/paywall/bloc/paywall_event.dart';
import 'package:yucat/features/paywall/bloc/paywall_state.dart';
import 'package:yucat/features/paywall/utils/paywall_format.dart';
import 'package:yucat/features/paywall/widgets/paywall_package_row.dart';
import 'package:yucat/features/paywall/widgets/paywall_value_props.dart';
import 'package:yucat/presentation/components/ds_pill_button.dart';

const _termsUrl = 'https://yucat-web-production.up.railway.app/cgv.html';
const _privacyUrl = 'https://yucat-web-production.up.railway.app/policy.html';

class PaywallLoadedWidget extends StatelessWidget {
  final PaywallLoadedState state;
  final PaywallBloc bloc;

  const PaywallLoadedWidget({
    super.key,
    required this.state,
    required this.bloc,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: DSColors.tintMint,
      child: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(
                DSDimens.sizeL,
                DSDimens.size3xl,
                DSDimens.sizeL,
                DSDimens.sizeL,
              ),
              children: [
                Image.asset(
                  'assets/images/Illustrations/Add new cat.gif',
                  height: 180,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: DSDimens.sizeS),
                _ProTag(),
                const SizedBox(height: DSDimens.sizeXs),
                Text(
                  'Find food that fits\nevery cat you own',
                  textAlign: TextAlign.center,
                  style: DSTextStyles.displayLg,
                ),
                const SizedBox(height: DSDimens.sizeL),
                for (var i = 0; i < state.packages.length; i++) ...[
                  if (i > 0) const SizedBox(height: DSDimens.sizeXs),
                  PaywallPackageRow(
                    package: state.packages[i],
                    allPackages: state.packages,
                    selected:
                        state.packages[i].identifier ==
                            state.selectedPackage.identifier,
                    badge: _badgeFor(state.packages[i]),
                    onTap: () => bloc.add(
                      PaywallPackageSelectedEvent(
                        package: state.packages[i],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: DSDimens.sizeL),
                const PaywallValueProps(),
                const SizedBox(height: DSDimens.size3xl),
                Center(
                  child: DSPillButton(
                    label: ctaLabelFor(state.selectedPackage),
                    onPressed: () => bloc.add(const PaywallPurchaseEvent()),
                    loading: state.isPurchasing,
                  ),
                ),
                const SizedBox(height: DSDimens.sizeS),
                _LegalLinks(
                  onRestore: () => bloc.add(const PaywallRestoreEvent()),
                ),
              ],
            ),
            Positioned(
              top: DSDimens.sizeS,
              left: DSDimens.sizeS,
              child: _CloseChip(
                onTap: () => bloc.add(const PaywallDismissEvent()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _badgeFor(Package pkg) {
    if (pkg.packageType == PackageType.annual) {
      return hasFreeTrial(pkg) ? 'MOST POPULAR' : 'BEST VALUE';
    }
    return null;
  }
}

class _ProTag extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: DSDimens.sizeS,
          vertical: DSDimens.sizeXxxs,
        ),
        decoration: BoxDecoration(
          color: DSColors.accentSuccess,
          borderRadius: BorderRadius.circular(DSRadii.pill),
        ),
        child: Text(
          'YuCat Pro',
          style: DSTextStyles.caption.copyWith(
            color: DSColors.inkInverse,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
      ),
    );
  }
}

class _CloseChip extends StatelessWidget {
  final VoidCallback onTap;

  const _CloseChip({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: DSColors.surfaceCard,
      shape: const CircleBorder(),
      elevation: 0,
      child: Ink(
        decoration: BoxDecoration(
          color: DSColors.surfaceCard,
          shape: BoxShape.circle,
          boxShadow: DSShadows.e1,
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: const SizedBox(
            width: 36,
            height: 36,
            child: Icon(
              Icons.close_rounded,
              color: DSColors.inkPrimary,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }
}

class _LegalLinks extends StatelessWidget {
  final VoidCallback onRestore;

  const _LegalLinks({required this.onRestore});

  Future<void> _open(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.inAppWebView);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DSTextLink(label: 'Restore purchases', onPressed: onRestore),
        Text(
          '·',
          style: DSTextStyles.bodyMd.copyWith(color: DSColors.inkTertiary),
        ),
        DSTextLink(
          label: 'Terms',
          onPressed: () => _open(Uri.parse(_termsUrl)),
        ),
        Text(
          '·',
          style: DSTextStyles.bodyMd.copyWith(color: DSColors.inkTertiary),
        ),
        DSTextLink(
          label: 'Privacy',
          onPressed: () => _open(Uri.parse(_privacyUrl)),
        ),
      ],
    );
  }
}
