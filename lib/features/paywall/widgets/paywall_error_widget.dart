import 'package:flutter/material.dart';

class PaywallErrorWidget extends StatelessWidget {
  const PaywallErrorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/Illustrations/Error.gif',
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 16),
            const Text('Error'),
          ],
        ),
      ),
    );
  }
}
