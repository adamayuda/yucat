import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yucat/config/themes/theme.dart';
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
              onTap: () async {
                final XFile? image = await imagePicker.pickImage(
                  source: ImageSource.gallery,
                );
                if (image != null) {
                  onPhotoSelected(File(image.path));
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 175,
                    height: 175,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: DSColors.surfaceCardDim,
                    ),
                    child: profilePhoto != null
                        ? ClipOval(
                            child: Image.file(
                              profilePhoto!,
                              width: 175,
                              height: 175,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(
                            Icons.camera_alt_rounded,
                            size: 64,
                            color: DSColors.inkTertiary,
                          ),
                  ),
                  const SizedBox(height: DSDimens.sizeS),
                  Text(
                    profilePhoto != null ? 'Tap to change' : 'Tap to upload',
                    style: DSTextStyles.bodyLg.copyWith(
                      color: DSColors.inkSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
