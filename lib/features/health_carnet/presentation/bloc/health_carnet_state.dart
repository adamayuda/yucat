part of 'health_carnet_bloc.dart';

sealed class HealthCarnetState extends Equatable {
  const HealthCarnetState();

  @override
  List<Object?> get props => [];
}

class HealthCarnetLoadingState extends HealthCarnetState {
  const HealthCarnetLoadingState();
}

/// Retryable. Reached on a read failure — which is why the datasource throws
/// rather than returning an empty list: "no records" and "we couldn't reach
/// Firestore" must never look the same on a page holding medical history.
class HealthCarnetErrorState extends HealthCarnetState {
  const HealthCarnetErrorState();
}

class HealthCarnetLoadedState extends HealthCarnetState {
  final CatEntity cat;

  /// Every record, most recent first.
  final List<HealthEventEntity> events;

  /// Derived, never stored — see `computeDueItems`.
  final List<HealthDueItem> dueItems;

  final List<WeightPoint> weightPoints;
  final int tabIndex;
  final bool isSaving;

  /// Increments per failed write so a `BlocListener` sees a state change and
  /// re-fires an identical SnackBar. Same trick as `CatCreateBloc.errorTick`.
  final int errorTick;

  const HealthCarnetLoadedState({
    required this.cat,
    required this.events,
    required this.dueItems,
    required this.weightPoints,
    this.tabIndex = 0,
    this.isSaving = false,
    this.errorTick = 0,
  });

  /// Records that actually happened. Excludes `snoozed` rows, which are
  /// scheduling residue rather than history and would otherwise appear in the
  /// timeline as acts the cat never had.
  List<HealthEventEntity> get history =>
      events.where((e) => e.isDone).toList();

  /// The "dont N urgent" figure. Counts overdue and imminent items only — a
  /// protocol the cat simply has no record of is an invitation, not an alarm,
  /// and inflating this with those would make the badge meaningless.
  int get urgentCount => dueItems.where((d) => d.urgency.isPressing).length;

  /// Recurring parasite and medication protocols with a next date — the
  /// "Traitements en cours" block. A regrouping of [dueItems], not a second
  /// source.
  List<HealthDueItem> get ongoingTreatments => dueItems
      .where((d) =>
          d.isRecurring &&
          d.intervalDays != null &&
          d.intervalDays! <= 92 &&
          (d.protocol.category == HealthCategory.parasite ||
              d.protocol.category == HealthCategory.treatment))
      .toList();

  DateTime? get lastRecordedAt {
    for (final event in events) {
      if (event.performedAt != null) return event.performedAt;
    }
    return null;
  }

  double? get latestWeightKg =>
      weightPoints.isEmpty ? null : weightPoints.last.kg;

  HealthCarnetLoadedState copyWith({
    CatEntity? cat,
    int? tabIndex,
    bool? isSaving,
    bool bumpError = false,
  }) {
    return HealthCarnetLoadedState(
      cat: cat ?? this.cat,
      events: events,
      dueItems: dueItems,
      weightPoints: weightPoints,
      tabIndex: tabIndex ?? this.tabIndex,
      isSaving: isSaving ?? this.isSaving,
      errorTick: bumpError ? errorTick + 1 : errorTick,
    );
  }

  @override
  List<Object?> get props => [
        cat.id,
        cat.allergies,
        events.length,
        events.map((e) => e.id).toList(),
        dueItems.map((d) => '${d.protocol.id}:${d.dueDate}').toList(),
        tabIndex,
        isSaving,
        errorTick,
      ];
}
