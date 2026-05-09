import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/presentation/components/ds_state_view.dart';

class PaywallErrorWidget extends StatelessWidget {
  final String message;

  const PaywallErrorWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: DSColors.tintMint,
      child: SafeArea(
        child: DSStateView.error(
          body: message,
          ctaLabel: 'Close',
          onCtaPressed: () => Navigator.of(context).pop(false),
        ),
      ),
    );
  }
}
