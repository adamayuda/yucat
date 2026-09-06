import 'package:flutter/material.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/health_carnet/domain/entities/health_event_entity.dart';
import 'package:yucat/features/health_carnet/presentation/models/health_due_item.dart';
import 'package:yucat/features/health_carnet/presentation/utils/health_calendar_layout.dart';
import 'package:yucat/features/health_carnet/presentation/utils/health_date_format.dart';
import 'package:yucat/features/health_carnet/presentation/utils/health_labels.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/ds_card.dart';
import 'package:yucat/presentation/components/ds_haptics.dart';

/// Month grid of everything dated, past and future, with a day detail below.
///
/// Stateful and **self-contained**: the displayed month and the selected day are
/// pure view navigation, so they stay here rather than in `HealthCarnetBloc`.
/// Routing them through the bloc would churn a state that also drives the other
/// two tabs, for no gain.
///
/// ⚠️ `HealthUrgency.toSchedule` items are **excluded**. They are dated today by
/// construction — a placeholder standing in for "no record yet" — so plotting
/// them would stack seven markers on today's cell for a fresh carnet and imply a
/// deadline none of them has. A footnote says so rather than leaving the
/// omission silent.
class HealthCalendarView extends StatefulWidget {
  final List<HealthEventEntity> history;
  final List<HealthDueItem> dueItems;

  const HealthCalendarView({
    super.key,
    required this.history,
    required this.dueItems,
  });

  @override
  State<HealthCalendarView> createState() => _HealthCalendarViewState();
}

class _HealthCalendarViewState extends State<HealthCalendarView> {
  late DateTime _month;
  late DateTime _selected;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
    _selected = _dayOf(now);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = healthLocaleOf(context);
    final material = MaterialLocalizations.of(context);

    final doneByDay = <DateTime, List<HealthEventEntity>>{};
    for (final event in widget.history) {
      final at = event.performedAt;
      if (at == null) continue;
      doneByDay.putIfAbsent(_dayOf(at), () => []).add(event);
    }

    final dueByDay = <DateTime, List<HealthDueItem>>{};
    for (final item in widget.dueItems) {
      final at = item.dueDate;
      if (at == null) continue;
      if (item.urgency == HealthUrgency.toSchedule) continue;
      dueByDay.putIfAbsent(_dayOf(at), () => []).add(item);
    }

    final selectedDone = doneByDay[_selected] ?? const [];
    final selectedDue = dueByDay[_selected] ?? const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DSCard(
          padding: const EdgeInsets.all(DSDimens.sizeS),
          child: Column(
            children: [
              _MonthHeader(
                label: healthFormatMonthYear(_month, locale),
                onPrevious: () => _shiftMonth(-1),
                onNext: () => _shiftMonth(1),
              ),
              const SizedBox(height: DSDimens.sizeXs),
              _WeekdayHeader(material: material),
              const SizedBox(height: DSDimens.sizeXxs),
              ..._weeks(
                material: material,
                doneByDay: doneByDay,
                dueByDay: dueByDay,
              ),
              const SizedBox(height: DSDimens.sizeXs),
              _Legend(l10n: l10n),
            ],
          ),
        ),
        const SizedBox(height: DSDimens.sizeS),
        _DayDetail(
          date: _selected,
          done: selectedDone,
          due: selectedDue,
          locale: locale,
        ),
        const SizedBox(height: DSDimens.sizeXs),
        Text(
          l10n.healthCarnetCalendarUnscheduledNote,
          style: DSTextStyles.caption,
        ),
      ],
    );
  }

  void _shiftMonth(int delta) {
    DSHaptics.selection();
    setState(() => _month = DateTime(_month.year, _month.month + delta));
  }

  /// The month laid out as rows of seven, honouring the locale's first weekday.
  List<Widget> _weeks({
    required MaterialLocalizations material,
    required Map<DateTime, List<HealthEventEntity>> doneByDay,
    required Map<DateTime, List<HealthDueItem>> dueByDay,
  }) {
    final firstColumn =
        leadingBlankDays(_month, material.firstDayOfWeekIndex);
    final dayCount = daysInMonth(_month);
    final today = _dayOf(DateTime.now());

    final cells = <Widget>[];
    for (var i = 0; i < firstColumn; i++) {
      cells.add(const Expanded(child: SizedBox(height: 44)));
    }
    for (var day = 1; day <= dayCount; day++) {
      final date = DateTime(_month.year, _month.month, day);
      cells.add(
        Expanded(
          child: _DayCell(
            day: day,
            isToday: date == today,
            isSelected: date == _selected,
            doneCount: (doneByDay[date] ?? const []).length,
            dueCount: (dueByDay[date] ?? const []).length,
            categories: [
              for (final e in doneByDay[date] ?? const <HealthEventEntity>[])
                e.category,
            ],
            onTap: () {
              DSHaptics.selection();
              setState(() => _selected = date);
            },
          ),
        ),
      );
    }
    while (cells.length % 7 != 0) {
      cells.add(const Expanded(child: SizedBox(height: 44)));
    }

    return [
      for (var i = 0; i < cells.length; i += 7)
        Row(children: cells.sublist(i, i + 7)),
    ];
  }

  static DateTime _dayOf(DateTime d) => DateTime(d.year, d.month, d.day);
}

