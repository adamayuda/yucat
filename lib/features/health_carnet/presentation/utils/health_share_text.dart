import 'package:yucat/features/cat/domain/entities/cat_lifestyle.dart';
import 'package:yucat/features/cat/presentation/utils/cat_labels.dart';
import 'package:yucat/features/health_carnet/domain/entities/health_event_entity.dart';
import 'package:yucat/features/health_carnet/presentation/bloc/health_carnet_bloc.dart';
import 'package:yucat/features/health_carnet/presentation/models/health_due_item.dart';
import 'package:yucat/features/health_carnet/presentation/utils/health_date_format.dart';
import 'package:yucat/features/health_carnet/presentation/utils/health_labels.dart';
import 'package:yucat/l10n/app_localizations.dart';

/// The carnet as a plain-text note — for a cat sitter, a new vet, a border
/// crossing that asks for the rabies date. Text rather than PDF on purpose:
/// it pastes into any chat, and a PDF would need a layout engine the app does
/// not ship (deferred, README §12).
///
/// Pure: takes the loaded state and the localizations, returns a string, so
/// the wording can be checked without a widget.
String buildHealthShareText({
  required HealthCarnetLoadedState state,
  required AppLocalizations l10n,
  required String locale,
  int maxUpcoming = 5,
}) {
  final cat = state.cat;
  final lines = <String>[l10n.healthShareHeading(cat.name), ''];

  // --- Profile -------------------------------------------------------------
  final birth = cat.birthDate;
  if (birth != null) {
    lines.add('${l10n.healthShareBirthday}: ${healthFormatDate(birth, locale)}');
  }
  final age = cat.age;
  if (age != null) {
    lines.add('${l10n.healthShareAge}: ${catFormatAge(age, l10n)}');
  }
  final kg = state.latestWeightKg ?? cat.weight;
  if (kg != null) {
    lines.add('${l10n.healthShareWeight}: ${healthFormatKg(kg, locale)} kg');
  }
  final lifestyle = CatLifestyle.normalize(cat.lifestyle);
  if (lifestyle != null) {
    lines.add('${l10n.healthShareLifestyle}: ${lifestyle == CatLifestyle.outdoor ? l10n.healthLifestyleOutdoor : l10n.healthLifestyleIndoor}');
  }

  // --- Core vaccines -------------------------------------------------------
  lines
    ..add('')
    ..add(l10n.healthShareVaccines);
  for (final id in const ['fvrcp', 'rabies', 'felv']) {
    final last = _latestDone(state.history, id);
    final name = healthProtocolName(id, l10n);
    if (last?.performedAt == null) {
      lines.add('• $name: ${l10n.healthShareNoRecord}');
      continue;
    }
    var line = '• $name: ${healthFormatDate(last!.performedAt!, locale)}';
    if (id == 'rabies') {
      final until = last.performedAt!.add(
        Duration(days: last.intervalDays ?? 365),
      );
      line += ' (${l10n.healthShareValidUntil(healthFormatDate(until, locale))})';
    }
    lines.add(line);
  }

  // --- Upcoming ------------------------------------------------------------
  final upcoming = state.dueItems
      .where((d) => d.urgency != HealthUrgency.toSchedule && d.dueDate != null)
      .take(maxUpcoming)
      .toList();
  if (upcoming.isNotEmpty) {
    lines
      ..add('')
      ..add(l10n.healthShareUpcoming);
    for (final item in upcoming) {
      lines.add(
        '• ${healthProtocolName(item.protocol.id, l10n)}: '
        '${healthFormatDate(item.dueDate!, locale)}',
      );
    }
  }

  // --- Allergies -----------------------------------------------------------
  final allergies = cat.allergies ?? const [];
  if (allergies.isNotEmpty) {
    lines
      ..add('')
      ..add('${l10n.healthShareAllergies}: '
          '${allergies.map((k) => catFormatAllergen(k, l10n)).join(', ')}');
  }

  // --- Vet -----------------------------------------------------------------
  final vet = cat.vet;
  if (vet != null && !vet.isEmpty) {
    final parts = [
      vet.displayName,
      if ((vet.clinic ?? '').trim().isNotEmpty && vet.clinic!.trim() != vet.displayName)
        vet.clinic!.trim(),
      if ((vet.phone ?? '').trim().isNotEmpty) vet.phone!.trim(),
    ];
    lines
      ..add('')
      ..add('${l10n.healthShareVet}: ${parts.join(' · ')}');
  }

  lines
    ..add('')
    ..add(l10n.healthShareFooter);
  return lines.join('\n');
}

HealthEventEntity? _latestDone(List<HealthEventEntity> history, String id) {
  HealthEventEntity? best;
  for (final e in history) {
    if (e.protocolId != id || e.performedAt == null) continue;
    if (best == null || e.performedAt!.isAfter(best.performedAt!)) best = e;
  }
  return best;
}
