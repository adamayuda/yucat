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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5E8FF),
                  borderRadius: BorderRadius.circular(DSDimens.sizeXxs),
                ),
                width: 40,
                height: 40,
                child: Image.asset(
                  'assets/images/cat_name.png',
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(width: DSDimens.sizeS),
              Expanded(
                child: Text(
                  'What\'s your cat\'s name?',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 29,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          // Center(
          //   child: Text(
          //     'This helps us personalize recommendations.',
          //     style: Theme.of(
          //       context,
          //     ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          //   ),
          // ),
          SizedBox(height: DSDimens.sizeS),
          TextFormField(
            key: nameFieldKey,
            controller: nameController,
            style: const TextStyle(
              color: Color(0xFFA0A8B6),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: 'Enter your cat\'s name',
              hintStyle: const TextStyle(
                color: Color(0xFFA0A8B6),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              filled: true,
              fillColor: DSColors.white,
              contentPadding: const EdgeInsets.only(
                left: 24,
                top: 16,
                bottom: 16,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DSDimens.sizeXs),
                borderSide: const BorderSide(color: Color(0xFFE6E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DSDimens.sizeXs),
                borderSide: const BorderSide(color: Color(0xFFFF61E5)),
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
