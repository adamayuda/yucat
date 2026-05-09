import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/presentation/components/ds_pill_button.dart';
import 'package:yucat/presentation/components/onboarding_scaffold.dart';

class AttributionDetailsScreen extends StatefulWidget {
  final void Function(String? text) onSubmit;
  final VoidCallback onBack;

  const AttributionDetailsScreen({
    super.key,
    required this.onSubmit,
    required this.onBack,
  });

  @override
  State<AttributionDetailsScreen> createState() =>
      _AttributionDetailsScreenState();
}

class _AttributionDetailsScreenState extends State<AttributionDetailsScreen> {
  final _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final has = _controller.text.trim().isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      background: DSColors.tintAsh,
      onBack: widget.onBack,
      footer: _hasText
          ? DSPillButton(
              label: 'Next',
              onPressed: () => widget.onSubmit(_controller.text.trim()),
            )
          : DSPillButton(
              label: 'No, skip',
              onPressed: () => widget.onSubmit(null),
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(flex: 1),
          Text(
            'Enter the influencer\'s name\n(if you remember)',
            textAlign: TextAlign.center,
            style: DSTextStyles.bodyLg.copyWith(color: DSColors.inkSecondary),
          ),
          const SizedBox(height: DSDimens.sizeL),
          TextField(
            controller: _controller,
            autofocus: true,
            textAlign: TextAlign.center,
            style: DSTextStyles.displayLg,
            cursorColor: DSColors.inkPrimary,
            decoration: const InputDecoration(
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
              fillColor: Colors.transparent,
              isCollapsed: true,
              contentPadding: EdgeInsets.zero,
              hintText: 'Their name',
            ),
          ),
          const Spacer(flex: 3),
        ],
      ),
    );
  }
}
