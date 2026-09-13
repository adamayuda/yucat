import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/ds_option_row.dart';

/// Lets the user pick where a photo comes from. Resolves to the chosen
/// [ImageSource], or `null` if the sheet is dismissed.
///
/// Shared by the cat wizard's photo step and the cat-detail hero, so the two
/// entry points into "give this cat a photo" look and behave the same.
Future<ImageSource?> showPhotoSourceSheet(BuildContext context) {
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

/// Shows [showPhotoSourceSheet], then opens the chosen picker. Resolves to the
/// picked file, or `null` when the sheet or the picker was dismissed.
///
/// A picker failure (permission denied, camera unavailable) surfaces as a
/// snackbar naming the source that failed and still resolves to `null`, so
/// callers only ever have to handle "got a file" or "didn't".
Future<File?> pickPhotoFromSheet(
  BuildContext context,
  ImagePicker imagePicker,
) async {
  final source = await showPhotoSourceSheet(context);
  if (source == null) return null;
  try {
    final image = await imagePicker.pickImage(source: source);
    return image == null ? null : File(image.path);
  } catch (_) {
    if (!context.mounted) return null;
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
    return null;
  }
}
