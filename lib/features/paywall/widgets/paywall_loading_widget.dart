import 'package:flutter/material.dart';

class PaywallLoadingWidget extends StatelessWidget {
  const PaywallLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
