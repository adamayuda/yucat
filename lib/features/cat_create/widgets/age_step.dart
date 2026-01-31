import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';

class AgeStep extends StatelessWidget {
  final String? ageGroup;
  final ValueChanged<String?> onAgeGroupChanged;
  final int years;
  final int months;
  final ValueChanged<int> onYearsChanged;
  final ValueChanged<int> onMonthsChanged;

  const AgeStep({
    super.key,
    required this.ageGroup,
    required this.onAgeGroupChanged,
    required this.years,
    required this.months,
    required this.onYearsChanged,
    required this.onMonthsChanged,
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
                  'assets/images/cake.png',
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(width: DSDimens.sizeS),
              Expanded(
                child: Text(
                  'How old is your cat?',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 29,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: DSDimens.sizeS),
          Center(
            child: Text(
              'Age affects nutritional needs and food ratings.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          SizedBox(height: DSDimens.sizeS),

          // Years input
          _NumberInputRow(
            label: 'Years',
            value: years,
            onDecrement: () {
              if (years > 0) {
                onYearsChanged(years - 1);
              }
            },
            onIncrement: () {
              onYearsChanged(years + 1);
            },
            onValueChanged: (value) {
              onYearsChanged(value);
            },
          ),

          SizedBox(height: DSDimens.sizeM),

          // Months input
          _NumberInputRow(
            label: 'Months',
            value: months,
            onDecrement: () {
              if (months > 0) {
                onMonthsChanged(months - 1);
              }
            },
            onIncrement: () {
              onMonthsChanged(months + 1);
            },
            onValueChanged: (value) {
              onMonthsChanged(value);
            },
          ),
        ],
      ),
    );
  }
}

class _NumberInputRow extends StatefulWidget {
  final String label;
  final int value;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final ValueChanged<int> onValueChanged;

  const _NumberInputRow({
    required this.label,
    required this.value,
    required this.onDecrement,
    required this.onIncrement,
    required this.onValueChanged,
  });

  @override
  State<_NumberInputRow> createState() => _NumberInputRowState();
}

class _NumberInputRowState extends State<_NumberInputRow> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toString());
  }

  @override
  void didUpdateWidget(_NumberInputRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.text = widget.value.toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          widget.label,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        SizedBox(height: DSDimens.sizeS),
        // Controls row
        Row(
          children: [
            // Decrement button
            _SquareButton(icon: Icons.remove, onTap: widget.onDecrement),
            SizedBox(width: DSDimens.sizeXxs),
            // Input field
            Expanded(
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: DSColors.white,
                  borderRadius: BorderRadius.circular(DSDimens.sizeXs),
                  border: Border.all(color: DSColors.inputLightGrey, width: 1),
                ),
                child: TextField(
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  controller: _controller,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: DSColors.black,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 8),
                  ),
                  onChanged: (text) {
                    final intValue = int.tryParse(text) ?? 0;
                    if (intValue >= 0) {
                      widget.onValueChanged(intValue);
                    }
                  },
                ),
              ),
            ),
            SizedBox(width: DSDimens.sizeXxs),
            // Increment button
            _SquareButton(icon: Icons.add, onTap: widget.onIncrement),
          ],
        ),
      ],
    );
  }
}

class _SquareButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _SquareButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(DSDimens.sizeXs),
        ),
        child: Icon(icon, color: Colors.black, size: 20),
      ),
    );
  }
}

class _AgeGroupOption extends StatelessWidget {
  final String label;
  final String value;
  final bool isSelected;
  final VoidCallback onTap;

  const _AgeGroupOption({
    required this.label,
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: isSelected
              ? DSColors.primary.withOpacity(0.1)
              : DSColors.white,
          borderRadius: BorderRadius.circular(DSDimens.sizeXs),
          border: Border.all(
            color: isSelected ? DSColors.primary : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: isSelected ? DSColors.primary : Colors.grey[700],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
