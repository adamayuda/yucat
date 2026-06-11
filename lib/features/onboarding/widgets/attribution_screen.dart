import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/ds_option_row.dart';
import 'package:yucat/presentation/components/onboarding_floating_button.dart';
import 'package:yucat/presentation/components/onboarding_scaffold.dart';

class _AttributionOption {
  final String key;
  final String asset;
  final String label;

  const _AttributionOption(this.key, this.asset, this.label);
}

List<_AttributionOption> _buildOptions(AppLocalizations l10n) => [
  _AttributionOption('instagram', 'assets/images/camera.svg', l10n.onboardingAttributionInstagram),
  _AttributionOption('tiktok', 'assets/images/Hand-2.svg', l10n.onboardingAttributionTikTok),
  _AttributionOption('youtube', 'assets/images/TV.svg', l10n.onboardingAttributionYouTube),
  _AttributionOption('app_store', 'assets/images/apple.svg', l10n.onboardingAttributionAppStore),
  _AttributionOption('friend', 'assets/images/Hand.svg', l10n.onboardingAttributionFriends),
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
    final l10n = AppLocalizations.of(context);
    final options = _buildOptions(l10n);
    final hasSelection = _selected != null;

    return OnboardingScaffold(
      background: DSColors.tintCloud,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: DSDimens.sizeS),
          Text(
            l10n.onboardingAttributionTitle,
            textAlign: TextAlign.center,
            style: DSTextStyles.displayLg,
          ),
          const SizedBox(height: DSDimens.size3xl),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: options.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: DSDimens.sizeXs),
              itemBuilder: (context, index) {
                final opt = options[index];
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
            label: hasSelection ? l10n.commonNext : l10n.commonSkip,
            onPressed: hasSelection
                ? () => widget.onSelect(_selected!)
                : widget.onSkip,
          ),
        ],
      ),
    );
  }
}
