/// Localized copy and visual vocabulary for the carnet.
///
/// Same house style as `cat_labels.dart`: free functions taking
/// `(rawValue, AppLocalizations)`, a `switch` expression, and a safe fallback —
/// never a class, never a hardcoded English string.
///
/// The protocol catalogue lives in the domain layer and knows nothing about
/// copy; this is the only place a `protocolId` becomes a sentence.
library;

import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/health_carnet/domain/entities/health_event_entity.dart';
import 'package:yucat/features/health_carnet/domain/entities/health_protocol.dart';
import 'package:yucat/features/health_carnet/presentation/models/health_due_item.dart';
import 'package:yucat/features/health_carnet/presentation/utils/health_date_format.dart';
import 'package:yucat/l10n/app_localizations.dart';


/// Display name for a protocol, e.g. "Rabies booster".
String healthProtocolName(String protocolId, AppLocalizations l10n) {
  return switch (protocolId) {
    'annual_checkup' => l10n.healthProtocolAnnualCheckup,
    'fvrcp' => l10n.healthProtocolFvrcp,
    'rabies' => l10n.healthProtocolRabies,
    'felv' => l10n.healthProtocolFelv,
    'felv_booster' => l10n.healthProtocolFelvBooster,
    'deworming_internal' => l10n.healthProtocolDewormingInternal,
    'deworming_monthly' => l10n.healthProtocolDewormingMonthly,
    'parasite_external' => l10n.healthProtocolParasiteExternal,
    'heartworm' => l10n.healthProtocolHeartworm,
    'dental_scaling' => l10n.healthProtocolDentalScaling,
    'senior_panel' => l10n.healthProtocolSeniorPanel,
    'retrovirus_test' => l10n.healthProtocolRetrovirusTest,
    'condition_follow_up' => l10n.healthProtocolConditionFollowUp,
    'neutering' => l10n.healthProtocolNeutering,
    'microchip' => l10n.healthProtocolMicrochip,
    _ => protocolId,
  };
}

/// One-line explanation of what the act is for.
String healthProtocolDescription(String protocolId, AppLocalizations l10n) {
  return switch (protocolId) {
    'annual_checkup' => l10n.healthProtocolAnnualCheckupDesc,
    'fvrcp' => l10n.healthProtocolFvrcpDesc,
    'rabies' => l10n.healthProtocolRabiesDesc,
    'felv' => l10n.healthProtocolFelvDesc,
    'felv_booster' => l10n.healthProtocolFelvBoosterDesc,
    'deworming_internal' => l10n.healthProtocolDewormingInternalDesc,
    'deworming_monthly' => l10n.healthProtocolDewormingMonthlyDesc,
    'parasite_external' => l10n.healthProtocolParasiteExternalDesc,
    'heartworm' => l10n.healthProtocolHeartwormDesc,
    'dental_scaling' => l10n.healthProtocolDentalScalingDesc,
    'senior_panel' => l10n.healthProtocolSeniorPanelDesc,
    'retrovirus_test' => l10n.healthProtocolRetrovirusTestDesc,
    'condition_follow_up' => l10n.healthProtocolConditionFollowUpDesc,
    'neutering' => l10n.healthProtocolNeuteringDesc,
    'microchip' => l10n.healthProtocolMicrochipDesc,
    _ => '',
  };
}

String healthCategoryLabel(HealthCategory category, AppLocalizations l10n) {
  return switch (category) {
    HealthCategory.vaccine => l10n.healthCategoryVaccine,
    HealthCategory.parasite => l10n.healthCategoryParasite,
    HealthCategory.exam => l10n.healthCategoryExam,
    HealthCategory.dental => l10n.healthCategoryDental,
    HealthCategory.surgery => l10n.healthCategorySurgery,
    HealthCategory.lab => l10n.healthCategoryLab,
    HealthCategory.identification => l10n.healthCategoryIdentification,
    HealthCategory.treatment => l10n.healthCategoryTreatment,
    HealthCategory.weight => l10n.healthCategoryWeight,
    HealthCategory.other => l10n.healthCategoryOther,
  };
}

IconData healthCategoryIcon(HealthCategory category) {
  return switch (category) {
    HealthCategory.vaccine => Icons.vaccines_outlined,
    HealthCategory.parasite => Icons.pest_control_outlined,
    HealthCategory.exam => Icons.local_hospital_outlined,
    HealthCategory.dental => Icons.cleaning_services_outlined,
    HealthCategory.surgery => Icons.healing_outlined,
    HealthCategory.lab => Icons.science_outlined,
    HealthCategory.identification => Icons.badge_outlined,
    HealthCategory.treatment => Icons.medication_outlined,
    HealthCategory.weight => Icons.monitor_weight_outlined,
    HealthCategory.other => Icons.event_note_outlined,
  };
}

