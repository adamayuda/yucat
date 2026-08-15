import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/cat/domain/entities/cat_entity.dart';
import 'package:yucat/features/litter_detail/presentation/models/litter_display_model.dart';
import 'package:yucat/features/litter_detail/presentation/utils/cat_litter_safety.dart';
import 'package:yucat/features/litter_detail/presentation/utils/litter_flag_copy.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/cat_avatar.dart';
import 'package:yucat/presentation/components/ds_card.dart';
import 'package:yucat/presentation/components/ds_pill_button.dart';

/// Per-cat litter notes for every cat at once.
///
/// Deliberately not a selector like `CatAssessmentSection`: there is no per-cat
/// *score* to switch between, only a short list of safety notes, and a
/// multi-cat household most wants to see them side by side — the kitten's
/// warning matters even while you're reading the senior's.
class LitterCatNotesCard extends StatelessWidget {
  final List<CatEntity> cats;
  final LitterDisplayModel litter;
  final VoidCallback onCreateCat;

  const LitterCatNotesCard({
    super.key,
    required this.cats,
    required this.litter,
    required this.onCreateCat,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (cats.isEmpty) {
      return DSCard(
        padding: const EdgeInsets.all(DSDimens.sizeL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.productDetailForYourCats, style: DSTextStyles.titleMd),
            const SizedBox(height: DSDimens.sizeXxs),
            Text(l10n.litterDetailNoCatPrompt, style: DSTextStyles.bodyMd),
            const SizedBox(height: DSDimens.sizeS),
            DSPillButton(
              label: l10n.productDetailAddACat,
              onPressed: onCreateCat,
            ),
          ],
        ),
      );
    }

    return DSCard(
      padding: const EdgeInsets.all(DSDimens.sizeL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.productDetailForYourCats, style: DSTextStyles.titleMd),
          for (final cat in cats) ...[
            const SizedBox(height: DSDimens.sizeS),
            _CatNotes(cat: cat, litter: litter),
          ],
        ],
      ),
    );
  }
}

class _CatNotes extends StatelessWidget {
  final CatEntity cat;
  final LitterDisplayModel litter;

  const _CatNotes({required this.cat, required this.litter});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final flags = litterFlagsForCat(cat, litter);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CatAvatar(
              photoUrl: cat.profileImageUrl,
              size: 24,
              background: DSColors.tintLavender,
            ),
            const SizedBox(width: DSDimens.sizeXxs),
            Text(
              cat.name,
              style: DSTextStyles.label.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        if (flags.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: DSDimens.sizeXxs),
            child: Text(
              l10n.litterDetailNoFlags(cat.name),
              style: DSTextStyles.bodyMd.copyWith(
                color: DSColors.inkSecondary,
              ),
            ),
          )
        else
          for (final flag in flags)
            _FlagRow(
              severity: flag.severity,
              text: litterFlagText(flag.code, cat.name, l10n),
            ),
      ],
    );
  }
}

class _FlagRow extends StatelessWidget {
  final LitterFlagSeverity severity;
  final String text;

  const _FlagRow({required this.severity, required this.text});

  @override
  Widget build(BuildContext context) {
    final (background, foreground, icon) = switch (severity) {
      LitterFlagSeverity.warning => (
          const Color(0xFFFFE2E2),
          DSColors.accentDanger,
          Icons.priority_high_rounded,
        ),
      LitterFlagSeverity.caution => (
          const Color(0xFFFFF3D6),
          const Color(0xFFB37800),
          Icons.warning_amber_rounded,
        ),
      LitterFlagSeverity.good => (
          DSColors.accentSuccessSoft,
          DSColors.accentSuccess,
          Icons.check_rounded,
        ),
    };

    return Padding(
      padding: const EdgeInsets.only(top: DSDimens.sizeXxs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: background,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: foreground, size: 13),
          ),
          const SizedBox(width: DSDimens.sizeXs),
          Expanded(
            child: Text(
              text,
              style: DSTextStyles.bodyMd.copyWith(color: DSColors.inkPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
