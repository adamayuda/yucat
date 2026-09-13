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

/// What the last failure was, so the page can word the SnackBar.
enum HealthCarnetErrorKind {
  /// A write or delete did not land.
  write,

  /// The record landed but its photo did not.
  attachment,
}

class HealthCarnetLoadedState extends HealthCarnetState {
  final CatEntity cat;

  /// Every record, most recent first.
  final List<HealthEventEntity> events;

  /// Derived, never stored — see `computeDueItems`.
  final List<HealthDueItem> dueItems;

  final List<WeightPoint> weightPoints;

  /// Medication courses running today — derived in `_buildLoaded` from the
  /// records, like [dueItems]. See `activeCourses`.
  final List<HealthCourse> courses;
  final int tabIndex;
  final bool isSaving;

  /// Increments per failed write so a `BlocListener` sees a state change and
  /// re-fires an identical SnackBar. Same trick as `CatCreateBloc.errorTick`.
  final int errorTick;
  final HealthCarnetErrorKind errorKind;

  const HealthCarnetLoadedState({
    required this.cat,
    required this.events,
    required this.dueItems,
    required this.weightPoints,
    this.courses = const [],
    this.tabIndex = 0,
    this.isSaving = false,
    this.errorTick = 0,
    this.errorKind = HealthCarnetErrorKind.write,
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

  /// The "à faire" figure: every dated item. `dueItems.length` would also
  /// count the undated "to schedule" rows, which turns the headline number
  /// into noise on a fresh carnet.
  int get actionableCount =>
      dueItems.where((d) => d.urgency.isActionable).length;

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
    HealthCarnetErrorKind errorKind = HealthCarnetErrorKind.write,
  }) {
    return HealthCarnetLoadedState(
      cat: cat ?? this.cat,
      events: events,
      dueItems: dueItems,
      weightPoints: weightPoints,
      courses: courses,
      tabIndex: tabIndex ?? this.tabIndex,
      isSaving: isSaving ?? this.isSaving,
      errorTick: bumpError ? errorTick + 1 : errorTick,
      errorKind: bumpError ? errorKind : this.errorKind,
    );
  }

  @override
  List<Object?> get props => [
        cat.id,
        cat.allergies,
        cat.vet?.name,
        cat.vet?.clinic,
        cat.vet?.phone,
        cat.vet?.address,
        cat.lifestyle,
        events.length,
        events.map((e) => e.id).toList(),
        dueItems.map((d) => '${d.protocol.id}:${d.dueDate}').toList(),
        courses.map((c) => '${c.event.id}:${c.daysLeft}').toList(),
        tabIndex,
        isSaving,
        errorTick,
        errorKind,
      ];
}
