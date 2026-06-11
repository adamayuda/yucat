import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/l10n/app_localizations.dart';
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
  final String avatarImage;

  _Testimonial({
    required this.quote,
    required this.name,
    required this.flag,
    required this.detail,
    required this.avatarImage,
  });
}

List<_Testimonial> _buildTestimonials(AppLocalizations l10n) => [
  _Testimonial(
    quote: l10n.paywallTestimonial1Quote,
    name: l10n.paywallTestimonial1Name,
    flag: '🇬🇧',
    detail: l10n.paywallTestimonial1Detail,
    avatarImage: 'assets/images/image.png',
  ),
  _Testimonial(
    quote: l10n.paywallTestimonial2Quote,
    name: l10n.paywallTestimonial2Name,
    flag: '🇮🇹',
    detail: l10n.paywallTestimonial2Detail,
    avatarImage: 'assets/images/image2.png',
  ),
  _Testimonial(
    quote: l10n.paywallTestimonial3Quote,
    name: l10n.paywallTestimonial3Name,
    flag: '🇮🇳',
    detail: l10n.paywallTestimonial3Detail,
    avatarImage: 'assets/images/image3.png',
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
    final l10n = AppLocalizations.of(context);
    final testimonials = _buildTestimonials(l10n);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          l10n.paywallSuccessStoriesHeading,
          textAlign: TextAlign.center,
          style: DSTextStyles.displayLg,
        ),
        const SizedBox(height: DSDimens.sizeL),
        SizedBox(
          height: 200,
          child: PageView(
            controller: _controller,
            children: [
              for (final t in testimonials)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DSDimens.sizeXs,
                  ),
                  child: _TestimonialCard(testimonial: t),
                ),
            ],
          ),
        ),
        const SizedBox(height: DSDimens.sizeS),
        Center(
          child: DSDotIndicator(
            controller: _controller,
            count: testimonials.length,
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
              ClipOval(
                child: Image.asset(
                  testimonial.avatarImage,
                  width: 40,
                  height: 40,
                  cacheWidth: 120,
                  fit: BoxFit.cover,
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
