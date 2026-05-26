import 'dart:math';

import 'package:flutter/material.dart';
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

  const ProfileNameScreen({
    super.key,
    required this.initialName,
    required this.onNext,
  });

  @override
  State<ProfileNameScreen> createState() => _ProfileNameScreenState();
}

class _ProfileNameScreenState extends State<ProfileNameScreen> {
  late final TextEditingController _controller;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName ?? '');
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
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
      footer: DSPillButton(
        label: 'Next',
        onPressed: hasName
            ? () => widget.onNext(_controller.text.trim())
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: DSDimens.sizeS),
          Text(
            "What's your\ncat's name?",
            textAlign: TextAlign.center,
            style: DSTextStyles.displayHero,
          ),
          const Spacer(flex: 1),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DSDimens.sizeL,
              vertical: DSDimens.sizeS,
            ),
            decoration: BoxDecoration(
              color: DSColors.surfaceCard,
              borderRadius: BorderRadius.circular(DSRadii.lg),
              boxShadow: DSShadows.e1,
            ),
            child: TextField(
              controller: _controller,
              autofocus: true,
              textAlign: TextAlign.center,
              textCapitalization: TextCapitalization.words,
              style: DSTextStyles.displayLg,
              cursorColor: DSColors.accentInfo,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Mochi',
                hintStyle: DSTextStyles.displayLg.copyWith(
                  color: DSColors.inkTertiary,
                ),
              ),
            ),
          ),
          const SizedBox(height: DSDimens.sizeL),
          TextButton.icon(
            onPressed: _randomize,
            icon: const Text('🎲', style: TextStyle(fontSize: 18)),
            label: Text(
              'Suggest a name',
              style: DSTextStyles.label.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            style: TextButton.styleFrom(
              foregroundColor: DSColors.inkPrimary,
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}
