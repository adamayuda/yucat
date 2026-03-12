import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';

class CatListingErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onPressed;

  const CatListingErrorWidget({
    super.key,
    required this.message,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/Illustrations/Error.gif',
            width: 200,
            height: 200,
          ),
          SizedBox(height: DSDimens.sizeM),
          Text(
            'Error: $message',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.red),
          ),
          SizedBox(height: DSDimens.sizeM),
          ElevatedButton(onPressed: onPressed, child: const Text('Retry')),
        ],
      ),
    );
  }
}
