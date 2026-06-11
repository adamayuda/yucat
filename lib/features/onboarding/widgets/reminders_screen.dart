import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/ds_option_row.dart';
import 'package:yucat/presentation/components/ds_pill_button.dart';
import 'package:yucat/presentation/components/onboarding_scaffold.dart';
import 'package:yucat/service_locator.dart';
import 'package:yucat/services/notification_service.dart';

/// Reminder-preferences screen.
///
/// The reminder-type selections are presentational only (not persisted). Tapping
/// "Done" triggers the OS push-permission prompt via OneSignal before advancing;
/// "Set up later" advances without prompting.
// TODO(feature): persist reminder-type preferences for segmentation.
class RemindersScreen extends StatefulWidget {
  final VoidCallback onNext;

  const RemindersScreen({
    super.key,
    required this.onNext,
  });

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _ReminderOption {
  final String asset;
  final String label;

  const _ReminderOption(this.asset, this.label);
}

List<_ReminderOption> _buildReminderOptions(AppLocalizations l10n) => [
  _ReminderOption('assets/images/girl-1.svg', l10n.onboardingRemindersOptionFoodChange),
  _ReminderOption('assets/images/Magic.svg', l10n.onboardingRemindersOptionBetterFit),
  _ReminderOption('assets/images/Calendar.svg', l10n.onboardingRemindersOptionMonthly),
];

class _RemindersScreenState extends State<RemindersScreen> {
  final Set<int> _selected = {};

  /// Prompt for push permission, then advance regardless of the user's choice
  /// so onboarding never blocks on the OS dialog.
  Future<void> _onDone() async {
    await sl<NotificationService>().requestPermission();
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final options = _buildReminderOptions(l10n);
    return OnboardingScaffold(
      gradient: DSGradients.onboardingReminders,
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DSPillButton(label: l10n.commonDone, onPressed: _onDone),
          const SizedBox(height: DSDimens.sizeXxs),
          TextButton(
            onPressed: widget.onNext,
            child: Text(
              l10n.onboardingSetUpLater,
              style: DSTextStyles.label.copyWith(
                color: DSColors.inkSecondary,
              ),
            ),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Scattered decorative stars around the header. Drawn behind the
          // content, so they sit in the transparent margins around the
          // headline (not under the option cards).
          const _Star(
            asset: 'start-blue.svg',
            size: 18,
            top: 64,
            left: 2,
            rotation: -0.35,
          ),
          const _Star(
            asset: 'star-green.svg',
            size: 26,
            top: 52,
            right: 2,
            rotation: 0.4,
          ),
          const _Star(
            asset: 'star-grey.svg',
            size: 14,
            top: 4,
            right: 44,
            rotation: 0.25,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: DSDimens.sizeS),
              Text(
                l10n.onboardingRemindersTitle,
                textAlign: TextAlign.center,
                style: DSTextStyles.displayLg,
              ),
              const SizedBox(height: DSDimens.size3xl),
              for (var i = 0; i < options.length; i++) ...[
                DSOptionRow(
                  leadingAsset: options[i].asset,
                  label: options[i].label,
                  showTrailingRadio: true,
                  trailingSize: 18,
                  selected: _selected.contains(i),
                  onTap: () => setState(() {
                    if (!_selected.add(i)) _selected.remove(i);
                  }),
                ),
                if (i != options.length - 1)
                  const SizedBox(height: DSDimens.sizeXxs),
              ],
              const SizedBox(height: DSDimens.sizeL),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(DSDimens.sizeS),
                decoration: BoxDecoration(
                  color: DSColors.tintSandSoft,
                  borderRadius: BorderRadius.circular(DSRadii.lg),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('💡', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: DSDimens.sizeXs),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          style: DSTextStyles.bodyMd.copyWith(
                            color: DSColors.inkSecondary,
                          ),
                          children: [
                            TextSpan(
                              text: l10n.onboardingRemindersCalloutPart1,
                            ),
                            TextSpan(
                              text: l10n.onboardingRemindersCalloutBold,
                              style: const TextStyle(
                                color: DSColors.inkPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
            ],
          ),
        ],
      ),
    );
  }
}

/// Decorative star pinned to the header area (fixed, behind the content).
class _Star extends StatelessWidget {
  final String asset;
  final double size;
  final double? top;
  final double? left;
  final double? right;
  final double rotation;

  const _Star({
    required this.asset,
    required this.size,
    this.top,
    this.left,
    this.right,
    this.rotation = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      child: ExcludeSemantics(
        child: Transform.rotate(
          angle: rotation,
          child: SvgPicture.asset('assets/images/$asset', width: size),
        ),
      ),
    );
  }
}
