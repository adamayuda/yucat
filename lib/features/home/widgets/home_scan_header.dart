import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/search_products/presentation/widgets/search_text_field.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/ds_pill_button.dart';

/// The top of Home: **one** full-bleed blue slab carrying the search bar *and*
/// the scan pitch.
///
/// Two deliberate choices worth keeping:
///
/// - **The search bar lives inside the blue.** It used to be a pill floating on
///   `pageBackground` above a separate banner, which read as two unrelated
///   sections. The header owns its own status-bar inset (`MediaQuery.padding.top`)
///   rather than sitting inside a `SafeArea`, which is what lets the blue bleed
///   under the status bar — so [HomeDashboardPage] passes `top: false` to its
///   `SafeArea` and zero top padding to the list.
/// - **No barcode iconography.** YuCat does not read barcodes — the backend
///   scan pipeline identifies a *photograph of the package*, and the barcode
///   flow was deleted from both client and functions. Anything that looks like
///   a barcode teaches the wrong gesture, so the affordance is a viewfinder
///   framing a pack ([_PackViewfinder]), and the eyebrow glyph is
///   `Icons.crop_free` — the same frame the nav's Scan slot uses.
class HomeScanHeader extends StatefulWidget {
  final VoidCallback onSearchTap;
  final VoidCallback onScanTap;

  const HomeScanHeader({
    super.key,
    required this.onSearchTap,
    required this.onScanTap,
  });

  @override
  State<HomeScanHeader> createState() => _HomeScanHeaderState();
}

