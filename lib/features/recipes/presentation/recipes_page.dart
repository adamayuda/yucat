import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/ds_app_bar.dart';
import 'package:yucat/presentation/components/ds_bottom_nav.dart';
import 'package:yucat/presentation/components/ds_state_view.dart';
import 'package:yucat/config/themes/theme.dart';

/// Recipes tab. Placeholder for now — the real content lands in its own plan.
@RoutePage()
class RecipesPage extends StatelessWidget {
  const RecipesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      // Transparent: the MainPage shell paints tintLavender (docs/design.md §8c).
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DSAppBar.tab(title: l10n.recipesTabTitle),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: kFloatingNavClearance),
                child: DSStateView.empty(
                  mascotAsset: 'assets/images/cat-thinking.svg',
                  tint: DSColors.tintMint,
                  headline: l10n.recipesEmptyHeadline,
                  body: l10n.recipesEmptyBody,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
