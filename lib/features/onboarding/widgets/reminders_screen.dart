import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  final Set<int> _selected = {};

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      gradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFEF8E6), Color(0xFFEFEEF5)],
      ),
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
                'What should we\nping you about?',
                textAlign: TextAlign.center,
                style: DSTextStyles.displayLg,
              ),
              const SizedBox(height: DSDimens.size3xl),
              for (var i = 0; i < _options.length; i++) ...[
                DSOptionRow(
                  leadingEmoji: _options[i].emoji,
                  label: _options[i].label,
                  showTrailingRadio: true,
                  trailingSize: 18,
                  selected: _selected.contains(i),
                  onTap: () => setState(() {
                    if (!_selected.add(i)) _selected.remove(i);
                  }),
                ),
                if (i != _options.length - 1)
                  const SizedBox(height: DSDimens.sizeXxs),
              ],
              const SizedBox(height: DSDimens.sizeL),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(DSDimens.sizeS),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8EADA),
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
                          children: const [
                            TextSpan(
                              text: 'Reminders build healthy eating habits ',
                            ),
                            TextSpan(
                              text: '2x faster',
                              style: TextStyle(
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
