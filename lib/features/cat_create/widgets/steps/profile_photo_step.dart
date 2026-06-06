import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/presentation/components/ds_option_row.dart';
import 'package:yucat/presentation/components/mascot_speech_bubble.dart';

class ProfilePhotoStep extends StatelessWidget {
  final File? profilePhoto;
  final bool useDefaultPhoto;
  final ImagePicker imagePicker;
  final ValueChanged<File> onPhotoSelected;
  final VoidCallback onUseDefault;
  final VoidCallback onRemovePhoto;

  const ProfilePhotoStep({
    super.key,
    required this.profilePhoto,
    required this.useDefaultPhoto,
    required this.imagePicker,
    required this.onPhotoSelected,
    required this.onUseDefault,
    required this.onRemovePhoto,
  });

  Future<void> _pick(BuildContext context) async {
    final source = await _showPhotoSourceSheet(context);
    if (source == null) return;
    final image = await imagePicker.pickImage(source: source);
    if (image != null) {
      onPhotoSelected(File(image.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const MascotSpeechBubble(
          question: 'Add a photo of your cat',
        ),
        Expanded(
          child: Center(
            child: GestureDetector(
              onTap: () => _pick(context),
              child: profilePhoto != null
                  ? ClipOval(
                      child: Image.file(
                        profilePhoto!,
                        width: 187,
                        height: 187,
                        fit: BoxFit.cover,
                      ),
                    )
                  : SvgPicture.asset(
                      'assets/images/upload-photo.svg',
                      width: 187,
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Lets the user pick where the cat photo comes from. Resolves to the chosen
/// [ImageSource], or `null` if the sheet is dismissed.
Future<ImageSource?> _showPhotoSourceSheet(BuildContext context) {
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
              Text('Add a photo', style: DSTextStyles.titleMd),
              const SizedBox(height: DSDimens.sizeS),
              DSOptionRow(
                leadingIcon: Icons.camera_alt_rounded,
                label: 'Take a photo',
                onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
              ),
              const SizedBox(height: DSDimens.sizeXs),
              DSOptionRow(
                leadingIcon: Icons.photo_library_rounded,
                label: 'Upload from library',
                onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
