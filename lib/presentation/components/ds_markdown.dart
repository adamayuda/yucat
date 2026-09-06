import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yucat/config/themes/theme.dart';

/// Renders one Markdown block of authored content with design-system typography.
///
/// Used for `ArticleEntity.body` items. Each item is a **block** — a paragraph,
/// a heading, a list — rendered on its own, with the spacing between blocks
/// staying layout rather than whitespace a translator could disturb.
///
/// ⚠️ Deliberately **not** used on cards or list rows. `MarkdownBody` has no
/// `maxLines` or `TextOverflow.ellipsis`, and every card surface in the app
/// depends on them (`home_news_card.dart` clips the excerpt at 3 lines,
/// `article_list_row.dart` the title at 2). Article `title` and `excerpt` stay
/// plain strings for that reason.
class DSMarkdownBlock extends StatelessWidget {
  final String data;

  /// Overrides the paragraph style. Defaults to the article body's
  /// `bodyLg + inkSecondary + height 1.55`.
  final TextStyle? paragraphStyle;

  const DSMarkdownBlock({super.key, required this.data, this.paragraphStyle});

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
      data: data,
      styleSheet: _styleSheet(paragraphStyle ?? _defaultParagraph),
      onTapLink: (text, href, title) => _openLink(href),
      checkboxBuilder: _checkbox,
      imageBuilder: _image,
    );
  }

  static TextStyle get _defaultParagraph => DSTextStyles.bodyLg.copyWith(
        color: DSColors.inkSecondary,
        height: 1.55,
      );

  /// ⚠️ Headings pass `DSTextStyles.headlineMd` / `titleMd` through unchanged
  /// rather than deriving them with `copyWith(fontWeight:)`.
  ///
  /// `DSTextStyles.title()` gets its weight from **`fontVariations`** on the
  /// bundled Bricolage Grotesque variable font, not from `fontWeight`. Setting
  /// `fontWeight` here would do nothing, and rebuilding the style by hand would
  /// silently drop the variations and render headings at normal weight.
  static MarkdownStyleSheet _styleSheet(TextStyle paragraph) {
    return MarkdownStyleSheet(
      p: paragraph,
      // Blocks are spaced by the caller's layout, so the sheet adds none of its
      // own — otherwise every block would carry a double gap.
      blockSpacing: 0,
      pPadding: EdgeInsets.zero,
      h1: DSTextStyles.displayLg,
      h2: DSTextStyles.headlineMd,
      h3: DSTextStyles.titleMd,
      h4: DSTextStyles.titleMd,
      h5: DSTextStyles.titleMd,
      h6: DSTextStyles.titleMd,
      h1Padding: EdgeInsets.zero,
      h2Padding: EdgeInsets.zero,
      h3Padding: EdgeInsets.zero,
      strong: paragraph.copyWith(
        fontWeight: FontWeight.w700,
        color: DSColors.inkPrimary,
      ),
      em: paragraph.copyWith(fontStyle: FontStyle.italic),
      a: paragraph.copyWith(
        color: DSColors.accentInfo,
        decoration: TextDecoration.underline,
        decorationColor: DSColors.accentInfo,
      ),
      listBullet: paragraph,
      listIndent: DSDimens.sizeM,
      blockquote: paragraph,
      blockquotePadding: const EdgeInsets.all(DSDimens.sizeS),
      blockquoteDecoration: BoxDecoration(
        color: DSColors.surfaceCardDim,
        borderRadius: BorderRadius.circular(DSRadii.md),
      ),
      code: DSTextStyles.bodyMd.copyWith(
        fontFamily: 'monospace',
        backgroundColor: DSColors.surfaceCardDim,
      ),
      codeblockPadding: const EdgeInsets.all(DSDimens.sizeS),
      codeblockDecoration: BoxDecoration(
        color: DSColors.surfaceCardDim,
        borderRadius: BorderRadius.circular(DSRadii.md),
      ),
      horizontalRuleDecoration: const BoxDecoration(
        border: Border(top: BorderSide(color: DSColors.tintGreySoft)),
      ),
      // Authored articles and recipes lean on tables for real data — treat
      // allowances by cat weight, label terms and their meanings — so they get
      // full borders rather than the app's usual row dividers: a two-axis
      // lookup needs its columns delimited to be readable.
      //
      // `tableColumnWidth` is deliberately left at the default `FlexColumnWidth`
      // so cells wrap and the table fits the phone. `IntrinsicColumnWidth` reads
      // better for short label/value pairs but makes a table with prose cells
      // very wide, and the package then hands it a horizontal scroll — worse on
      // a phone than wrapping.
      tableHead: DSTextStyles.label,
      tableBody: DSTextStyles.bodyMd,
      tableBorder: TableBorder.all(
        color: DSColors.tintGreySoft,
        borderRadius: BorderRadius.circular(DSRadii.sm),
      ),
      tableCellsPadding: const EdgeInsets.symmetric(
        horizontal: DSDimens.sizeXxs,
        vertical: DSDimens.sizeXxs,
      ),
      tableHeadCellsPadding: const EdgeInsets.symmetric(
        horizontal: DSDimens.sizeXxs,
        vertical: DSDimens.sizeXxs,
      ),
    );
  }

  /// GFM task-list checkbox (`- [ ]` / `- [x]`).
  ///
  /// Authored content uses these as a read-along checklist — the article's
  /// "weekly two-minute check" — so they are **display only**. There is nowhere
  /// to persist a tick, and a control that forgets what you tapped is worse
  /// than a plain glyph.
  static Widget _checkbox(bool value) => Padding(
        padding: const EdgeInsets.only(right: DSDimens.sizeXxs),
        child: Icon(
          value ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
          size: 18,
          color: value ? DSColors.accentSuccess : DSColors.inkTertiary,
        ),
      );

  /// Inline article/recipe image.
  ///
  /// The default builder is a bare `Image.network`, which shows a hard error
  /// glyph the moment a URL rots — and authored copy references remote photos.
  /// This one reserves space while loading and **collapses to nothing** on
  /// failure, so a dead image costs a photo rather than a broken-looking screen.
  static Widget _image(Uri uri, String? title, String? alt) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DSDimens.sizeXxs),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(DSRadii.md),
        child: Image.network(
          uri.toString(),
          width: double.infinity,
          fit: BoxFit.cover,
          semanticLabel: alt,
          loadingBuilder: (context, child, progress) => progress == null
              ? child
              : Container(
                  height: 180,
                  color: DSColors.surfaceCardDim,
                ),
          errorBuilder: (context, error, stack) => const SizedBox.shrink(),
        ),
      ),
    );
  }

  /// Opens a tapped link externally, following the same guarded-`launchUrl`
  /// idiom as `welcome_screen.dart`. Silent on failure — a dead link in seeded
  /// copy should not throw at a reader.
  static Future<void> _openLink(String? href) async {
    if (href == null || href.isEmpty) return;
    final uri = Uri.tryParse(href);
    if (uri == null) return;
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      // Ignored: nothing useful to tell the reader, and no flow depends on it.
    }
  }
}
