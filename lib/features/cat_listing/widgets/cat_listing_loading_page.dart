import 'package:flutter/material.dart';

class CatListingLoadingWidget extends StatelessWidget {
  const CatListingLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: CircularProgressIndicator());
  }
}
