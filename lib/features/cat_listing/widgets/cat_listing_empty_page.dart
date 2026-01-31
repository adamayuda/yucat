import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/cat_listing/bloc/cat_listing_bloc.dart';

class CatListingEmptyWidget extends StatelessWidget {
  final VoidCallback onPressed;

  const CatListingEmptyWidget({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/Empty.png',
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                ),
                Text(
                  'Your cat doesn’t have a profile yet.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: DSColors.darkGrey),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Create one to get started!',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: DSColors.darkGrey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(DSDimens.sizeL),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: DSColors.primary,
                foregroundColor: DSColors.white,
                disabledBackgroundColor: const Color(0xFFEDAFDD),
                disabledForegroundColor: DSColors.white,
                // padding: EdgeInsets.symmetric(
                //   vertical: DSDimens.sizeM,
                // ),
                padding: const EdgeInsets.symmetric(vertical: DSDimens.sizeS),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DSDimens.sizeXxs),
                ),
              ),
              child: Text(
                'Add a new cat profile!',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
