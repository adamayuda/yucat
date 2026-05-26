import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/paywall/bloc/paywall_bloc.dart';
import 'package:yucat/features/paywall/bloc/paywall_event.dart';
import 'package:yucat/features/paywall/bloc/paywall_state.dart';
import 'package:yucat/features/paywall/utils/paywall_format.dart';
import 'package:yucat/features/paywall/widgets/paywall_package_row.dart';
import 'package:yucat/features/paywall/widgets/paywall_testimonials.dart';
import 'package:yucat/features/paywall/widgets/paywall_value_props.dart';
import 'package:yucat/presentation/components/ds_pill_button.dart';

const _termsUrl = 'https://yucat-web-production.up.railway.app/cgv.html';
const _privacyUrl = 'https://yucat-web-production.up.railway.app/policy.html';

class PaywallLoadedWidget extends StatefulWidget {
  final PaywallLoadedState state;
  final PaywallBloc bloc;

  const PaywallLoadedWidget({
    super.key,
    required this.state,
    required this.bloc,
  });

  @override
  State<PaywallLoadedWidget> createState() => _PaywallLoadedWidgetState();
}

class _PaywallLoadedWidgetState extends State<PaywallLoadedWidget> {
  bool _showAllPlans = false;

  /// Default-recommended plan: annual with free trial if available,
  /// otherwise the first annual, otherwise the first package.
  Package _defaultPlan(List<Package> packages) {
    final annualWithTrial = packages.firstWhere(
      (p) => p.packageType == PackageType.annual && hasFreeTrial(p),
      orElse: () => packages.firstWhere(
        (p) => p.packageType == PackageType.annual,
        orElse: () => packages.first,
      ),
    );
    return annualWithTrial;
  }

