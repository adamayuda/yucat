import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart' show NumberFormat;
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/paywall/bloc/paywall_bloc.dart';
import 'package:yucat/features/paywall/bloc/paywall_event.dart';
import 'package:yucat/features/paywall/utils/intro_offer_info.dart';
import 'package:yucat/features/paywall/utils/paywall_format.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/ds_circle_icon_button.dart';
import 'package:yucat/presentation/components/ds_haptics.dart';

/// The full-height "limited-time offer" sheet: the same yearly plan with a
/// pay-up-front first year ([intro]), presented once per paywall session —
/// after the first cancel of Apple's sheet on the onboarding gate, or on its
/// own for returning users (see `PaywallBloc`).
///
/// Layout: headline with the discount percentage in green, a dark ticket-style
/// card the mascot peeks over, a countdown pill, the full monthly-equivalent
/// price struck through above the discounted one, a green CTA, and the legal
/// line under the card.
///
/// ⚠️ **The countdown is real.** [deadline] is set the first time the sheet is
/// presented and persisted by the bloc; the offer is withheld once it passes.
/// A timer that reset on every open would be fake urgency — App Review rejects
/// it, and a brand that sells trust can't afford it. When the clock reaches
/// zero while the sheet is open, it closes itself.
///
/// Resolves to nothing; the outcome is reported to [bloc] as
/// [PaywallSecondChanceAcceptedEvent] or [PaywallSecondChanceDismissedEvent],
/// so the close chip, a swipe-down and a tap outside all count the same.
Future<void> showPaywallSecondChanceSheet(
  BuildContext context, {
  required PaywallBloc bloc,
  required Package package,
  required IntroOfferInfo intro,
  required DateTime deadline,
}) async {
  final accepted = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _SecondChanceSheet(
      package: package,
      intro: intro,
      deadline: deadline,
    ),
  );
  bloc.add(
    accepted == true
        ? const PaywallSecondChanceAcceptedEvent()
        : const PaywallSecondChanceDismissedEvent(),
  );
}

class _SecondChanceSheet extends StatefulWidget {
  final Package package;
  final IntroOfferInfo intro;
  final DateTime deadline;

  const _SecondChanceSheet({
    required this.package,
    required this.intro,
    required this.deadline,
  });

  @override
  State<_SecondChanceSheet> createState() => _SecondChanceSheetState();
}

class _SecondChanceSheetState extends State<_SecondChanceSheet> {
  Timer? _ticker;
  late Duration _left;

  @override
  void initState() {
    super.initState();
    _left = _remaining();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      final left = _remaining();
      if (!mounted) return;
      setState(() => _left = left);
      if (left == Duration.zero) {
        _ticker?.cancel();
        // The deadline the user was shown has passed: the offer is gone.
        Navigator.of(context).pop(false);
      }
    });
  }

  Duration _remaining() {
    final d = widget.deadline.difference(DateTime.now());
    return d.isNegative ? Duration.zero : d;
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final product = widget.package.storeProduct;
    final period = periodSuffixFor(widget.package, l10n);
    final discount = _discountPercent(product.price, widget.intro.price);
    final discountLabel = l10n.paywallOfferDiscount(discount);
    final headline = l10n.paywallOfferHeadline(discountLabel);
    // Per-month equivalents, formatted by the store's currency in the user's
    // locale — never a hand-built string, separators differ per locale.
    final money = NumberFormat.simpleCurrency(
      locale: Localizations.localeOf(context).toString(),
      name: product.currencyCode,
    );
    final fullMonthly = money.format(product.price / 12);
    final introMonthly = money.format(widget.intro.price / 12);

    return Container(
      height: double.infinity,
      decoration: const BoxDecoration(
        color: DSColors.pageBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(DSRadii.xl)),
      ),
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              DSDimens.sizeL,
              DSDimens.size3xl,
              DSDimens.sizeL,
              DSDimens.sizeL,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: DSDimens.sizeL),
                _Headline(text: headline, highlight: discountLabel),
                const SizedBox(height: DSDimens.size3xl),
                _TicketCard(
                  countdown: l10n.paywallOfferExpiresIn(_format(_left)),
                  fullMonthly: fullMonthly,
                  introMonthly: introMonthly,
                  perMonth: l10n.paywallOfferPerMonth,
                  cta: l10n.paywallOfferCta,
                  onCta: () {
                    DSHaptics.tap();
                    Navigator.of(context).pop(true);
                  },
                ),
                const SizedBox(height: DSDimens.sizeL),
                Text(
                  period == null
                      ? l10n.paywallCancelAnytime
                      : l10n.paywallIntroDisclosure(
                          widget.intro.priceString,
                          product.priceString,
                          period,
                        ),
                  textAlign: TextAlign.center,
                  style: DSTextStyles.caption.copyWith(
                    color: DSColors.inkTertiary,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: DSDimens.sizeS,
            left: DSDimens.sizeS,
            child: DSCircleIconButton(
              icon: Icons.close_rounded,
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ),
        ],
      ),
    );
  }

  static int _discountPercent(double full, double intro) {
    if (full <= 0 || intro >= full) return 0;
    return ((1 - intro / full) * 100).round();
  }

  static String _format(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    return '${two(h)}:${two(m)}:${two(s)}';
  }
}

