import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/cat/domain/entities/cat_entity.dart';
import 'package:yucat/l10n/app_localizations.dart';

/// How many of the cat's wizard-collected attributes are filled in, out of the
/// total tracked. A richer profile yields better per-cat recommendations, so we
/// surface this as a nudge on Home (see [CatProfileCompletionCard]).
///
/// Tracks the eight optional attributes the create wizard collects whose
/// "answered" state survives the round-trip to Firestore. `name` is excluded
/// (always present). `healthConditions` is intentionally excluded: the document
/// mapper only persists it when non-empty, so "answered: none" is stored
/// identically to "skipped" — counting it would cap a genuinely-healthy cat
/// below 100% and the card would never dismiss.
class CatProfileCompletion {
  final int filled;
  final int total;

  const CatProfileCompletion(this.filled, this.total);

  bool get isComplete => filled >= total;
  double get fraction => total == 0 ? 1 : filled / total;
}

CatProfileCompletion catProfileCompletion(CatEntity cat) {
  bool has(String? v) => v != null && v.trim().isNotEmpty;

  final fields = <bool>[
    has(cat.gender),
    has(cat.profileImageUrl),
    cat.age != null,
    has(cat.weightCategory),
    has(cat.activityLevel),
    has(cat.neuteredStatus),
    has(cat.coatType),
    has(cat.breed),
  ];

  final filled = fields.where((f) => f).length;
  return CatProfileCompletion(filled, fields.length);
}

/// Home nudge to finish an incomplete cat profile. A single tappable surface
/// (mirroring the scan hero card — no separate button) that opens the edit
/// wizard. Callers should only mount this when the profile is incomplete
/// (`!catProfileCompletion(cat).isComplete`).
class CatProfileCompletionCard extends StatelessWidget {
  final CatEntity cat;
  final VoidCallback onComplete;

  const CatProfileCompletionCard({
    super.key,
    required this.cat,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final completion = catProfileCompletion(cat);
    final shape = BorderRadius.circular(DSRadii.xl);

    return Container(
      decoration: BoxDecoration(
        gradient: DSGradients.homeProfileCard,
        borderRadius: shape,
        boxShadow: DSShadows.e2,
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onComplete,
          child: Padding(
            padding: const EdgeInsets.all(DSDimens.sizeL),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _ProgressRing(completion: completion),
                const SizedBox(width: DSDimens.sizeM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.homeProfileCompletionTitle(cat.name),
                        style: DSTextStyles.headlineMd,
                      ),
                      const SizedBox(height: DSDimens.sizeXxxs),
                      Text(
                        l10n.homeProfileCompletionBody,
                        style: DSTextStyles.bodyMd.copyWith(
                          color: DSColors.inkPrimary.withValues(alpha: 0.72),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: DSDimens.sizeXs),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: DSColors.inkSecondary,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Circular completeness indicator with the "filled/total" count in the centre.
class _ProgressRing extends StatelessWidget {
  final CatProfileCompletion completion;

  const _ProgressRing({required this.completion});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: const BoxDecoration(
        color: DSColors.surfaceCard,
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: CircularProgressIndicator(
              value: completion.fraction,
              strokeWidth: 5,
              strokeCap: StrokeCap.round,
              backgroundColor: DSColors.tintMint,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(DSColors.accentSuccess),
            ),
          ),
          Text(
            '${completion.filled}/${completion.total}',
            style: DSTextStyles.caption.copyWith(
              fontWeight: FontWeight.w800,
              color: DSColors.inkPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
