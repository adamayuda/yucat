import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yucat/config/themes/theme.dart';

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
    final bool hasSelection = profilePhoto != null || useDefaultPhoto;

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'Add a photo of your cat',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(),
            ),
          ),
          Center(
            child: Text(
              'A cute picture makes the profile feel complete.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
          ),
          SizedBox(height: DSDimens.sizeM),
          if (hasSelection)
            // Show selected photo centered
            Column(
              children: [
                Center(
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: DSColors.white,
                      borderRadius: BorderRadius.circular(DSDimens.sizeM),
                      border: Border.all(color: Colors.grey[300]!, width: 1),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(DSDimens.sizeM),
                      child: profilePhoto != null
                          ? Image.file(profilePhoto!, fit: BoxFit.cover)
                          : Image.asset(
                              'assets/images/cat_default.png',
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                ),
                SizedBox(height: DSDimens.sizeM),
                Center(
                  child: OutlinedButton(
                    onPressed: onRemovePhoto,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: DSColors.primary),
                      foregroundColor: Colors.white,
                      backgroundColor: DSColors.primary.withOpacity(0.1),
                    ),
                    child: Text(
                      'Change Photo',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: DSColors.inputDarkGrey,
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            // Show both options side by side
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Upload square
                Expanded(
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
                      children: [
                        AspectRatio(
                          aspectRatio: 1,
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: DSColors.white,
                              borderRadius: BorderRadius.circular(
                                DSDimens.sizeM,
                              ),
                              border: Border.all(
                                color: Colors.grey[300]!,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: DSColors.primary.withOpacity(0.1),
                                  ),
                                  child: Icon(
                                    Icons.camera_alt,
                                    size: 40,
                                    color: DSColors.primary,
                                  ),
                                ),
                                SizedBox(height: DSDimens.sizeS),
                                Text(
                                  'Upload Photo',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: DSDimens.sizeM),
                // Default square
                Expanded(
                  child: GestureDetector(
                    onTap: onUseDefault,
                    child: Column(
                      children: [
                        AspectRatio(
                          aspectRatio: 1,
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: DSColors.white,
                              borderRadius: BorderRadius.circular(
                                DSDimens.sizeM,
                              ),
                              border: Border.all(
                                color: Colors.grey[300]!,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  child: Image.asset(
                                    'assets/images/cat_default.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                SizedBox(height: DSDimens.sizeS),
                                Text(
                                  'Use Default',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
