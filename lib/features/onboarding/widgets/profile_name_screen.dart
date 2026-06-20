import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/ds_pill_button.dart';
import 'package:yucat/presentation/components/onboarding_scaffold.dart';

const _suggestedNames = [
  'Mochi',
  'Miso',
  'Toro',
  'Pickle',
  'Luna',
  'Whiskers',
  'Biscuit',
  'Pumpkin',
  'Oreo',
  'Cleo',
];

class ProfileNameScreen extends StatefulWidget {
  final String? initialName;
  final void Function(String name) onNext;

  /// Whether this is the currently-visible onboarding phase. The keyboard is
  /// only raised when active, so the off-screen page in the PageView doesn't
  /// pop the keyboard on neighbouring screens.
  final bool active;

  const ProfileNameScreen({
    super.key,
    required this.initialName,
    required this.onNext,
    this.active = true,
  });

  @override
  State<ProfileNameScreen> createState() => _ProfileNameScreenState();
}

class _ProfileNameScreenState extends State<ProfileNameScreen> {
  late final TextEditingController _controller;
  final _focusNode = FocusNode();
  final _random = Random();

  Timer? _keyboardTimer;

  /// Delay before raising the keyboard once the screen becomes active. Kept
  /// safely longer than the 280ms PageView slide so the keyboard's slide-up
  /// doesn't overlap (and jank) the page transition.
  static const _keyboardDelay = Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName ?? '');
    _controller.addListener(() => setState(() {}));
    // Defensive: onboarding normally starts on an earlier phase, but if this
    // screen mounts already-active, schedule the delayed keyboard too.
    if (widget.active) _scheduleKeyboard();
  }

  @override
  void didUpdateWidget(ProfileNameScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Raise the keyboard automatically, but only after the page transition has
    // settled. Doing it immediately (e.g. autofocus) fights the slide animation
    // and causes lag, so we wait _keyboardDelay before requesting focus and
    // drop focus the moment we leave so the keyboard doesn't linger.
    if (widget.active && !oldWidget.active) {
      _scheduleKeyboard();
    } else if (!widget.active && oldWidget.active) {
      _keyboardTimer?.cancel();
      _focusNode.unfocus();
    }
  }

  void _scheduleKeyboard() {
    _keyboardTimer?.cancel();
    _keyboardTimer = Timer(_keyboardDelay, () {
      if (mounted && widget.active) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _keyboardTimer?.cancel();
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _randomize() {
    final name = _suggestedNames[_random.nextInt(_suggestedNames.length)];
    _controller.text = name;
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: name.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasName = _controller.text.trim().isNotEmpty;

    return OnboardingScaffold(
      background: DSColors.tintAsh,
      footer: Row(
        children: [
          _SuggestButton(onTap: _randomize),
          const Spacer(),
          DSPillButton(
            label: l10n.commonNext,
            onPressed: hasName
                ? () {
                    FocusScope.of(context).unfocus();
                    widget.onNext(_controller.text.trim());
                  }
                : null,
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Mascot peeking in from the top-right corner, clipped by the screen
          // edges (bleeds off the top and the right past the scaffold padding).
          Positioned(
            top: -DSDimens.size4xl,
            right: -DSDimens.size3xl,
            child: SvgPicture.asset(
              'assets/images/cat-side.svg',
              width: 160,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              Text(
                l10n.onboardingProfileNameLabel,
                textAlign: TextAlign.center,
                style: DSTextStyles.titleMd.copyWith(
                  color: DSColors.inkSecondary,
                ),
              ),
              const SizedBox(height: DSDimens.sizeXs),
              TextField(
                controller: _controller,
                focusNode: _focusNode,
                textAlign: TextAlign.center,
                textCapitalization: TextCapitalization.words,
                style: DSTextStyles.displayHero,
                cursorColor: DSColors.accentInfo,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: l10n.onboardingProfileNameHint,
                  hintStyle: DSTextStyles.displayHero.copyWith(
                    color: DSColors.inkTertiary,
                  ),
                ),
              ),
              const Spacer(flex: 3),
            ],
          ),
        ],
      ),
    );
  }
}

class _SuggestButton extends StatelessWidget {
  final VoidCallback onTap;

  const _SuggestButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: DSColors.surfaceCardDim,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Center(
            child: SvgPicture.asset(
              'assets/images/Games.svg',
              width: 26,
              height: 26,
            ),
          ),
        ),
      ),
    );
  }
}
