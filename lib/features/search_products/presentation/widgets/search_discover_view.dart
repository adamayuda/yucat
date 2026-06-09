import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/search_products/presentation/models/brand_display_model.dart';
import 'package:yucat/features/search_products/presentation/widgets/search_brand_strip.dart';
import 'package:yucat/presentation/components/ds_pill_button.dart';

/// The Search tab's pre-query state: recent searches (when any) above the
/// popular-brands strip.
class SearchDiscoverView extends StatelessWidget {
  final List<String> recentSearches;
  final List<BrandDisplayModel> brands;
  final ValueChanged<String> onRecentTap;
  final VoidCallback onClearRecents;

  const SearchDiscoverView({
    super.key,
    required this.recentSearches,
    required this.brands,
    required this.onRecentTap,
    required this.onClearRecents,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom + 96;
    return ListView(
      padding: EdgeInsets.fromLTRB(
        DSDimens.sizeL,
        DSDimens.sizeS,
        DSDimens.sizeL,
        bottomInset,
      ),
      children: [
        if (recentSearches.isNotEmpty) ...[
          Row(
            children: [
              Expanded(child: Text('Recent', style: DSTextStyles.titleMd)),
              DSTextLink(label: 'Clear', onPressed: onClearRecents),
            ],
          ),
          const SizedBox(height: DSDimens.sizeXxs),
          Wrap(
            spacing: DSDimens.sizeXs,
            runSpacing: DSDimens.sizeXs,
            children: [
              for (final query in recentSearches)
                _RecentChip(query: query, onTap: () => onRecentTap(query)),
            ],
          ),
          const SizedBox(height: DSDimens.sizeL),
        ],
        SearchBrandStrip(brands: brands),
      ],
    );
  }
}

class _RecentChip extends StatelessWidget {
  final String query;
  final VoidCallback onTap;

  const _RecentChip({required this.query, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: DSColors.surfaceCard,
      borderRadius: BorderRadius.circular(DSRadii.pill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DSRadii.pill),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: DSDimens.sizeS,
            vertical: DSDimens.sizeXs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.history_rounded,
                size: 16,
                color: DSColors.inkSecondary,
              ),
              const SizedBox(width: DSDimens.sizeXxs),
              Text(
                query,
                style: DSTextStyles.label.copyWith(color: DSColors.inkPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
