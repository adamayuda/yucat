import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/presentation/components/ds_option_row.dart';
import 'package:yucat/presentation/components/ds_pill_button.dart';
import 'package:yucat/presentation/components/onboarding_scaffold.dart';

class _AttributionOption {
  final String key;
  final String emoji;
  final String label;

  const _AttributionOption(this.key, this.emoji, this.label);
}

const _options = [
  _AttributionOption('influencer', '⭐', 'From an influencer'),
  _AttributionOption('instagram', '📸', 'Instagram'),
  _AttributionOption('tiktok', '🎵', 'TikTok'),
  _AttributionOption('youtube', '📺', 'YouTube'),
  _AttributionOption('app_store', '🍎', 'App Store search'),
  _AttributionOption('friend', '👋', 'Friends/family'),
];

class AttributionScreen extends StatefulWidget {
  final String? initialSelection;
  final void Function(String source) onSelect;
  final VoidCallback onSkip;

  const AttributionScreen({
    super.key,
    required this.initialSelection,
    required this.onSelect,
    required this.onSkip,
  });

  @override
  State<AttributionScreen> createState() => _AttributionScreenState();
}

class _AttributionScreenState extends State<AttributionScreen> {
  String? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialSelection;
  }

  @override
  Widget build(BuildContext context) {
    final hasSelection = _selected != null;

    return OnboardingScaffold(
      background: DSColors.tintAsh,
      footer: hasSelection
          ? DSPillButton(
              label: 'Next',
              onPressed: () => widget.onSelect(_selected!),
            )
          : DSPillButton(
              label: 'Skip',
              onPressed: widget.onSkip,
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: DSDimens.sizeS),
          Text(
            'How did you\nhear about us?',
            textAlign: TextAlign.center,
            style: DSTextStyles.displayLg,
          ),
          const SizedBox(height: DSDimens.size3xl),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: _options.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: DSDimens.sizeXs),
              itemBuilder: (context, index) {
                final opt = _options[index];
                return DSOptionRow(
                  label: opt.label,
                  leadingEmoji: opt.emoji,
                  selected: _selected == opt.key,
                  onTap: () => setState(() => _selected = opt.key),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