class _HomeScanHeaderState extends State<HomeScanHeader>
    with SingleTickerProviderStateMixin {
  /// Drives the viewfinder's scan line. One controller for the whole header —
  /// the sweep is the only motion here.
  late final AnimationController _sweep;

  @override
  void initState() {
    super.initState();
    _sweep = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _sweep.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final topInset = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      // White status-bar icons while the blue is under them. `HomeDashboardPage`
      // annotates the page dark, so scrolling the header away restores dark
      // icons on its own — the style is resolved from whatever region covers
      // the top of the screen.
      value: SystemUiOverlayStyle.light,
      child: Container(
        decoration: const BoxDecoration(
          gradient: DSGradients.homeScanHeader,
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(DSRadii.xl),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            const Positioned.fill(child: _Backdrop()),
            Padding(
              padding: EdgeInsets.fromLTRB(
                DSDimens.sizeL,
                topInset + DSDimens.sizeS,
                DSDimens.sizeL,
                DSDimens.sizeL,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SearchTextField(
                    readOnly: true,
                    hintText: l10n.searchHint,
                    onTap: widget.onSearchTap,
                  ),
                  const SizedBox(height: DSDimens.sizeL),
                  _ScanPitch(l10n: l10n, sweep: _sweep),
                  const SizedBox(height: DSDimens.sizeS),
                  SizedBox(
                    width: double.infinity,
                    child: DSPillButton(
                      label: l10n.homeScanProduct,
                      variant: DSPillButtonVariant.secondary,
                      onPressed: widget.onScanTap,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Eyebrow + headline + subtitle, all reversed out of the blue.
///
/// The eyebrow and headline run the **full** column width and only the subtitle
/// shares its line with the viewfinder. Putting the viewfinder beside the
/// headline instead left it about 225 px on a 393 pt screen, which is two words
/// a line at `headlineMd` — German and Hungarian ran to four lines there.
class _ScanPitch extends StatelessWidget {
  final AppLocalizations l10n;
  final Animation<double> sweep;

  const _ScanPitch({required this.l10n, required this.sweep});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const ExcludeSemantics(
              child: Icon(
                Icons.crop_free,
                size: 15,
                color: DSColors.inkInverse,
              ),
            ),
            const SizedBox(width: DSDimens.sizeXxs),
            Flexible(
              child: Text(
                l10n.homeScanEyebrow.toUpperCase(),
                style: DSTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: DSColors.inkInverse,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: DSDimens.sizeXs),
        Text(
          l10n.homeScanHeadline,
          style: DSTextStyles.headlineMd.copyWith(color: DSColors.inkInverse),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: DSDimens.sizeXs),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                l10n.homeScanProductSubtitle,
                style: DSTextStyles.bodyLg.copyWith(
                  color: DSColors.inkInverse.withValues(alpha: 0.85),
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: DSDimens.sizeS),
            _PackViewfinder(sweep: sweep),
          ],
        ),
      ],
    );
  }
}

/// Photo wash behind the header.
///
/// The repo has no purpose-shot header photo — every cat image is a 360 px
/// collage tile — so this runs one of them at low opacity under a blue scrim,
/// where the upscale is invisible. Swapping in a dedicated hi-res shot is a
/// one-line change to [_kBackdrop]; the `errorBuilder` means a missing file
/// degrades to the plain gradient rather than throwing.
class _Backdrop extends StatelessWidget {
  const _Backdrop();

  static const String _kBackdrop = 'assets/images/collage-senior-cat-bowl.jpg';

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            _kBackdrop,
            fit: BoxFit.cover,
            alignment: Alignment.centerRight,
            opacity: const AlwaysStoppedAnimation<double>(0.22),
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
          // Keeps the copy column legible: opaque blue on the left, clearing to
          // nothing over the viewfinder side.
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  DSColors.accentInfo,
                  DSColors.accentInfo.withValues(alpha: 0),
                ],
                stops: const [0.15, 0.95],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The scan affordance: four corner brackets around a cat-food pack, with a
/// line sweeping down it.
///
/// Deliberately a *pack* in a viewfinder rather than a barcode in a frame —
/// what the user has to do is photograph the package.
class _PackViewfinder extends StatelessWidget {
  final Animation<double> sweep;

  const _PackViewfinder({required this.sweep});

  static const double _size = 104;
  static const double _inner = 72;

  /// The closest thing the repo has to a pack shot. Swap for a real pouch/tin
  /// photo when one exists.
  static const String _kPack = 'assets/images/onboarding-food.png';

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox(
        width: _size,
        height: _size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Positioned.fill(
              child: CustomPaint(painter: _BracketPainter()),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(DSRadii.md),
              child: SizedBox(
                width: _inner,
                height: _inner,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ColoredBox(
                      color: DSColors.surfaceCard.withValues(alpha: 0.15),
                    ),
                    Image.asset(
                      _kPack,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                    _ScanLine(sweep: sweep),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A soft white bar travelling top→bottom, mirroring the sweep on the
/// post-capture scan theater (`home_loading_page.dart`) so opening the camera
/// and waiting for the verdict read as one gesture.
class _ScanLine extends StatelessWidget {
  final Animation<double> sweep;

  const _ScanLine({required this.sweep});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: sweep,
      builder: (context, child) {
        // Ease the travel and fade the ends so the line appears to pass
        // through rather than pop in at the edges.
        final t = sweep.value;
        final fade = math.sin(t * math.pi);
        return Align(
          alignment: Alignment(0, -1 + 2 * t),
          child: Opacity(opacity: fade, child: child),
        );
      },
      child: Container(
        // `Align` hands down loose constraints, and a gradient has no intrinsic
        // width — without this the bar collapses to zero and never shows.
        width: double.infinity,
        height: 2,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              DSColors.inkInverse.withValues(alpha: 0),
              DSColors.inkInverse,
              DSColors.inkInverse.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}

/// Four corner L-brackets — a viewfinder, not a closed frame.
class _BracketPainter extends CustomPainter {
  const _BracketPainter();

  static const double _arm = 20;
  static const double _radius = 6;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = DSColors.inkInverse
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;
    final path = Path()
      // Top-left
      ..moveTo(0, _arm)
      ..lineTo(0, _radius)
      ..arcToPoint(
        const Offset(_radius, 0),
        radius: const Radius.circular(_radius),
      )
      ..lineTo(_arm, 0)
      // Top-right
      ..moveTo(w - _arm, 0)
      ..lineTo(w - _radius, 0)
      ..arcToPoint(Offset(w, _radius), radius: const Radius.circular(_radius))
      ..lineTo(w, _arm)
      // Bottom-right
      ..moveTo(w, h - _arm)
      ..lineTo(w, h - _radius)
      ..arcToPoint(
        Offset(w - _radius, h),
        radius: const Radius.circular(_radius),
      )
      ..lineTo(w - _arm, h)
      // Bottom-left
      ..moveTo(_arm, h)
      ..lineTo(_radius, h)
      ..arcToPoint(
        Offset(0, h - _radius),
        radius: const Radius.circular(_radius),
      )
      ..lineTo(0, h - _arm);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BracketPainter oldDelegate) => false;
}
