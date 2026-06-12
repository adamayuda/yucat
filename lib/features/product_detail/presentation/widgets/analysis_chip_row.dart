import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';

/// Overall pros/cons rendered as icon + text rows, matching the per-cat verdict
/// findings (`CatVerdictCard`), instead of coloured background pills.
class AnalysisChipRow extends StatelessWidget {
  final List<String> pros;
  final List<String> cons;

  const AnalysisChipRow({super.key, required this.pros, required this.cons});

  @override
  Widget build(BuildContext context) {
    if (pros.isEmpty && cons.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final pro in pros) _FindingRow.success(text: pro),
        for (final con in cons) _FindingRow.caution(text: con),
      ],
    );
  }
}

enum _FindingKind { success, caution }

class _FindingRow extends StatelessWidget {
  final String text;
  final _FindingKind kind;

  const _FindingRow.success({required this.text}) : kind = _FindingKind.success;
  const _FindingRow.caution({required this.text}) : kind = _FindingKind.caution;

  @override
  Widget build(BuildContext context) {
    final isSuccess = kind == _FindingKind.success;
    final bg =
        isSuccess ? DSColors.accentSuccessSoft : const Color(0xFFFFF3D6);
    final fg = isSuccess ? DSColors.accentSuccess : const Color(0xFFB37800);
    final icon = isSuccess ? Icons.check_rounded : Icons.warning_amber_rounded;

    return Padding(
      padding: const EdgeInsets.only(top: DSDimens.sizeXxs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Icon(icon, color: fg, size: 13),
          ),
          const SizedBox(width: DSDimens.sizeXs),
          Expanded(
            child: Text(
              text,
              style: DSTextStyles.bodyMd.copyWith(color: DSColors.inkPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
