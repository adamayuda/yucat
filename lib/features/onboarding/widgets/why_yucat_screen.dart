import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/presentation/components/ds_pill_button.dart';
import 'package:yucat/presentation/components/onboarding_scaffold.dart';

class _WhyCard {
  final String title;
  final IconData icon;
  final Color background;
  final Color iconColor;
  final double rotation;

  const _WhyCard({
    required this.title,
    required this.icon,
    required this.background,
    required this.iconColor,
    required this.rotation,
  });
}

const _cards = [
  _WhyCard(
    title: 'Scan any cat food bag',
    icon: Icons.camera_alt_rounded,
    background: DSColors.tintSky,
    iconColor: DSColors.accentInfo,
    rotation: -0.06,
  ),
  _WhyCard(
    title: 'Verdict tailored to your cat',
    icon: Icons.check_circle_rounded,
    background: DSColors.inkPrimary,
    iconColor: DSColors.accentSuccess,
    rotation: 0.05,
  ),
  _WhyCard(
    title: 'Track what works for your cat',
    icon: Icons.favorite_rounded,
    background: DSColors.tintCoral,
    iconColor: DSColors.accentDanger,
    rotation: -0.03,
  ),
];

class WhyYucatScreen extends StatelessWidget {
  final VoidCallback onNext;

  const WhyYucatScreen({
    super.key,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      background: DSColors.tintSky,
      footer: DSPillButton(label: 'Let\'s go', onPressed: onNext),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: DSDimens.sizeS),
          Text(
            "Why YuCat's\nunique approach\nworks",
            textAlign: TextAlign.center,
            style: DSTextStyles.displayLg,
          ),
          const SizedBox(height: DSDimens.size3xl),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(
                vertical: DSDimens.sizeS,
              ),
              itemCount: _cards.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: DSDimens.sizeS),
              itemBuilder: (context, index) {
                final card = _cards[index];
                return Transform.rotate(
                  angle: card.rotation,
                  child: _WhyCardView(card: card),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _WhyCardView extends StatelessWidget {
  final _WhyCard card;

  const _WhyCardView({required this.card});

  @override
  Widget build(BuildContext context) {
    final isDark = card.background == DSColors.inkPrimary;
    return Container(
      padding: const EdgeInsets.all(DSDimens.sizeL),
      decoration: BoxDecoration(
        color: card.background,
        borderRadius: BorderRadius.circular(DSRadii.xl),
        boxShadow: DSShadows.e2,
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: DSColors.surfaceCard,
              borderRadius: BorderRadius.circular(DSRadii.md),
            ),
            child: Icon(card.icon, color: card.iconColor, size: 28),
          ),
          const SizedBox(width: DSDimens.sizeS),
          Expanded(
            child: Text(
              card.title,
              style: DSTextStyles.headlineMd.copyWith(
                color: isDark ? DSColors.inkInverse : DSColors.inkPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
