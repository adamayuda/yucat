import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';

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
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'What\'s your cat\'s name?',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(),
            ),
          ),
          Center(
            child: Text(
              'This helps us personalize recommendations.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
          ),
          SizedBox(height: DSDimens.sizeM),
          TextFormField(
            key: nameFieldKey,
            controller: nameController,
            decoration: InputDecoration(
              hintText: 'Enter your cat\'s name',
              hintStyle: TextStyle(color: Colors.grey[400]),
              filled: true,
              fillColor: DSColors.white,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DSDimens.sizeXs),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DSDimens.sizeXs),
                borderSide: const BorderSide(color: DSColors.primary, width: 2),
              ),
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
    );
  }
}
