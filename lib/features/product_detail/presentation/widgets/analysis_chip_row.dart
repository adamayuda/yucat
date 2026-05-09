import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';

class AnalysisChipRow extends StatelessWidget {
  final List<String> pros;
  final List<String> cons;

  const AnalysisChipRow({super.key, required this.pros, required this.cons});

  @override
  Widget build(BuildContext context) {
    final shownPros = pros.take(3).toList();
    final shownCons = cons.take(1).toList();
    if (shownPros.isEmpty && shownCons.isEmpty) {
      return const SizedBox.shrink();
    }
    return Wrap(
      spacing: DSDimens.sizeXxs,
      runSpacing: DSDimens.sizeXxs,
      children: [
        for (final pro in shownPros)
          _AnalysisChip(text: pro, kind: _ChipKind.success),
        for (final con in shownCons)
          _AnalysisChip(text: con, kind: _ChipKind.caution),
      ],
    );
  }
}

enum _ChipKind { success, caution }

class _AnalysisChip extends StatelessWidget {
  final String text;
  final _ChipKind kind;

  const _AnalysisChip({required this.text, required this.kind});

  @override
  Widget build(BuildContext context) {
    final isSuccess = kind == _ChipKind.success;
    final bg = isSuccess
        ? DSColors.accentSuccessSoft
        : const Color(0xFFFFF3D6);
    final fg = isSuccess
        ? DSColors.accentSuccess
        : const Color(0xFFB37800);
    final prefix = isSuccess ? '+' : '!';
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSDimens.sizeXs,
        vertical: DSDimens.sizeXxxs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(DSRadii.pill),
      ),
      child: Text(
        '$prefix $text',
        style: DSTextStyles.caption.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
