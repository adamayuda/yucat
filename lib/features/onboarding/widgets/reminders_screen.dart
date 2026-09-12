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
/// Tapping "Done" writes the three toggles as OneSignal tags
/// (`reminder_food_change` / `reminder_better_fit` / `reminder_monthly`) and
/// then triggers the OS push-permission prompt before advancing. Delivery is
/// a OneSignal Journey keyed on those tags — the app schedules nothing locally.
/// "Set up later" advances without writing or prompting.
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

  /// Persist the toggles, prompt for push permission, then advance regardless
  /// of the user's choice so onboarding never blocks on the OS dialog.
  ///
  /// Tags are written *before* the prompt: they need the SDK initialised, not
  /// permission granted, and a user who declines today can still be reached
  /// with the right reminders if they enable notifications in Settings later.
  Future<void> _onDone() async {
    final notifications = sl<NotificationService>();
    await notifications.setReminderPreferences(
      foodChange: _selected.contains(0),
      betterFit: _selected.contains(1),
      monthly: _selected.contains(2),
    );
    await notifications.requestPermission();
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
          TextButton(
            onPressed: widget.onNext,
            child: Text(
              l10n.onboardingSetUpLater,
              style: DSTextStyles.label.copyWith(
                color: DSColors.inkSecondary,
              ),
            ),
          ),
          const SizedBox(height: DSDimens.sizeXxs),
          DSPillButton(label: l10n.commonDone, onPressed: _onDone),
        ],
      ),
      child: Stack(
        children: [
          // Scattered decorative stars around the header. Drawn behind the
          // content, so they sit in the transparent margins around the
          // headline (not under the option cards).
          const _Star(
            asset: 'star-round.svg',
            color: DSColors.starBlue,
            size: 18,
            top: 64,
            left: 2,
            rotation: -0.35,
          ),
          const _Star(
            asset: 'star-round.svg',
            color: DSColors.starCyan,
            size: 26,
            top: 52,
            right: 2,
            rotation: 0.4,
          ),
          const _Star(
            asset: 'star-round.svg',
            color: DSColors.starGrey,
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
              // Center the options + callout block in the space below the title
              // (which stays pinned at the top like the other onboarding screens).
              const Spacer(),
              for (var i = 0; i < options.length; i++) ...[
                DSOptionRow(
                  leadingAsset: options[i].asset,
                  label: options[i].label,
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
  final Color color;
  final double size;
  final double? top;
  final double? left;
  final double? right;
  final double rotation;

  const _Star({
    required this.asset,
    required this.color,
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
          child: SvgPicture.asset(
            'assets/images/$asset',
            width: size,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }
}
