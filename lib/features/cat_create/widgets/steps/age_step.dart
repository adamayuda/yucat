import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';

class AgeStep extends StatefulWidget {
  final int? age;
  final ValueChanged<int?> onAgeChanged;

  const AgeStep({super.key, required this.age, required this.onAgeChanged});

  @override
  State<AgeStep> createState() => _AgeStepState();
}

class _AgeStepState extends State<AgeStep> {
  int _years = 0;
  int _months = 0;

  @override
  void initState() {
    super.initState();
    _initializeFromAge(widget.age);
  }

  @override
  void didUpdateWidget(covariant AgeStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.age != widget.age) {
      _initializeFromAge(widget.age);
    }
  }

  void _initializeFromAge(int? ageInMonths) {
    if (ageInMonths == null) return;
    setState(() {
      _years = ageInMonths ~/ 12;
      _months = ageInMonths % 12;
    });
  }

  void _notifyAgeChanged() {
    final totalMonths = _years * 12 + _months;
    widget.onAgeChanged(totalMonths);
  }

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
                  color: DSColors.primaryLight,
                  borderRadius: BorderRadius.circular(DSDimens.sizeXxs),
                ),
                width: 40,
                height: 40,
                child: Image.asset(
                  'assets/images/Icons/cake.png',
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
            value: _years,
            onDecrement: () {
              if (_years > 0) {
                setState(() {
                  _years -= 1;
                });
                _notifyAgeChanged();
              }
            },
            onIncrement: () {
              setState(() {
                _years += 1;
              });
              _notifyAgeChanged();
            },
            onValueChanged: (value) {
              setState(() {
                _years = value;
              });
              _notifyAgeChanged();
            },
          ),

          SizedBox(height: DSDimens.sizeM),

          // Months input
          _NumberInputRow(
            label: 'Months',
            value: _months,
            onDecrement: () {
              if (_months > 0) {
                setState(() {
                  _months -= 1;
                });
                _notifyAgeChanged();
              }
            },
            onIncrement: () {
              setState(() {
                _months += 1;
                if (_months >= 12) {
                  _years += _months ~/ 12;
                  _months = _months % 12;
                }
              });
              _notifyAgeChanged();
            },
            onValueChanged: (value) {
              setState(() {
                _months = value.clamp(0, 11);
              });
              _notifyAgeChanged();
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
