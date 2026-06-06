import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';

enum DSOptionRowAccent { success, danger }

class DSOptionRow extends StatelessWidget {
  final String label;

  /// Optional secondary line shown under [label] (e.g. an example or hint).
  final String? description;
  final String? leadingEmoji;
  final IconData? leadingIcon;
  final bool selected;
  final VoidCallback onTap;
  final bool showTrailingRadio;
  final DSOptionRowAccent accent;

  const DSOptionRow({
    super.key,
    required this.label,
    required this.onTap,
    this.description,
    this.leadingEmoji,
    this.leadingIcon,
    this.selected = false,
    this.showTrailingRadio = false,
    this.accent = DSOptionRowAccent.success,
  });

  Color get _accentColor => switch (accent) {
        DSOptionRowAccent.success => DSColors.accentSuccess,
        DSOptionRowAccent.danger => DSColors.accentDanger,
      };

  Color get _accentSoftBackground => switch (accent) {
        DSOptionRowAccent.success => DSColors.accentSuccessSoft,
        DSOptionRowAccent.danger => const Color(0xFFFCE4E1),
      };

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: DSMotion.durFast,
      curve: DSMotion.curveStandard,
      decoration: BoxDecoration(
        color: selected ? _accentSoftBackground : DSColors.surfaceCard,
        borderRadius: BorderRadius.circular(DSRadii.lg),
        border: Border.all(
          color: selected ? _accentColor : Colors.transparent,
          width: 2,
        ),
        boxShadow: selected ? null : DSShadows.e1,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(DSRadii.lg),
        child: InkWell(
          borderRadius: BorderRadius.circular(DSRadii.lg),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: DSDimens.sizeS,
              vertical: DSDimens.sizeS,
            ),
            child: Row(
              children: [
                if (leadingEmoji != null)
                  Text(leadingEmoji!, style: const TextStyle(fontSize: 22))
                else if (leadingIcon != null)
                  Icon(leadingIcon, size: 22, color: DSColors.inkPrimary),
                const SizedBox(width: DSDimens.sizeXs),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: DSTextStyles.titleMd.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (description != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          description!,
                          style: DSTextStyles.caption.copyWith(
                            color: DSColors.inkSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (selected)
                  Icon(
                    Icons.check_circle,
                    color: _accentColor,
                    size: 22,
                  )
                else if (showTrailingRadio)
                  Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFE5E3EC),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
