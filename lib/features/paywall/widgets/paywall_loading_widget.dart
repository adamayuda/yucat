import 'package:flutter/material.dart';
import 'package:yucat/presentation/widgets/app_loading_widget.dart';

class PaywallLoadingWidget extends StatelessWidget {
  const PaywallLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: AppLoadingWidget(),
    );
  }
}
