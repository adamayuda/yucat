import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/presentation/components/ds_pill_button.dart';
import 'package:yucat/presentation/components/onboarding_scaffold.dart';

class ProfilePhotoScreen extends StatefulWidget {
  final String? photoPath;
  final void Function(String? path) onPhotoSelected;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const ProfilePhotoScreen({
    super.key,
    required this.photoPath,
    required this.onPhotoSelected,
    required this.onNext,
    required this.onSkip,
  });

  @override
  State<ProfilePhotoScreen> createState() => _ProfilePhotoScreenState();
}

class _ProfilePhotoScreenState extends State<ProfilePhotoScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pick() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      widget.onPhotoSelected(picked.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasPhoto = widget.photoPath != null;

    return OnboardingScaffold(
      background: DSColors.tintAsh,
      footer: hasPhoto
          ? DSPillButton(label: 'Next', onPressed: widget.onNext)
          : DSPillButton(
              label: 'Skip',
              onPressed: widget.onSkip,
              variant: DSPillButtonVariant.secondary,
              showChevron: false,
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: DSDimens.sizeS),
          Text(
            'Add a photo\nof your cat',
            textAlign: TextAlign.center,
            style: DSTextStyles.displayHero,
          ),
          const Spacer(flex: 1),
          GestureDetector(
            onTap: _pick,
            child: hasPhoto
                ? _filledFrame(widget.photoPath!)
                : _emptyFrame(),
          ),
          const SizedBox(height: DSDimens.sizeL),
          if (hasPhoto)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DSDimens.sizeS,
                vertical: DSDimens.sizeXxs,
              ),
              decoration: BoxDecoration(
                color: DSColors.accentSuccess,
                borderRadius: BorderRadius.circular(DSRadii.pill),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check, color: Colors.white, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'Photo added',
                    style: DSTextStyles.label.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            )
          else
            Text(
              'Optional — you can do this later',
              style: DSTextStyles.caption,
            ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }

  Widget _emptyFrame() {
    return Container(
      width: 170,
      height: 170,
      decoration: BoxDecoration(
        color: DSColors.surfaceCardDim,
        borderRadius: BorderRadius.circular(DSRadii.xl),
        border: Border.all(
          color: DSColors.inkTertiary,
          width: 2.5,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📷', style: TextStyle(fontSize: 42)),
          const SizedBox(height: DSDimens.sizeXxs),
          Text('Tap to add', style: DSTextStyles.caption),
        ],
      ),
    );
  }

  Widget _filledFrame(String path) {
    return Container(
      width: 170,
      height: 170,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DSRadii.xl),
        image: DecorationImage(
          image: FileImage(File(path)),
          fit: BoxFit.cover,
        ),
        boxShadow: DSShadows.e3,
      ),
    );
  }
}
