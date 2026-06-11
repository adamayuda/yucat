import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:yucat/config/routes/router.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/search_products/presentation/models/brand_display_model.dart';
import 'package:yucat/l10n/app_localizations.dart';

/// "Popular brands" section — a title + a horizontal strip of brand tiles.
/// Designed to sit inside a parent scroll view (see [SearchDiscoverView]); it
/// does not impose its own outer scroll or padding.
class SearchBrandStrip extends StatelessWidget {
  final List<BrandDisplayModel> brands;

  const SearchBrandStrip({super.key, required this.brands});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.searchPopularBrands,
          style: DSTextStyles.titleMd,
        ),
        const SizedBox(height: DSDimens.sizeS),
        SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: brands.length,
            separatorBuilder: (_, __) => const SizedBox(width: DSDimens.sizeXs),
            itemBuilder: (context, index) {
              final brand = brands[index];
              return _BrandTile(brand: brand);
            },
          ),
        ),
      ],
    );
  }
}

class _BrandTile extends StatelessWidget {
  final BrandDisplayModel brand;

  const _BrandTile({required this.brand});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.router.push(
        ProductListingRoute(brandName: brand.name),
      ),
      child: Container(
        width: 96,
        height: 96,
        decoration: BoxDecoration(
          color: DSColors.surfaceCard,
          borderRadius: BorderRadius.circular(DSRadii.lg),
          boxShadow: DSShadows.e1,
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.network(
          brand.image,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: DSColors.tintLavender,
            alignment: Alignment.center,
            child: Text(
              brand.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: DSTextStyles.caption,
            ),
          ),
        ),
      ),
    );
  }
}
