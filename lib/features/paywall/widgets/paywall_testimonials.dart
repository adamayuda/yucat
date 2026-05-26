import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/presentation/components/ds_dot_indicator.dart';

/// Success-stories carousel shown on the paywall.
// TODO: replace placeholder testimonials with real, attributed reviews.
class PaywallTestimonials extends StatefulWidget {
  const PaywallTestimonials({super.key});

  @override
  State<PaywallTestimonials> createState() => _PaywallTestimonialsState();
}

class _Testimonial {
  final String quote;
  final String name;
  final String flag;
  final String detail;
  final List<Color> avatarGradient;
  final String avatarEmoji;

  const _Testimonial({
    required this.quote,
    required this.name,
    required this.flag,
    required this.detail,
    required this.avatarGradient,
    required this.avatarEmoji,
  });
}

const _testimonials = [
  _Testimonial(
    quote:
        "I'd been guessing for years. YuCat narrowed down a senior food "
        "that's gentle on Lulu's stomach in one afternoon.",
    name: 'Sophie',
    flag: '🇬🇧',
    detail: 'Senior cat · sensitive stomach',
    avatarGradient: [Color(0xFFFFD9A6), Color(0xFFFFB773)],
    avatarEmoji: '🧑',
  ),
  _Testimonial(
    quote:
        "Scanned our kitten's kibble and finally understood what was in "
        "it. Switched brands the same week.",
    name: 'Marco',
    flag: '🇮🇹',
    detail: 'Kitten · picky eater',
    avatarGradient: [Color(0xFFC9E4FF), Color(0xFF7AB8F0)],
    avatarEmoji: '👨',
  ),
  _Testimonial(
    quote:
        'Two cats, two very different needs. Now I know which food '
        'actually fits each of them.',
    name: 'Priya',
    flag: '🇮🇳',
    detail: 'Multi-cat household',
    avatarGradient: [Color(0xFFFAD3D6), Color(0xFFE89BA3)],
    avatarEmoji: '👩',
  ),
];

class _PaywallTestimonialsState extends State<PaywallTestimonials> {
  final PageController _controller = PageController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Success stories\nfrom cat parents',
          style: DSTextStyles.headlineMd,
        ),
        const SizedBox(height: DSDimens.sizeS),
        SizedBox(
          height: 200,
          child: PageView(
            controller: _controller,
            children: [
              for (final t in _testimonials) _TestimonialCard(testimonial: t),
            ],
          ),
        ),
        const SizedBox(height: DSDimens.sizeS),
        Center(
          child: DSDotIndicator(
            controller: _controller,
            count: _testimonials.length,
          ),
        ),
      ],
    );
  }
}

class _TestimonialCard extends StatelessWidget {
  final _Testimonial testimonial;

  const _TestimonialCard({required this.testimonial});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DSDimens.sizeS),
      decoration: BoxDecoration(
        color: DSColors.surfaceCard,
        borderRadius: BorderRadius.circular(DSRadii.lg),
        border: Border.all(color: DSColors.border),
        boxShadow: DSShadows.e1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: testimonial.avatarGradient,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  testimonial.avatarEmoji,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(width: DSDimens.sizeXs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          testimonial.name,
                          style: DSTextStyles.bodyLg.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: DSDimens.sizeXxs),
                        Text(
                          testimonial.flag,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    Text(
                      testimonial.detail,
                      style: DSTextStyles.caption.copyWith(
                        color: DSColors.inkSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: DSDimens.sizeXs),
          Expanded(
            child: Text(
              testimonial.quote,
              style: DSTextStyles.bodyMd.copyWith(
                color: DSColors.inkSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
