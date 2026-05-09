import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/presentation/components/mascot_speech_bubble.dart';

class CatNameStep extends StatelessWidget {
  final TextEditingController nameController;
  final GlobalKey<FormFieldState<String>> nameFieldKey;

  const CatNameStep({
    super.key,
    required this.nameController,
    required this.nameFieldKey,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const MascotSpeechBubble(
          question: 'What\'s your cat\'s name?',
        ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Name your cat',
                  style: DSTextStyles.bodyLg.copyWith(
                    color: DSColors.inkTertiary,
                  ),
                ),
                const SizedBox(height: DSDimens.sizeXs),
                TextFormField(
                  key: nameFieldKey,
                  controller: nameController,
                  textAlign: TextAlign.center,
                  autofocus: true,
                  cursorColor: DSColors.coralAccent,
                  style: DSTextStyles.displayLg,
                  decoration: const InputDecoration(
                    hintText: 'Caramel',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    filled: false,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a cat name';
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.done,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
