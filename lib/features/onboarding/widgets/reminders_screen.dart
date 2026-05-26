import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/presentation/components/ds_option_row.dart';
import 'package:yucat/presentation/components/ds_pill_button.dart';
import 'package:yucat/presentation/components/onboarding_scaffold.dart';

/// Reminder-preferences screen.
///
/// MOCK ONLY — selections are tracked in local state for the screen's
/// feel but are not persisted or used to schedule any notification.
// TODO(feature): persist reminder preferences + schedule push notifications.
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
  final String emoji;
  final String label;

  const _ReminderOption(this.emoji, this.label);
}

const _options = [
  _ReminderOption('🔄', 'When a saved food changes'),
  _ReminderOption('✨', 'When a better fit is found'),
  _ReminderOption('📅', 'Monthly check-in'),
];

class _RemindersScreenState extends State<RemindersScreen> {
  final Set<int> _selected = {0, 1};

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      background: DSColors.tintAsh,
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DSPillButton(label: 'Done', onPressed: widget.onNext),
          const SizedBox(height: DSDimens.sizeXxs),
          TextButton(
            onPressed: widget.onNext,
            child: Text(
              'Set up later',
              style: DSTextStyles.label.copyWith(
                color: DSColors.inkSecondary,
              ),
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: DSDimens.sizeS),
          Text(
            'What should we\nping you about?',
            style: DSTextStyles.displayLg,
          ),
          const SizedBox(height: DSDimens.size3xl),
          for (var i = 0; i < _options.length; i++) ...[
            DSOptionRow(
              leadingEmoji: _options[i].emoji,
              label: _options[i].label,
              selected: _selected.contains(i),
              onTap: () => setState(() {
                if (!_selected.add(i)) _selected.remove(i);
              }),
            ),
            if (i != _options.length - 1)
              const SizedBox(height: DSDimens.sizeXs),
          ],
          const Spacer(),
        ],
      ),
    );
  }
}
