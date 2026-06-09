import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/presentation/components/ds_option_row.dart';
import 'package:yucat/presentation/components/onboarding_floating_button.dart';
import 'package:yucat/presentation/components/onboarding_scaffold.dart';

class _AttributionOption {
  final String key;
  final String asset;
  final String label;

  const _AttributionOption(this.key, this.asset, this.label);
}

const _options = [
  _AttributionOption('instagram', 'assets/images/camera.svg', 'Instagram'),
  _AttributionOption('tiktok', 'assets/images/Hand-2.svg', 'TikTok'),
  _AttributionOption('youtube', 'assets/images/TV.svg', 'YouTube'),
  _AttributionOption('app_store', 'assets/images/apple.svg', 'App Store search'),
  _AttributionOption('friend', 'assets/images/Hand.svg', 'Friends/family'),
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
      background: DSColors.tintCloud,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: DSDimens.sizeS),
          Text(
            'How did you hear\nabout us?',
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
                  leadingAsset: opt.asset,
                  selected: _selected == opt.key,
                  onTap: () => setState(() => _selected = opt.key),
                );
              },
            ),
          ),
          OnboardingFloatingButton(
            label: hasSelection ? 'Next' : 'Skip',
            onPressed: hasSelection
                ? () => widget.onSelect(_selected!)
                : widget.onSkip,
          ),
        ],
      ),
    );
  }
}