  String? _badgeFor(Package pkg) {
    if (pkg.packageType == PackageType.annual) {
      return hasFreeTrial(pkg) ? 'MOST POPULAR' : 'BEST VALUE';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final bloc = widget.bloc;
    final packages = state.packages;
    final defaultPlan = _defaultPlan(packages);
    final extraPlans = packages
        .where((p) => p.identifier != defaultPlan.identifier)
        .toList();
    final visiblePlans = _showAllPlans
        ? <Package>[defaultPlan, ...extraPlans]
        : <Package>[defaultPlan];

    return ColoredBox(
      color: DSColors.surfaceCard,
      child: Stack(
        children: [
          // Green hero band painted across the top; the white floor below
          // comes from the outer ColoredBox so the route never goes
          // transparent (its frame is opaque: false during slide-bottom).
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 320,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF57BC7E), Color(0xFF44A66E)],
                ),
              ),
            ),
          ),
          SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              DSDimens.sizeL,
              DSDimens.size3xl,
              DSDimens.sizeL,
              DSDimens.sizeL,
            ),
            children: [
              const _Hero(),
              const SizedBox(height: DSDimens.sizeL),
              for (var i = 0; i < visiblePlans.length; i++) ...[
                if (i > 0) const SizedBox(height: DSDimens.sizeXs),
                PaywallPackageRow(
                  package: visiblePlans[i],
                  allPackages: packages,
                  selected:
                      visiblePlans[i].identifier ==
                      state.selectedPackage.identifier,
                  badge: _badgeFor(visiblePlans[i]),
                  onTap: () => bloc.add(
                    PaywallPackageSelectedEvent(package: visiblePlans[i]),
                  ),
                ),
              ],
              if (extraPlans.isNotEmpty) ...[
                const SizedBox(height: DSDimens.sizeXs),
                Center(
                  child: TextButton(
                    onPressed: () =>
                        setState(() => _showAllPlans = !_showAllPlans),
                    child: Text(
                      _showAllPlans ? 'Hide other plans' : 'Show more plans ⌄',
                      style: DSTextStyles.label.copyWith(
                        color: DSColors.inkSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: DSDimens.sizeL),
              Center(
                child: DSPillButton(
                  label: ctaLabelFor(state.selectedPackage),
                  onPressed: () => bloc.add(const PaywallPurchaseEvent()),
                  loading: state.isPurchasing,
                ),
              ),
              const SizedBox(height: DSDimens.sizeXs),
              const _Reassurance(),
              const SizedBox(height: DSDimens.size3xl),
              const PaywallValueProps(),
              const SizedBox(height: DSDimens.size3xl),
              const PaywallTestimonials(),
              const SizedBox(height: DSDimens.size3xl),
              const _LaurelStats(),
              const SizedBox(height: DSDimens.size3xl),
              const _AutoRenewDisclosure(),
              const SizedBox(height: DSDimens.sizeS),
              _LegalLinks(
                onRestore: () => bloc.add(const PaywallRestoreEvent()),
              ),
            ],
          ),
        ),
          Positioned(
            top: MediaQuery.of(context).padding.top + DSDimens.sizeS,
            left: DSDimens.sizeS,
            child: _CloseChip(
              onTap: () => bloc.add(const PaywallDismissEvent()),
            ),
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 120,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Text('😼', style: TextStyle(fontSize: 100)),
              Positioned(
                top: 4,
                left: 12,
                child: Text('⚡', style: TextStyle(fontSize: 18)),
              ),
              Positioned(
                top: 16,
                right: 24,
                child: Text('⚡', style: TextStyle(fontSize: 22)),
              ),
              Positioned(
                bottom: 12,
                left: 32,
                child: Text(
                  '✦',
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 12,
                child: Text(
                  '✦',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: DSDimens.sizeL),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Yucat', style: DSTextStyles.headlineMd),
            const SizedBox(width: DSDimens.sizeXxs),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DSDimens.sizeXs,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: DSColors.accentSuccess,
                borderRadius: BorderRadius.circular(DSRadii.sm),
              ),
              child: Text(
                'Plus',
                style: DSTextStyles.titleMd.copyWith(
                  color: DSColors.inkInverse,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: DSDimens.sizeS),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: DSTextStyles.displayLg,
            children: [
              const TextSpan(text: 'Find the right\nfood '),
              TextSpan(
                text: '4.2× faster',
                style: DSTextStyles.displayLg.copyWith(
                  color: DSColors.accentSuccess,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CloseChip extends StatelessWidget {
  final VoidCallback onTap;

  const _CloseChip({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.4),
      shape: const CircleBorder(),
      elevation: 0,
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.4),
          shape: BoxShape.circle,
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

class _LaurelStats extends StatelessWidget {
  const _LaurelStats();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: const [
        _LaurelStat(value: '4.7', label: 'average\nrating'),
        _LaurelStat(value: '1M+', label: 'cat parents\nworldwide'),
      ],
    );
  }
}

class _LaurelStat extends StatelessWidget {
  final String value;
  final String label;

  const _LaurelStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('🌿', style: TextStyle(fontSize: 28)),
        const SizedBox(width: DSDimens.sizeXxs),
        Column(
          children: [
            Text(value, style: DSTextStyles.displayLg),
            Text(
              label,
              textAlign: TextAlign.center,
              style: DSTextStyles.caption.copyWith(
                color: DSColors.inkSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(width: DSDimens.sizeXxs),
        Transform.flip(
          flipX: true,
          child: const Text('🌿', style: TextStyle(fontSize: 28)),
        ),
      ],
    );
  }
}

class _Reassurance extends StatelessWidget {
  const _Reassurance();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.shield_outlined,
          size: 14,
          color: DSColors.inkTertiary,
        ),
        const SizedBox(width: DSDimens.sizeXxs),
        Text(
          'No payment now. Easy to cancel.',
          style: DSTextStyles.caption.copyWith(color: DSColors.inkSecondary),
        ),
      ],
    );
  }
}

class _AutoRenewDisclosure extends StatelessWidget {
  const _AutoRenewDisclosure();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Your subscription auto-renews unless cancelled at least 24 hours before '
      'the end of the current term. Cancel anytime in the App Store at no '
      'extra cost.',
      textAlign: TextAlign.center,
      style: DSTextStyles.caption.copyWith(color: DSColors.inkTertiary),
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
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        DSTextLink(label: 'Restore purchases', onPressed: onRestore),
        DSTextLink(
          label: 'Terms',
          onPressed: () => _open(Uri.parse(_termsUrl)),
        ),
        DSTextLink(
          label: 'Privacy',
          onPressed: () => _open(Uri.parse(_privacyUrl)),
        ),
      ],
    );
  }
}
