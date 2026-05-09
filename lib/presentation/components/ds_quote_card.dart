import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';

class DSQuoteCard extends StatelessWidget {
  final String sourceTitle;
  final String body;
  final String? sourceLinkLabel;
  final VoidCallback? onSourceTap;
  final IconData icon;
  final Color iconBackground;
  final Color iconColor;

  const DSQuoteCard({
    super.key,
    required this.sourceTitle,
    required this.body,
    this.sourceLinkLabel,
    this.onSourceTap,
    this.icon = Icons.local_hospital_rounded,
    this.iconBackground = DSColors.tintCoral,
    this.iconColor = DSColors.accentDanger,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DSDimens.sizeS),
      decoration: BoxDecoration(
        color: DSColors.surfaceCard,
        borderRadius: BorderRadius.circular(DSRadii.lg),
        boxShadow: DSShadows.e1,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(DSRadii.sm),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: DSDimens.sizeXs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: DSTextStyles.bodyMd.copyWith(
                      color: DSColors.inkPrimary,
                    ),
                    children: [
                      TextSpan(
                        text: '$sourceTitle ',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      TextSpan(text: body),
                    ],
                  ),
                ),
                if (sourceLinkLabel != null) ...[
                  const SizedBox(height: DSDimens.sizeXxs),
                  GestureDetector(
                    onTap: onSourceTap,
                    child: Text(
                      sourceLinkLabel!,
                      style: DSTextStyles.bodyMd.copyWith(
                        color: DSColors.inkSecondary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