/// Background tint for the category's icon disc and timeline pill.
Color healthCategoryTint(HealthCategory category) {
  return switch (category) {
    HealthCategory.vaccine => DSColors.tintBlueSoft,
    HealthCategory.parasite => DSColors.tintMintSoft,
    HealthCategory.exam => DSColors.tintMint,
    HealthCategory.dental => DSColors.tintSand,
    HealthCategory.surgery => DSColors.tintCoralSoft,
    HealthCategory.lab => DSColors.tintLavender,
    HealthCategory.identification => DSColors.tintGreySoft,
    HealthCategory.treatment => DSColors.tintCream,
    HealthCategory.weight => DSColors.tintSkyBright,
    HealthCategory.other => DSColors.tintAsh,
  };
}

/// Foreground colour paired with [healthCategoryTint].
Color healthCategoryInk(HealthCategory category) {
  return switch (category) {
    HealthCategory.vaccine => DSColors.accentInfo,
    HealthCategory.parasite => DSColors.accentSuccess,
    HealthCategory.exam => DSColors.accentSuccess,
    HealthCategory.dental => DSColors.accentWarning,
    HealthCategory.surgery => DSColors.accentDanger,
    HealthCategory.lab => DSColors.inkPrimary,
    HealthCategory.identification => DSColors.inkSecondary,
    HealthCategory.treatment => DSColors.accentWarning,
    HealthCategory.weight => DSColors.accentInfo,
    HealthCategory.other => DSColors.inkSecondary,
  };
}

/// Pill colours for the urgency chip. `toSchedule` is deliberately neutral —
/// it is an invitation, not an alarm.
({Color background, Color ink}) healthUrgencyColors(HealthUrgency urgency) {
  return switch (urgency) {
    HealthUrgency.overdue => (
        background: DSColors.tintCoralSoft,
        ink: DSColors.accentDanger,
      ),
    HealthUrgency.urgent => (
        background: DSColors.tintCoralSoft,
        ink: DSColors.accentDanger,
      ),
    HealthUrgency.soon => (
        background: DSColors.tintBlueSoft,
        ink: DSColors.accentInfo,
      ),
    HealthUrgency.later => (
        background: DSColors.accentSuccessSoft,
        ink: DSColors.accentSuccess,
      ),
    HealthUrgency.toSchedule => (
        background: DSColors.tintAsh,
        ink: DSColors.inkSecondary,
      ),
  };
}

/// The short relative chip: "In 3 days", "6 days late", "To schedule".
String healthUrgencyLabel(HealthDueItem item, AppLocalizations l10n) {
  if (item.urgency == HealthUrgency.toSchedule || item.daysUntil == null) {
    return l10n.healthCarnetToSchedule;
  }
  final days = item.daysUntil!;
  if (days == 0) return l10n.healthCarnetToday;
  if (days == 1) return l10n.healthCarnetTomorrow;

  final parts = healthRelativeParts(days);
  if (days < 0) {
    return switch (parts.unit) {
      HealthRelativeUnit.day => l10n.healthCarnetLateDays(parts.value),
      HealthRelativeUnit.month => l10n.healthCarnetLateMonths(parts.value),
      HealthRelativeUnit.year => l10n.healthCarnetLateYears(parts.value),
    };
  }
  return switch (parts.unit) {
    HealthRelativeUnit.day => l10n.healthCarnetInDays(parts.value),
    HealthRelativeUnit.month => l10n.healthCarnetInMonths(parts.value),
    HealthRelativeUnit.year => l10n.healthCarnetInYears(parts.value),
  };
}

/// "Every 3 months" — the recurrence line. Empty for a one-time act.
String healthRecurrenceLabel(int? intervalDays, AppLocalizations l10n) {
  if (intervalDays == null) return '';
  if (intervalDays % 365 == 0 && intervalDays >= 365) {
    return l10n.healthCarnetEveryYears(intervalDays ~/ 365);
  }
  if (intervalDays >= 28) {
    return l10n.healthCarnetEveryMonths((intervalDays / 30.4375).round());
  }
  return l10n.healthCarnetEveryDays(intervalDays);
}

/// The secondary line under a due item: recurrence plus what it follows on from.
///
/// The mockup's *"Tous les 3 mois. Dernier traitement le 3 juin."* and
/// *"Dernière injection le 12 janv. 2026. Rappel selon le vaccin utilisé."*
String healthDueSubtitle(
  HealthDueItem item,
  AppLocalizations l10n,
  String locale,
) {
  final parts = <String>[];

  final recurrence = healthRecurrenceLabel(item.intervalDays, l10n);
  if (recurrence.isNotEmpty) parts.add(recurrence);

  final last = item.lastDone?.performedAt;
  if (last != null) {
    parts.add(l10n.healthCarnetLastDoneOn(healthFormatDate(last, locale)));
  } else {
    parts.add(l10n.healthCarnetNoRecordYet);
  }

  if (item.isSeriesDose) parts.add(l10n.healthCarnetSeriesNote);

  // The interval is a property of the vial, not the cat — say so rather than
  // implying the app knows which booster the vet used.
  if (item.protocol.id == 'rabies' && item.lastDone != null) {
    parts.add(l10n.healthCarnetRabiesIntervalNote);
  }

  // Never assert what the user's local law requires.
  if (item.protocol.obligation == HealthObligation.legal) {
    parts.add(l10n.healthCarnetLegalNote);
  }

  return parts.join(' ');
}