class _MonthHeader extends StatelessWidget {
  final String label;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _MonthHeader({
    required this.label,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        _Arrow(
          icon: Icons.chevron_left_rounded,
          semanticLabel: l10n.healthCarnetCalendarPreviousMonth,
          onTap: onPrevious,
        ),
        Expanded(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: DSTextStyles.titleMd,
          ),
        ),
        _Arrow(
          icon: Icons.chevron_right_rounded,
          semanticLabel: l10n.healthCarnetCalendarNextMonth,
          onTap: onNext,
        ),
      ],
    );
  }
}

class _Arrow extends StatelessWidget {
  final IconData icon;
  final String semanticLabel;
  final VoidCallback onTap;

  const _Arrow({
    required this.icon,
    required this.semanticLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      icon: Icon(icon, color: DSColors.inkPrimary, size: 26),
      tooltip: semanticLabel,
    );
  }
}

class _WeekdayHeader extends StatelessWidget {
  final MaterialLocalizations material;

  const _WeekdayHeader({required this.material});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < 7; i++)
          Expanded(
            child: Text(
              material.narrowWeekdays[(material.firstDayOfWeekIndex + i) % 7],
              textAlign: TextAlign.center,
              style: DSTextStyles.caption,
            ),
          ),
      ],
    );
  }
}

/// One day. A filled dot per recorded act, a ring per scheduled one — so past
/// and future read differently at a glance without needing colour alone.
class _DayCell extends StatelessWidget {
  final int day;
  final bool isToday;
  final bool isSelected;
  final int doneCount;
  final int dueCount;
  final List<HealthCategory> categories;
  final VoidCallback onTap;

  /// More markers than this in one day collapse — three dots is already the
  /// point ("something happened here"), and a fourth just makes the cell noisy.
  static const _maxMarkers = 3;

