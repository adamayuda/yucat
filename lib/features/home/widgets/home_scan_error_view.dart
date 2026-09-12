import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/home/bloc/home_state.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/ds_pill_button.dart';
import 'package:yucat/presentation/components/mascot_illustration.dart';

/// The scan-failure screen, one layout per *outcome* with up to three exits.
///
/// Before Phase 2 every failure was "Product not found" plus a button that
/// reloaded Home — "that's a dog food", "the photo was blurry", "we found it
/// but no nutrition data exists online" and "we couldn't read the label" all
/// looked identical and offered nothing to do next. Now each names what
/// happened and offers the exit that fixes it: scan again, photograph the back
/// label (the rescue path — hidden when the pack isn't a cat product at all),
/// or search by name.
///
/// Built on [MascotIllustration] + [DSPillButton] directly rather than
/// `DSStateView`, which renders a single CTA.
class HomeScanErrorView extends StatelessWidget {
  final HomeErrorState state;
  final VoidCallback onScanAgain;
  final VoidCallback onScanLabel;
  final VoidCallback onSearch;

  const HomeScanErrorView({
    super.key,
    required this.state,
    required this.onScanAgain,
    required this.onScanLabel,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final copy = _copyFor(state, l10n);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: DSDimens.sizeL,
          vertical: DSDimens.sizeXl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const MascotIllustration(
              mascotAsset: 'assets/images/cat-thinking.svg',
              tint: DSColors.tintCoral,
              size: 160,
            ),
            const SizedBox(height: DSDimens.sizeS),
            Text(
              copy.headline,
              textAlign: TextAlign.center,
              style: DSTextStyles.displayLg,
            ),
            const SizedBox(height: DSDimens.sizeS),
            Text(
              copy.body,
              textAlign: TextAlign.center,
              style: DSTextStyles.bodyLg.copyWith(color: DSColors.inkSecondary),
            ),
            const SizedBox(height: DSDimens.sizeXl),
            // The rescue is the primary action whenever it applies: it is the
            // one exit that produces a result instead of another attempt.
            if (copy.offerLabel) ...[
              DSPillButton(
                label: l10n.homeErrorExitScanLabel,
                onPressed: onScanLabel,
                showChevron: false,
                leadingIcon: Icons.photo_camera_outlined,
              ),
              const SizedBox(height: DSDimens.sizeS),
              DSPillButton(
                label: l10n.homeErrorExitScanAgain,
                onPressed: onScanAgain,
                variant: DSPillButtonVariant.secondary,
                showChevron: false,
              ),
            ] else
              DSPillButton(
                label: l10n.homeErrorExitScanAgain,
                onPressed: onScanAgain,
                showChevron: false,
              ),
            const SizedBox(height: DSDimens.sizeXs),
            Center(
              child: DSTextLink(
                label: l10n.homeErrorExitSearch,
                onPressed: onSearch,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static _ErrorCopy _copyFor(HomeErrorState state, AppLocalizations l10n) {
    final name = [state.identifiedBrand, state.identifiedName]
        .where((s) => s != null && s.isNotEmpty)
        .join(' ');
    switch (state.outcome) {
      case 'not_cat_product':
        return _ErrorCopy(
          headline: l10n.homeErrorNotCatProductTitle,
          body: l10n.homeErrorNotCatProductBody,
          offerLabel: false,
        );
      case 'unreadable':
        return _ErrorCopy(
          headline: l10n.homeErrorUnreadableTitle,
          body: l10n.homeErrorUnreadableBody,
          offerLabel: true,
        );
      case 'analysis_failed':
        return _ErrorCopy(
          headline: name.isEmpty
              ? l10n.homeErrorUnreadableTitle
              : l10n.homeErrorAnalysisFailedTitle(name),
          body: l10n.homeErrorAnalysisFailedBody,
          offerLabel: true,
        );
      case 'litter_analysis_failed':
        // Litter has no analysis panel, so the label rescue does not apply.
        return _ErrorCopy(
          headline: name.isEmpty
              ? l10n.homeErrorUnreadableTitle
              : l10n.homeErrorAnalysisFailedTitle(name),
          body: l10n.homeErrorProductNotFound,
          offerLabel: false,
        );
      case 'label_unreadable':
        return _ErrorCopy(
          headline: l10n.homeErrorLabelUnreadableTitle,
          body: l10n.homeErrorLabelUnreadableBody,
          offerLabel: true,
        );
      case 'label_no_data':
        return _ErrorCopy(
          headline: l10n.homeErrorLabelNoDataTitle,
          body: l10n.homeErrorLabelNoDataBody,
          offerLabel: true,
        );
      default:
        return _ErrorCopy(
          headline: l10n.homeErrorProductNotFound,
          body: l10n.homeErrorUnreadableBody,
          offerLabel: true,
        );
    }
  }
}

class _ErrorCopy {
  final String headline;
  final String body;
  final bool offerLabel;

  const _ErrorCopy({
    required this.headline,
    required this.body,
    required this.offerLabel,
  });
}
