import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/cat/presentation/utils/cat_labels.dart';
import 'package:yucat/features/cat_listing/models/cat_model.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/cat_avatar.dart';

class CatHeroSection extends StatelessWidget {
  final CatModel cat;

  /// Tapping the avatar — the in-place photo change. Null renders the avatar
  /// inert, without the camera badge.
  final VoidCallback? onPhotoTap;

  /// Shows a progress ring over the avatar and swallows taps.
  final bool isUploadingPhoto;

  const CatHeroSection({
    super.key,
    required this.cat,
    this.onPhotoTap,
    this.isUploadingPhoto = false,
  });

  static const double _avatarSize = 132;
  static const double _badgeSize = 40;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final subtitle = _buildSubtitle(cat, l10n);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildAvatar(l10n),
        const SizedBox(height: DSDimens.sizeS),
        Text(
          cat.name,
          textAlign: TextAlign.center,
          style: DSTextStyles.displayLg,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: DSDimens.sizeXxxs),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: DSTextStyles.bodyLg.copyWith(
              color: DSColors.inkSecondary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAvatar(AppLocalizations l10n) {
    final avatar = CatAvatar(photoUrl: cat.profileImageUrl, size: _avatarSize);
    if (onPhotoTap == null) return avatar;

    // Cat photos are auto-masked in Session Replay (AutoMaskedView.image), so
    // no explicit mask is needed here.
    return Semantics(
      button: true,
      label: l10n.catDetailChangePhoto,
      child: GestureDetector(
        onTap: isUploadingPhoto ? null : onPhotoTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: _avatarSize,
          height: _avatarSize,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              avatar,
              if (isUploadingPhoto)
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: DSColors.inkPrimary.withValues(alpha: 0.35),
                    ),
                    child: const Center(
                      child: SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: DSColors.inkInverse,
                        ),
                      ),
                    ),
                  ),
                )
              else
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: _badgeSize,
                    height: _badgeSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: DSColors.accentInfo,
                      border: Border.all(
                        color: DSColors.pageBackground,
                        width: 3,
                      ),
                      boxShadow: DSShadows.e1,
                    ),
                    child: const Icon(
                      Icons.photo_camera_rounded,
                      color: DSColors.inkInverse,
                      size: 18,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String? _buildSubtitle(CatModel cat, AppLocalizations l10n) {
    final parts = <String>[];
    final ageGroup = _formatAgeGroup(cat.ageGroup, l10n);
    if (ageGroup != null) parts.add(ageGroup);
    if (cat.breed != null && cat.breed!.isNotEmpty) {
      parts.add(catFormatBreed(cat.breed!, l10n));
    }
    if (parts.isEmpty) return null;
    return parts.join(' • ');
  }

  String? _formatAgeGroup(String? ageGroup, AppLocalizations l10n) {
    if (ageGroup == null) return null;
    return switch (ageGroup.toLowerCase()) {
      'kitten' => l10n.commonAgeGroupKitten,
      'adult' => l10n.commonAgeGroupAdult,
      'senior' => l10n.commonAgeGroupSenior,
      _ => ageGroup,
    };
  }
}