  const _DayCell({
    required this.day,
    required this.isToday,
    required this.isSelected,
    required this.doneCount,
    required this.dueCount,
    required this.categories,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final markers = <Widget>[];
    for (final category in categories.take(_maxMarkers)) {
      markers.add(_dot(healthCategoryInk(category), filled: true));
    }
    for (var i = 0; i < dueCount && markers.length < _maxMarkers; i++) {
      markers.add(_dot(DSColors.accentInfo, filled: false));
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 44,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? DSColors.inkPrimary : Colors.transparent,
                shape: BoxShape.circle,
                border: !isSelected && isToday
                    ? Border.all(color: DSColors.inkTertiary)
                    : null,
              ),
              child: Text(
                '$day',
                style: DSTextStyles.bodyMd.copyWith(
                  color: isSelected
                      ? DSColors.inkInverse
                      : DSColors.inkPrimary,
                  fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: DSDimens.sizeXxxs),
            SizedBox(
              height: 6,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final marker in markers) ...[
                    marker,
                    const SizedBox(width: 2),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dot(Color color, {required bool filled}) => Container(
        width: 5,
        height: 5,
        decoration: BoxDecoration(
          color: filled ? color : Colors.transparent,
          shape: BoxShape.circle,
          border: filled ? null : Border.all(color: color, width: 1.2),
        ),
      );
}

class _Legend extends StatelessWidget {
  final AppLocalizations l10n;

  const _Legend({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 5,
          height: 5,
          decoration: const BoxDecoration(
            color: DSColors.inkSecondary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: DSDimens.sizeXxxs),
        Text(l10n.healthCarnetCalendarLegendDone,
            style: DSTextStyles.caption),
        const SizedBox(width: DSDimens.sizeS),
        Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: DSColors.accentInfo, width: 1.2),
          ),
        ),
        const SizedBox(width: DSDimens.sizeXxxs),
        Text(l10n.healthCarnetCalendarLegendDue, style: DSTextStyles.caption),
      ],
    );
  }
}

class _DayDetail extends StatelessWidget {
  final DateTime date;
  final List<HealthEventEntity> done;
  final List<HealthDueItem> due;
  final String locale;

  const _DayDetail({
    required this.date,
    required this.done,
    required this.due,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return DSCard(
      padding: const EdgeInsets.all(DSDimens.sizeS),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(healthFormatDate(date, locale), style: DSTextStyles.titleMd),
          const SizedBox(height: DSDimens.sizeXs),
          if (done.isEmpty && due.isEmpty)
            Text(
              l10n.healthCarnetCalendarEmptyDay,
              style: DSTextStyles.bodyMd,
            ),
          if (done.isNotEmpty) ...[
            Text(
              l10n.healthCarnetCalendarSectionDone,
              style: DSTextStyles.label,
            ),
            const SizedBox(height: DSDimens.sizeXxs),
            for (final event in done)
              _DetailRow(
                category: event.category,
                label: event.title.isNotEmpty
                    ? event.title
                    : healthProtocolName(event.protocolId ?? '', l10n),
                secondary: event.notes,
                filled: true,
              ),
          ],
          if (due.isNotEmpty) ...[
            if (done.isNotEmpty) const SizedBox(height: DSDimens.sizeXs),
            Text(
              l10n.healthCarnetCalendarSectionDue,
              style: DSTextStyles.label,
            ),
            const SizedBox(height: DSDimens.sizeXxs),
            for (final item in due)
              _DetailRow(
                category: item.protocol.category,
                label: healthProtocolName(item.protocol.id, l10n),
                secondary: healthRecurrenceLabel(item.intervalDays, l10n),
                filled: false,
              ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final HealthCategory category;
  final String label;
  final String? secondary;
  final bool filled;

  const _DetailRow({
    required this.category,
    required this.label,
    required this.secondary,
    required this.filled,
  });

  @override
  Widget build(BuildContext context) {
    final ink = healthCategoryInk(category);
    return Padding(
      padding: const EdgeInsets.only(bottom: DSDimens.sizeXxs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: filled
                  ? healthCategoryTint(category)
                  : DSColors.surfaceCardDim,
              borderRadius: BorderRadius.circular(DSRadii.sm),
            ),
            child: Icon(healthCategoryIcon(category), size: 17, color: ink),
          ),
          const SizedBox(width: DSDimens.sizeXxs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: DSTextStyles.bodyLg.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (secondary != null && secondary!.isNotEmpty)
                  Text(secondary!, style: DSTextStyles.bodyMd),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
