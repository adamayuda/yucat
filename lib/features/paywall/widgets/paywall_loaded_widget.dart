import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  final bool dismissible;

  const PaywallLoadedWidget({
    super.key,
    required this.state,
    required this.bloc,
    this.dismissible = true,
  });

  @override
  State<PaywallLoadedWidget> createState() => _PaywallLoadedWidgetState();
}

class _PaywallLoadedWidgetState extends State<PaywallLoadedWidget> {
  // Promo switch defaults ON: open on the discounted yearly plan with weekly
  // hidden. Only meaningful when the annual plan has an eligible intro offer.
  bool _promoOn = true;

  String? _badgeFor(Package pkg) {
    if (pkg.packageType == PackageType.annual) {
      return 'BEST VALUE';
    }
    return null;
  }

  Package _annualOf(List<Package> packages) => packages.firstWhere(
        (p) => p.packageType == PackageType.annual,
        orElse: () => packages.first,
      );

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final bloc = widget.bloc;
    final packages = state.packages;

    final annual = _annualOf(packages);
    // The promo is only offered when the annual plan carries an introductory
    // offer AND the user is eligible for it (checked in the bloc).
    final promoAvailable = state.introEligible && hasIntroOffer(annual);
    final promoActive = promoAvailable && _promoOn;
    // When the promo is active we collapse to just the discounted yearly plan.
    final visible = promoActive ? <Package>[annual] : packages;

