import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:yucat/config/routes/router.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/presentation/top_app_bar/top_app_bar.dart';
import 'package:yucat/features/search_products/presentation/models/brand_display_model.dart';

class SearchDiscoverLoadedPage extends StatelessWidget {
  final List<BrandDisplayModel> brands;

  const SearchDiscoverLoadedPage({super.key, required this.brands});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: DSDimens.sizeS),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Popular brands',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        SizedBox(height: DSDimens.sizeXxs),
        SizedBox(
          height: 100,
          child: ListView.separated(
            itemCount: brands.length,
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: DSDimens.sizeS),
            separatorBuilder: (context, index) =>
                SizedBox(width: DSDimens.sizeXxs),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  context.router.push(
                    ProductListingRoute(brandName: brands[index].name),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(DSDimens.sizeS),
                    color: DSColors.white,
                    border: Border.all(color: DSColors.lightGrey),
                  ),
                  width: 100,
                  height: 100,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(DSDimens.sizeS),
                    child: Image.network(
                      brands[index].image,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
