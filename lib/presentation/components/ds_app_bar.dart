import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';

/// Inline page header used across tab and modal screens.
///
/// `DSAppBar.tab(title, [trailing])` — large `displayLg` title + optional
/// trailing widget. Used by tab pages (Cats, Search) where the title sits
/// inline with the page content.
///
/// `DSAppBar.modal(onBack, [title], [actions])` — leading 28px chevron-back +
/// optional `headlineMd` title + optional trailing actions. Used by modal
/// pages (Cat Detail, Product Listing, Profile, Product Detail).
class DSAppBar extends StatelessWidget {
  final Widget? leading;
  final String? title;
  final TextStyle? titleStyle;
  final List<Widget> actions;
  final EdgeInsetsGeometry padding;

  const DSAppBar._({
    this.leading,
    this.title,
    this.titleStyle,
    this.actions = const [],
    this.padding = _defaultPadding,
  });

  factory DSAppBar.tab({
    required String title,
    Widget? trailing,
  }) {
    return DSAppBar._(
      title: title,
      titleStyle: DSTextStyles.displayLg,
      actions: trailing == null ? const [] : [trailing],
      padding: const EdgeInsets.fromLTRB(
        DSDimens.sizeL,
        DSDimens.sizeS,
        DSDimens.sizeS,
        DSDimens.sizeXs,
      ),
    );
  }

  factory DSAppBar.modal({
    required VoidCallback onBack,
    String? title,
    List<Widget> actions = const [],
  }) {
    return DSAppBar._(
      leading: IconButton(
        onPressed: onBack,
        icon: const Icon(
          Icons.chevron_left,
          color: DSColors.inkPrimary,
          size: 28,
        ),
      ),
      title: title,
      titleStyle: DSTextStyles.headlineMd,
      actions: actions,
      padding: const EdgeInsets.fromLTRB(
        DSDimens.sizeXxs,
        DSDimens.sizeXxs,
        DSDimens.sizeS,
        DSDimens.sizeXs,
      ),
    );
  }

  static const _defaultPadding = EdgeInsets.fromLTRB(
    DSDimens.sizeL,
    DSDimens.sizeS,
    DSDimens.sizeS,
    DSDimens.sizeXs,
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          if (leading != null) leading!,
          if (title != null)
            Expanded(
              child: Text(
                title!,
                style: titleStyle ?? DSTextStyles.headlineMd,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            )
          else
            const Spacer(),
          for (var i = 0; i < actions.length; i++) ...[
            if (i > 0) const SizedBox(width: DSDimens.sizeXxs),
            actions[i],
          ],
        ],
      ),
    );
  }
}