/// "Limited-time offer: -33%" with the discount in green. The green part is
/// found inside the composed string, the same trick the hero headline uses,
/// so a locale that moves the placeholder still colours the right words.
class _Headline extends StatelessWidget {
  final String text;
  final String highlight;

  const _Headline({required this.text, required this.highlight});

  @override
  Widget build(BuildContext context) {
    final base = DSTextStyles.displayHero.copyWith(color: DSColors.inkPrimary);
    final i = text.indexOf(highlight);
    if (i < 0) {
      return Text(text, textAlign: TextAlign.center, style: base);
    }
    return Text.rich(
      TextSpan(
        style: base,
        children: [
          TextSpan(text: text.substring(0, i)),
          TextSpan(
            text: highlight,
            style: const TextStyle(color: DSColors.accentSuccess),
          ),
          TextSpan(text: text.substring(i + highlight.length)),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}

/// The dark ticket: mascot over the top edge, countdown, prices, a dashed
/// tear line with side notches, and the green CTA.
class _TicketCard extends StatelessWidget {
  final String countdown;
  final String fullMonthly;
  final String introMonthly;
  final String perMonth;
  final String cta;
  final VoidCallback onCta;

  const _TicketCard({
    required this.countdown,
    required this.fullMonthly,
    required this.introMonthly,
    required this.perMonth,
    required this.cta,
    required this.onCta,
  });

  static const double _mascotHeight = 120;
  static const double _mascotOverlap = 64;
  static const double _notchRadius = 18;

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Room for the part of the mascot that rises above the card.
      padding: const EdgeInsets.only(top: _mascotHeight - _mascotOverlap),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(DSRadii.xl + 8),
            child: Container(
              color: DSColors.inkPrimary,
              child: CustomPaint(
                painter: const _PercentPatternPainter(),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    DSDimens.sizeL,
                    _mascotOverlap + DSDimens.sizeL,
                    DSDimens.sizeL,
                    DSDimens.sizeL,
                  ),
                  child: Column(
                    children: [
                      _CountdownPill(text: countdown),
                      const SizedBox(height: DSDimens.sizeL),
                      Text(
                        fullMonthly,
                        style: DSTextStyles.titleMd.copyWith(
                          color: Colors.white54,
                          decoration: TextDecoration.lineThrough,
                          decorationColor: Colors.white54,
                        ),
                      ),
                      Text(
                        introMonthly,
                        style: DSTextStyles.displayHero.copyWith(
                          color: DSColors.inkInverse,
                          fontSize: 56,
                          height: 1.05,
                        ),
                      ),
                      Text(
                        perMonth,
                        style: DSTextStyles.bodyLg.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: DSDimens.sizeL),
                      const _TearLine(),
                      const SizedBox(height: DSDimens.sizeL),
                      _GreenCta(label: cta, onPressed: onCta),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // The two notches that make the dashed line read as a tear-off
          // edge: page-coloured discs sitting half outside the card.
          const _Notch(side: _Side.left),
          const _Notch(side: _Side.right),
          Positioned(
            top: -(_mascotHeight - _mascotOverlap),
            child: SvgPicture.asset(
              'assets/images/cat-laught.svg',
              height: _mascotHeight,
            ),
          ),
        ],
      ),
    );
  }
}

enum _Side { left, right }

class _Notch extends StatelessWidget {
  final _Side side;

  const _Notch({required this.side});

  @override
  Widget build(BuildContext context) {
    // Centred on the tear line, measured from the card's bottom edge: the
    // card's bottom padding, the CTA, the gap above it, then half the line's
    // 2 px height. Fixed layout, so a fixed offset holds.
    const lineCenter = DSDimens.sizeL + _GreenCta.height + DSDimens.sizeL + 1;
    const bottom = lineCenter - _TicketCard._notchRadius;
    return Positioned(
      bottom: bottom,
      left: side == _Side.left ? -_TicketCard._notchRadius : null,
      right: side == _Side.right ? -_TicketCard._notchRadius : null,
      child: Container(
        width: _TicketCard._notchRadius * 2,
        height: _TicketCard._notchRadius * 2,
        decoration: const BoxDecoration(
          color: DSColors.pageBackground,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _CountdownPill extends StatelessWidget {
  final String text;

  const _CountdownPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSDimens.sizeM,
        vertical: DSDimens.sizeXs,
      ),
      decoration: BoxDecoration(
        color: DSColors.accentDanger.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(DSRadii.md),
      ),
      child: Text(
        text,
        style: DSTextStyles.label.copyWith(
          color: const Color(0xFFFF8A7E),
          fontWeight: FontWeight.w700,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

class _TearLine extends StatelessWidget {
  const _TearLine();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 2,
      width: double.infinity,
      child: CustomPaint(painter: _DashPainter()),
    );
  }
}

class _DashPainter extends CustomPainter {
  const _DashPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white30
      ..strokeWidth = 2;
    const dash = 8.0, gap = 6.0;
    var x = 0.0;
    final y = size.height / 2;
    while (x < size.width) {
      canvas.drawLine(Offset(x, y), Offset(math.min(x + dash, size.width), y), paint);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Faint, tilted "%" glyphs scattered over the card — the wallpaper that makes
/// the ticket read as a coupon rather than a plain dark box.
class _PercentPatternPainter extends CustomPainter {
  const _PercentPatternPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final tp = TextPainter(
      text: const TextSpan(
        text: '%',
        style: TextStyle(
          color: Colors.white,
          fontSize: 44,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.05);
    const stepX = 96.0, stepY = 88.0;
    var row = 0;
    for (var y = -20.0; y < size.height; y += stepY, row++) {
      final offset = row.isOdd ? stepX / 2 : 0.0;
      for (var x = -30.0 + offset; x < size.width; x += stepX) {
        canvas.save();
        canvas.translate(x, y);
        canvas.rotate(-0.35);
        canvas.saveLayer(null, paint);
        tp.paint(canvas, Offset.zero);
        canvas.restore();
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GreenCta extends StatelessWidget {
  static const double height = 60;

  final String label;
  final VoidCallback onPressed;

  const _GreenCta({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    // A darker rim around the pill, like a pressed button — the one place the
    // design system's black pill would vanish against the dark card.
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF1F6B34),
        borderRadius: BorderRadius.circular(DSRadii.pill),
      ),
      padding: const EdgeInsets.all(4),
      child: Material(
        color: DSColors.accentSuccess,
        borderRadius: BorderRadius.circular(DSRadii.pill),
        child: InkWell(
          borderRadius: BorderRadius.circular(DSRadii.pill),
          onTap: onPressed,
          child: Center(
            child: Text(
              label,
              style: DSTextStyles.titleMd.copyWith(
                color: DSColors.inkInverse,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
