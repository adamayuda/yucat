import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';

class OnboardingScaffold extends StatelessWidget {
  final Color background;
  final Gradient? gradient;
  final Widget child;
  final Widget? footer;
  final Widget? topRightAction;

  const OnboardingScaffold({
    super.key,
    required this.child,
    this.background = DSColors.tintAsh,
    this.gradient,
    this.footer,
    this.topRightAction,
  });

  @override
  Widget build(BuildContext context) {
    final body = SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: DSDimens.sizeL),
        child: Column(
          children: [
            SizedBox(
              height: 48,
              child: Row(
                children: [
                  const Spacer(),
                  if (topRightAction != null) topRightAction!,
                ],
              ),
            ),
            Expanded(child: child),
            if (footer != null)
              Padding(
                padding: const EdgeInsets.only(
                  top: DSDimens.sizeS,
                  bottom: DSDimens.sizeS,
                ),
                child: footer,
              ),
          ],
        ),
      ),
    );

    if (gradient != null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: DecoratedBox(
          decoration: BoxDecoration(gradient: gradient),
          child: body,
        ),
      );
    }

    return Scaffold(backgroundColor: background, body: body);
  }
}

class BackChip extends StatelessWidget {
  final VoidCallback onTap;

  const BackChip({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: DSColors.surfaceCardDim,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            Icons.chevron_left,
            color: DSColors.inkPrimary,
            size: 24,
          ),
        ),
      ),
    );
  }
}
