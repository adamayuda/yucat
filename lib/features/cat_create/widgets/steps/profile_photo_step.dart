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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: DSColors.primaryLight,
                  borderRadius: BorderRadius.circular(DSDimens.sizeXxs),
                ),
                width: 40,
                height: 40,
                child: Image.asset(
                  'assets/images/Icons/camera.png',
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(width: DSDimens.sizeS),
              Expanded(
                child: Text(
                  'Add a photo of your cat',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 29,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: DSDimens.sizeS),

          Center(
            child: Text(
              'A cute picture makes the profile feel complete.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(height: DSDimens.sizeS),
          GestureDetector(
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
                Container(
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 175,
                        height: 175,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFEFEFEF),
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
                            : Icon(
                                Icons.camera_alt,
                                size: 85,
                                color: DSColors.white,
                              ),
                      ),
                      SizedBox(height: DSDimens.sizeS),
                      Text(
                        'Tap to upload',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
