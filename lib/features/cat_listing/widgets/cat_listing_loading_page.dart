import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/presentation/components/skeletons/product_list_skeleton.dart';

class CatListingLoadingWidget extends StatelessWidget {
  const CatListingLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return ProductListSkeleton(
      circularThumb: true,
      itemCount: 4,
      padding: EdgeInsets.fromLTRB(
        DSDimens.sizeL,
        DSDimens.sizeS,
        DSDimens.sizeL,
        bottomInset + DSDimens.size5xl + DSDimens.sizeL,
      ),
    );
  }
}
