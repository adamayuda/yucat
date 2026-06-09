import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:yucat/config/themes/theme.dart';
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

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName ?? '');
    _controller.addListener(() => setState(() {}));
  }

  @override
  void didUpdateWidget(ProfileNameScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // No auto-focus (it opens the keyboard immediately and causes lag); the
    // user taps the field to type. Just drop focus when leaving so the keyboard
    // doesn't linger on the next page.
    if (!widget.active && oldWidget.active) {
      _focusNode.unfocus();
    }
  }

  @override
  void dispose() {
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
    final hasName = _controller.text.trim().isNotEmpty;

    return OnboardingScaffold(
      background: DSColors.tintAsh,
      footer: Row(
        children: [
          _SuggestButton(onTap: _randomize),
          const Spacer(),
          DSPillButton(
            label: 'Next',
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
                'Name your cat',
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
                  hintText: 'Mochi',
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
        child: const SizedBox(
          width: 48,
          height: 48,
          child: Center(
            child: Text('🎲', style: TextStyle(fontSize: 20)),
          ),
        ),
      ),
    );
  }
}