    return ColoredBox(
      color: DSColors.surfaceCard,
      child: Stack(
        children: [
          // Full-bleed content. No horizontal ListView padding so the hero
          // bleeds edge-to-edge; the other sections are padded individually.
          // The close chip lives inside _Hero so it scrolls away with it.
          ListView(
            padding: const EdgeInsets.only(bottom: 168),
            children: [
              _Hero(
                onClose: widget.dismissible
                    ? () => bloc.add(const PaywallDismissEvent())
                    : null,
              ),
              const SizedBox(height: DSDimens.sizeL),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: DSDimens.sizeL),
                child: Column(
                  children: [
                    if (promoAvailable) ...[
                      _PromoSwitch(
                        label: introSavingsLabelFor(annual) != null
                            ? 'Limited-time offer · ${introSavingsLabelFor(annual)}'
                            : 'Limited-time offer',
                        value: _promoOn,
                        onChanged: (on) {
                          setState(() => _promoOn = on);
                          // Turning the promo on collapses to the yearly plan,
                          // so make sure it's the selected (purchased) package.
                          if (on) {
                            bloc.add(
                              PaywallPackageSelectedEvent(package: annual),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: DSDimens.sizeS),
                    ],
                    for (var i = 0; i < visible.length; i++) ...[
                      if (i > 0) const SizedBox(height: DSDimens.sizeXs),
                      PaywallPackageRow(
                        package: visible[i],
                        allPackages: packages,
                        selected: visible[i].identifier ==
                            state.selectedPackage.identifier,
                        badge: _badgeFor(visible[i]),
                        showIntro: promoActive,
                        onTap: () => bloc.add(
                          PaywallPackageSelectedEvent(package: visible[i]),
                        ),
                      ),
                    ],
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
            ],
          ),
          // Fade behind the static CTA (same effect as the onboarding/success
          // floating footer).
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 160,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      DSColors.surfaceCard.withValues(alpha: 0),
                      DSColors.surfaceCard,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  DSDimens.sizeL,
                  DSDimens.sizeS,
                  DSDimens.sizeL,
                  DSDimens.sizeS,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      heightFactor: 1,
                      child: DSPillButton(
                        label: ctaLabelFor(state.selectedPackage),
                        onPressed: () =>
                            bloc.add(const PaywallPurchaseEvent()),
                        loading: state.isPurchasing,
                      ),
                    ),
                    const SizedBox(height: DSDimens.sizeXs),
                    const _Reassurance(),
                    // Debug-only escape hatch so the hard gate can be skipped
                    // while testing the rest of the app. Stripped from release
                    // builds (kDebugMode is a const false there).
                    if (kDebugMode && !widget.dismissible)
                      TextButton(
                        onPressed: () =>
                            bloc.add(const PaywallDismissEvent()),
                        child: Text(
                          'Skip paywall (debug)',
                          style: DSTextStyles.caption.copyWith(
                            color: DSColors.inkTertiary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PromoSwitch extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PromoSwitch({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        DSDimens.sizeS,
        DSDimens.sizeXxs,
        DSDimens.sizeXs,
        DSDimens.sizeXxs,
      ),
      decoration: BoxDecoration(
        color: DSColors.paywallAccentSoft,
        borderRadius: BorderRadius.circular(DSRadii.xl),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.local_offer_rounded,
            size: 18,
            color: DSColors.paywallAccent,
          ),
          const SizedBox(width: DSDimens.sizeXs),
          Expanded(
            child: Text(
              label,
              style: DSTextStyles.label.copyWith(
                color: DSColors.inkPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: DSColors.paywallAccent,
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({this.onClose});

  /// When null the close chip is hidden (hard-gate paywall).
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final topInset = MediaQuery.viewPaddingOf(context).top;
    // cat-cloud.svg is 391×378; rendered at full width its white cloud base
    // lands on the white content, hiding the gradient's bottom edge.
    final svgHeight = width * (378 / 391);
    final fullHeight = topInset + svgHeight;
    // Clip the empty white cloud below the cat so the branding sits close.
    final visibleHeight = topInset + svgHeight * 0.66;
    return Column(
      children: [
        // Full-bleed cat-on-cloud hero (the ListView has no horizontal
        // padding); it carries its own gradient + close chip so the whole
        // thing scrolls together and bleeds behind the status bar.
        ClipRect(
          child: SizedBox(
            height: visibleHeight,
            width: double.infinity,
            child: OverflowBox(
              minHeight: fullHeight,
              maxHeight: fullHeight,
              alignment: Alignment.topCenter,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Pink gradient behind the cat (covered below by the cloud).
                  const Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: DSGradients.paywallHero,
                      ),
                    ),
                  ),
                  const _HeroStar(size: 30, alignment: Alignment(-0.78, -0.55)),
                  const _HeroStar(size: 38, alignment: Alignment(0.8, -0.7)),
                  const _HeroStar(size: 22, alignment: Alignment(0.86, -0.05)),
                  const _HeroStar(size: 26, alignment: Alignment(-0.88, -0.1)),
                  // Cat-on-cloud, pushed below the status bar.
                  Positioned(
                    top: topInset,
                    left: 0,
                    right: 0,
                    child: SvgPicture.asset(
                      'assets/images/cat-cloud.svg',
                      width: width,
                    ),
                  ),
                  // Close chip — inside the hero so it scrolls away. Hidden
                  // when the paywall is a hard gate (onClose == null).
                  if (onClose != null)
                    Positioned(
                      top: topInset + DSDimens.sizeS,
                      left: DSDimens.sizeL,
                      child: _CloseChip(onTap: onClose!),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: DSDimens.sizeS),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: DSDimens.sizeL),
          child: Column(
            children: [
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
                      gradient: DSGradients.paywallBadge,
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
                    const TextSpan(text: 'Know '),
                    TextSpan(
                      text: 'exactly',
                      style: DSTextStyles.displayLg.copyWith(
                        color: DSColors.paywallAccent,
                      ),
                    ),
                    const TextSpan(text: "\nwhat's in the bowl"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeroStar extends StatelessWidget {
  final double size;
  final Alignment alignment;

  const _HeroStar({required this.size, required this.alignment});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ExcludeSemantics(
        child: SvgPicture.asset('assets/images/star-red.svg', width: size),
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
        Transform.flip(
          flipX: true,
          child: SvgPicture.asset('assets/images/wheat.svg', height: 46),
        ),
        const SizedBox(width: DSDimens.sizeS),
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
        const SizedBox(width: DSDimens.sizeS),
        SvgPicture.asset('assets/images/wheat.svg', height: 46),
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
          'Cancel anytime.',
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
