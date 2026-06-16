import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/ds_option_row.dart';
import 'package:yucat/presentation/components/mascot_speech_bubble.dart';

class ProfilePhotoStep extends StatelessWidget {
  final File? profilePhoto;
  final ImagePicker imagePicker;
  final ValueChanged<File> onPhotoSelected;

  const ProfilePhotoStep({
    super.key,
    required this.profilePhoto,
    required this.imagePicker,
    required this.onPhotoSelected,
  });

  Future<void> _pick(BuildContext context) async {
    final source = await _showPhotoSourceSheet(context);
    if (source == null) return;
    try {
      final image = await imagePicker.pickImage(source: source);
      if (image != null) {
        onPhotoSelected(File(image.path));
      }
    } catch (_) {
      if (!context.mounted) return;
      final l10n = AppLocalizations.of(context);
      final isCamera = source == ImageSource.camera;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              isCamera ? l10n.photoCameraError : l10n.photoLibraryError,
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MascotSpeechBubble(question: l10n.photoQuestion),
        Expanded(
          child: Center(
            child: GestureDetector(
              onTap: () => _pick(context),
              behavior: HitTestBehavior.opaque,
              child: profilePhoto != null
                  ? _SelectedPhoto(photo: profilePhoto!)
                  : _PhotoTapTarget(label: l10n.photoTapHint),
            ),
          ),
        ),
      ],
    );
  }
}

/// Chosen photo, clipped into the same circle as the empty tap target.
class _SelectedPhoto extends StatelessWidget {
  final File photo;

  const _SelectedPhoto({required this.photo});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _PhotoTapTarget.circleDiameter,
      height: _PhotoTapTarget.circleDiameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: DSColors.surfaceCard, width: 6),
        boxShadow: DSShadows.e1,
      ),
      child: ClipOval(child: Image.file(photo, fit: BoxFit.cover)),
    );
  }
}

/// Empty-state tap target: a large lavender circle with a camera badge and
/// "Tap here" label, with the winking cat mascot gripping the top rim.
///
/// The mascot is split into three pieces (head, hands, tail) so the circle can
/// sit *between* them: the head and tail tuck behind the rim while the paws
/// drape over the front — an effect a single flat SVG can't achieve. Piece
/// offsets are in the original 244×211 artwork frame.
class _PhotoTapTarget extends StatelessWidget {
  final String label;

  const _PhotoTapTarget({required this.label});

  static const double circleDiameter = 240;

  static const Color _violet = Color(0xFF7C6CE0);

  @override
  Widget build(BuildContext context) {
    // The SizedBox is exactly the circle, so centering it centers the *circle*
    // in the available space. The mascot pieces overflow above it (negative
    // tops, clip none) and don't shift the vertical centering. Offsets are in
    // circle-local coordinates (origin = circle top-left).
    return SizedBox(
      width: circleDiameter,
      height: circleDiameter,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Behind the circle: tail then head.
          const Positioned(
            left: 170,
            top: -10.467,
            child: _Piece(
              asset: 'assets/images/tail.svg',
              width: 77,
              height: 53,
            ),
          ),
          const Positioned(
            left: -2,
            top: -150,
            child: _Piece(
              asset: 'assets/images/head.svg',
              width: 213,
              height: 211,
            ),
          ),
          // The tap circle: camera badge centered, label below it.
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: DSColors.tintLavender,
                border: Border.all(color: DSColors.surfaceCard, width: 6),
              ),
              child: Stack(
                children: [
                  const Center(child: _CameraBadge(violet: _violet)),
                  // Centered vertically in the gap between the camera badge
                  // and the bottom of the main circle.
                  Align(
                    alignment: const Alignment(0, 0.7),
                    child: Text(
                      label,
                      style: DSTextStyles.bodyMd.copyWith(
                        color: _violet,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // In front of the circle: both paws resting on the rim, tilted a
          // touch so they drape naturally over the curve.
          Positioned(
            left: 56.0,
            top: -15,
            child: Transform.rotate(
              angle: 0.1,
              child: const _Piece(
                asset: 'assets/images/hands.svg',
                width: 124,
                height: 47,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A single mascot piece (head / hands / tail) rendered at its artwork size.
class _Piece extends StatelessWidget {
  final String asset;
  final double width;
  final double height;

  const _Piece({
    required this.asset,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SvgPicture.asset(asset, width: width, height: height),
    );
  }
}

/// White disc with a camera glyph.
class _CameraBadge extends StatelessWidget {
  final Color violet;

  const _CameraBadge({required this.violet});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: DSColors.surfaceCard,
      ),
      alignment: Alignment.center,
      child: Icon(Icons.photo_camera_rounded, color: violet, size: 40),
    );
  }
}

/// Lets the user pick where the cat photo comes from. Resolves to the chosen
/// [ImageSource], or `null` if the sheet is dismissed.
Future<ImageSource?> _showPhotoSourceSheet(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  return showModalBottomSheet<ImageSource>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => Container(
      decoration: const BoxDecoration(
        color: DSColors.surfaceCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(DSRadii.xl)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            DSDimens.sizeL,
            DSDimens.sizeS,
            DSDimens.sizeL,
            DSDimens.sizeL,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: DSColors.surfaceCardDim,
                    borderRadius: BorderRadius.circular(DSRadii.pill),
                  ),
                ),
              ),
              const SizedBox(height: DSDimens.sizeL),
              Text(l10n.photoSheetTitle, style: DSTextStyles.titleMd),
              const SizedBox(height: DSDimens.sizeS),
              DSOptionRow(
                leadingIcon: Icons.camera_alt_rounded,
                label: l10n.photoSheetTakePhoto,
                onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
              ),
              const SizedBox(height: DSDimens.sizeXs),
              DSOptionRow(
                leadingIcon: Icons.photo_library_rounded,
                label: l10n.photoSheetUploadLibrary,
                onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
