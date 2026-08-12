import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/core/legal_urls.dart';
import 'package:yucat/features/paywall/bloc/paywall_bloc.dart';
import 'package:yucat/features/paywall/bloc/paywall_event.dart';
import 'package:yucat/features/paywall/bloc/paywall_state.dart';
import 'package:yucat/features/paywall/utils/paywall_format.dart';
import 'package:yucat/features/paywall/utils/trial_info.dart';
import 'package:yucat/features/paywall/widgets/paywall_testimonials.dart';
import 'package:yucat/features/paywall/widgets/paywall_value_props.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/ds_pill_button.dart';

class PaywallLoadedWidget extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Already eligibility-checked in the bloc, so it's safe to advertise.
    final trial = state.eligibleTrial;

    return ColoredBox(
      color: DSColors.surfaceCard,
      child: Stack(
        children: [
          // Full-bleed content. No horizontal ListView padding so the hero
          // bleeds edge-to-edge; the other sections are padded individually.
          // The close chip lives inside _Hero so it scrolls away with it.
          ListView(
            // Reserves room for the sticky footer: no-payment line + CTA +
            // terms line.
            padding: const EdgeInsets.only(bottom: 212),
            children: [
              _Hero(
                onClose: dismissible
                    ? () => bloc.add(const PaywallDismissEvent())
                    : null,
              ),
              const SizedBox(height: DSDimens.sizeL),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: DSDimens.sizeL),
                child: Column(
                  children: [
                    // No plan card: with a single plan there is nothing to pick,
                    // and the price/trial terms are already stated twice below —
                    // `_Reassurance` under the CTA and `_AutoRenewDisclosure` at
                    // the end of the scroll. `PaywallPackageRow` is kept in the
                    // codebase as the restore path for a second plan (README §11).
                    const SizedBox(height: DSDimens.sizeS),
                    const PaywallValueProps(),
                    const SizedBox(height: DSDimens.size3xl),
                    const PaywallTestimonials(),
                    const SizedBox(height: DSDimens.size3xl),
                    const _LaurelStats(),
                    const SizedBox(height: DSDimens.size3xl),
                    _AutoRenewDisclosure(
                      package: state.selectedPackage,
                      trial: trial,
                    ),
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
          // floating footer). It has to be taller than the footer itself and
          // reach full opacity well before the text starts, or scrolling
          // content shows through behind the disclosure lines.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 240,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      DSColors.surfaceCard.withValues(alpha: 0),
                      DSColors.surfaceCard,
                      DSColors.surfaceCard,
                    ],
                    stops: const [0, 0.42, 1],
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
                    // The single biggest objection at this moment is "am I
                    // about to be charged?" — answer it directly above the CTA.
                    if (trial != null) ...[
                      const _NoPaymentDue(),
                      const SizedBox(height: DSDimens.sizeXs),
                    ],
                    Center(
                      heightFactor: 1,
                      child: DSPillButton(
                        label: ctaLabelFor(
                          state.selectedPackage,
                          l10n,
                          trial: trial,
                        ),
                        onPressed: () =>
                            bloc.add(const PaywallPurchaseEvent()),
                        loading: state.isPurchasing,
                      ),
                    ),
                    const SizedBox(height: DSDimens.sizeXs),
                    _Reassurance(
                      package: state.selectedPackage,
                      trial: trial,
                    ),
                    // Debug-only escape hatch so the hard gate can be skipped
                    // while testing the rest of the app. Stripped from release
                    // builds (kDebugMode is a const false there).
                    if (kDebugMode && !dismissible)
                      TextButton(
                        onPressed: () =>
                            bloc.add(const PaywallDismissEvent()),
                        child: Text(
                          l10n.paywallSkipDebug,
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

class _Hero extends StatelessWidget {
  const _Hero({this.onClose});

  /// When null the close chip is hidden (hard-gate paywall).
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
                      l10n.paywallPlusBadge,
                      style: DSTextStyles.titleMd.copyWith(
                        color: DSColors.inkInverse,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DSDimens.sizeS),
              () {
                final headline = l10n.paywallHeroHeadline;
                final highlight = l10n.paywallHeroHighlight;
                final idx = headline.indexOf(highlight);
                final before = idx >= 0 ? headline.substring(0, idx) : headline;
                final highlighted = idx >= 0 ? highlight : '';
                final after = idx >= 0 ? headline.substring(idx + highlight.length) : '';
                return RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: DSTextStyles.displayLg,
                    children: [
                      TextSpan(text: before),
                      TextSpan(
                        text: highlighted,
                        style: DSTextStyles.displayLg.copyWith(
                          color: DSColors.paywallAccent,
                        ),
                      ),
                      TextSpan(text: after),
                    ],
                  ),
                );
              }(),
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
        child: SvgPicture.asset(
          'assets/images/star-sharp.svg',
          width: size,
          colorFilter: const ColorFilter.mode(
            DSColors.starBlue,
            BlendMode.srcIn,
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
    final l10n = AppLocalizations.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _LaurelStat(value: '4.7', label: l10n.paywallStatRatingLabel),
        _LaurelStat(value: '1M+', label: l10n.paywallStatCatParentsLabel),
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

/// "No payment due now" — shown only when a trial is actually being offered,
/// because with no trial payment *is* due now.
class _NoPaymentDue extends StatelessWidget {
  const _NoPaymentDue();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.check_circle_rounded,
          size: 18,
          color: DSColors.accentSuccess,
        ),
        const SizedBox(width: DSDimens.sizeXxs),
        Flexible(
          child: Text(
            l10n.paywallNoPaymentDue,
            textAlign: TextAlign.center,
            style: DSTextStyles.bodyMd.copyWith(
              color: DSColors.inkPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

/// The compact disclosure directly under the CTA. Trial length, the price it
/// converts to, and cancellation all have to be visible at the moment of
/// purchase — App Store guideline 3.1.2 and Play's subscription policy both
/// require it, and this is the line that satisfies them.
class _Reassurance extends StatelessWidget {
  final Package package;
  final TrialInfo? trial;

  const _Reassurance({required this.package, required this.trial});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final period = periodSuffixFor(package, l10n);
    final price = package.storeProduct.priceString;
    // A package type with no natural period (e.g. lifetime) can't state renewal
    // terms, so it falls back to the bare reassurance.
    final text = period == null
        ? l10n.paywallCancelAnytime
        : trial != null
            ? l10n.paywallTrialDisclosure(trial!.days, price, period)
            : l10n.paywallPriceDisclosure(price, period);
    // No icon: _NoPaymentDue sits directly above with a check mark, and two
    // stacked icons in a three-line footer reads cluttered.
    return Text(
      text,
      textAlign: TextAlign.center,
      style: DSTextStyles.caption.copyWith(color: DSColors.inkSecondary),
    );
  }
}

/// The long-form renewal terms at the bottom of the scroll. Spells out the
/// trial-to-paid conversion, since that's the part reviewers look for.
class _AutoRenewDisclosure extends StatelessWidget {
  final Package package;
  final TrialInfo? trial;

  const _AutoRenewDisclosure({required this.package, required this.trial});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Brand names, so not localized.
    final store = Platform.isIOS ? 'App Store' : 'Google Play';
    final period = periodSuffixFor(package, l10n) ?? '';
    final price = package.storeProduct.priceString;
    return Text(
      trial != null
          ? l10n.paywallAutoRenewDisclosureTrial(
              trial!.days, price, period, store)
          : l10n.paywallAutoRenewDisclosure(price, period, store),
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
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        DSTextLink(label: l10n.paywallRestorePurchases, onPressed: onRestore),
        DSTextLink(
          label: l10n.commonTerms,
          onPressed: () => _open(Uri.parse(kTermsUrl)),
        ),
        DSTextLink(
          label: l10n.commonPrivacy,
          onPressed: () => _open(Uri.parse(kPrivacyUrl)),
        ),
      ],
    );
  }
}
