import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yucat/features/analytics/analytics_events.dart';
import 'package:yucat/features/analytics/domain/usecase/log_event_usecase.dart';
import 'package:yucat/features/cat/domain/entities/cat_entity.dart';
import 'package:yucat/features/cat/domain/usecases/update_cat_allergies_usecase.dart';
import 'package:yucat/features/health_carnet/domain/entities/health_event_entity.dart';
import 'package:yucat/features/health_carnet/domain/usecases/add_health_event_usecase.dart';
import 'package:yucat/features/health_carnet/domain/usecases/delete_health_event_usecase.dart';
import 'package:yucat/features/health_carnet/domain/usecases/get_health_events_usecase.dart';
import 'package:yucat/features/health_carnet/presentation/models/health_due_item.dart';
import 'package:yucat/features/health_carnet/presentation/utils/cat_health_schedule.dart';
import 'package:yucat/features/health_carnet/presentation/utils/health_events_cache.dart';

part 'health_carnet_event.dart';
part 'health_carnet_state.dart';

/// Owns one cat's carnet for the lifetime of one page push.
///
/// ⚠️ Deliberately **absent** from `main.dart`'s `MultiBlocProvider`, following
/// `FoodGuideBloc`/`ArticlesBloc` rather than the older root-provided blocs:
/// `HealthCarnetPage` resolves `sl<HealthCarnetBloc>()` in `initState` and
/// closes it in `dispose`. A root instance would carry one cat's records into
/// the next cat's carnet.
class HealthCarnetBloc extends Bloc<HealthCarnetEvent, HealthCarnetState> {
  final GetHealthEventsUsecase _getHealthEventsUsecase;
  final AddHealthEventUsecase _addHealthEventUsecase;
  final DeleteHealthEventUsecase _deleteHealthEventUsecase;
  final UpdateCatAllergiesUsecase _updateCatAllergiesUsecase;
  final LogEventUsecase _logEventUsecase;

  CatEntity? _cat;
  int _tabIndex = 0;

  HealthCarnetBloc({
    required GetHealthEventsUsecase getHealthEventsUsecase,
    required AddHealthEventUsecase addHealthEventUsecase,
    required DeleteHealthEventUsecase deleteHealthEventUsecase,
    required UpdateCatAllergiesUsecase updateCatAllergiesUsecase,
    required LogEventUsecase logEventUsecase,
  })  : _getHealthEventsUsecase = getHealthEventsUsecase,
        _addHealthEventUsecase = addHealthEventUsecase,
        _deleteHealthEventUsecase = deleteHealthEventUsecase,
        _updateCatAllergiesUsecase = updateCatAllergiesUsecase,
        _logEventUsecase = logEventUsecase,
        super(const HealthCarnetLoadingState()) {
    on<HealthCarnetInitialEvent>(_onInitial);
    on<HealthCarnetTabChanged>(_onTabChanged);
    on<HealthCarnetMarkDoneEvent>(_onMarkDone);
    on<HealthCarnetSnoozeEvent>(_onSnooze);
    on<HealthCarnetAddRecordEvent>(_onAddRecord);
    on<HealthCarnetSetupShownEvent>(_onSetupShown);
    on<HealthCarnetSetupCompletedEvent>(_onSetupCompleted);
    on<HealthCarnetDeleteRecordEvent>(_onDeleteRecord);
    on<HealthCarnetUpdateAllergiesEvent>(_onUpdateAllergies);
  }

  Future<void> _onInitial(
    HealthCarnetInitialEvent event,
    Emitter<HealthCarnetState> emit,
  ) async {
    _cat = event.cat;
    emit(const HealthCarnetLoadingState());

    final catId = event.cat.id;
    if (catId == null) {
      emit(const HealthCarnetErrorState());
      return;
    }

    try {
      final events = await _getHealthEventsUsecase.call(catId: catId);
      final loaded = _buildLoaded(cat: event.cat, events: events);

      _logEventUsecase.call(
        eventName: AnalyticsEvents.healthCarnetViewed,
        properties: {
          'record_count': events.length,
          'due_count': loaded.dueItems.length,
          'urgent_count': loaded.urgentCount,
          'has_weight_history': loaded.weightPoints.isNotEmpty,
          'cat_age_group': event.cat.ageGroup ?? 'unknown',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      emit(loaded);
    } catch (e) {
      _logEventUsecase.call(
        eventName: AnalyticsEvents.healthCarnetLoadFailed,
        properties: {
          'error_message': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      emit(const HealthCarnetErrorState());
    }
  }

  void _onTabChanged(
    HealthCarnetTabChanged event,
    Emitter<HealthCarnetState> emit,
  ) {
    final current = state;
    if (current is! HealthCarnetLoadedState) return;
    if (event.index < 0 || event.index >= _tabNames.length) return;
    _tabIndex = event.index;
    _logEventUsecase.call(
      eventName: AnalyticsEvents.healthCarnetTabChanged,
      properties: {
        'tab_index': event.index,
        'tab_name': _tabNames[event.index],
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
    emit(current.copyWith(tabIndex: event.index));
  }

  Future<void> _onMarkDone(
    HealthCarnetMarkDoneEvent event,
    Emitter<HealthCarnetState> emit,
  ) async {
    final item = event.item;
    // Protocol-backed records store an **empty title** on purpose: the timeline
    // renders them from `protocolId` through `healthProtocolName`, so a record
    // logged in French still reads correctly after the user switches to German.
    // Only freeform records carry a user-authored title.
    await _write(
      emit,
      HealthEventEntity(
        protocolId: item.protocol.id,
        category: item.protocol.category,
        title: '',
        status: HealthEventStatus.done,
        performedAt: event.performedAt,
      ),
      analyticsEvent: AnalyticsEvents.healthTaskCompleted,
      analyticsProperties: {
        'protocol_id': item.protocol.id,
        'obligation': item.protocol.obligation.name,
        // The pair that makes the whole feature measurable: completions are only
        // interesting relative to whether the app caught the act in time.
        'was_overdue': item.urgency == HealthUrgency.overdue,
        'urgency': item.urgency.wire,
        'days_until': item.daysUntil ?? 0,
        // Whole days between the act and the tap — 0 is "ticked off today".
        'logged_days_late':
            DateTime.now().difference(event.performedAt).inDays,
      },
    );
  }

  Future<void> _onSnooze(
    HealthCarnetSnoozeEvent event,
    Emitter<HealthCarnetState> emit,
  ) async {
    final item = event.item;
    final base = item.dueDate ?? DateTime.now();
    // Snoozing from a date already in the past would land the new date in the
    // past too, so an overdue item is pushed on from today instead.
    final from = base.isBefore(DateTime.now()) ? DateTime.now() : base;

    await _write(
      emit,
      HealthEventEntity(
        protocolId: item.protocol.id,
        category: item.protocol.category,
        title: '',
        status: HealthEventStatus.snoozed,
        dueAt: from.add(Duration(days: event.days)),
      ),
      // Snoozes are not history and must not accumulate: each one supersedes
      // the last, so the old rows are cleared rather than left to pile up in a
      // collection the user can't see or manage.
      supersedeSnoozesFor: item.protocol.id,
      analyticsEvent: AnalyticsEvents.healthTaskSnoozed,
      analyticsProperties: {
        'protocol_id': item.protocol.id,
        'snooze_days': event.days,
        'was_overdue': item.urgency == HealthUrgency.overdue,
      },
    );
  }

  Future<void> _onAddRecord(
    HealthCarnetAddRecordEvent event,
    Emitter<HealthCarnetState> emit,
  ) async {
    await _write(
      emit,
      event.draft,
      analyticsEvent: AnalyticsEvents.healthRecordAdded,
      analyticsProperties: {
        'protocol_id': event.draft.protocolId ?? 'freeform',
        'category': event.draft.category.wire,
        'has_notes': event.draft.notes != null,
        'has_weight': event.draft.weightKg != null,
        'has_vet': event.draft.vetName != null,
        'source': 'add_sheet',
      },
    );
  }

  void _onSetupShown(
    HealthCarnetSetupShownEvent event,
    Emitter<HealthCarnetState> emit,
  ) {
    _logEventUsecase.call(
      eventName: AnalyticsEvents.healthSetupShown,
      properties: {
        'source': event.source,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Writes the setup answers one after another and re-derives once.
  ///
  /// Not routed through [_write]: that helper appends to the state it captured
  /// at entry, so three concurrent calls would each emit a list missing the
  /// others' rows. A partial failure keeps what was saved and bumps the error
  /// tick, so the user sees the SnackBar over a carnet that already holds the
  /// records that did land.
  Future<void> _onSetupCompleted(
    HealthCarnetSetupCompletedEvent event,
    Emitter<HealthCarnetState> emit,
  ) async {
    final current = state;
    final cat = _cat;
    if (current is! HealthCarnetLoadedState || cat?.id == null) return;
    final catId = cat!.id!;

    if (event.drafts.isEmpty) {
      _logEventUsecase.call(
        eventName: AnalyticsEvents.healthSetupSkipped,
        properties: {
          'dismissed': event.dismissed,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      return;
    }

    emit(current.copyWith(isSaving: true));
    final events = [...current.events];
    var written = 0;
    var failed = false;
    for (final draft in event.drafts) {
      try {
        final saved = await _addHealthEventUsecase.call(
          catId: catId,
          event: draft,
        );
        events.add(saved);
        written += 1;
        _logEventUsecase.call(
          eventName: AnalyticsEvents.healthRecordAdded,
          properties: {
            'protocol_id': draft.protocolId ?? 'freeform',
            'category': draft.category.wire,
            'has_notes': false,
            'has_weight': false,
            'has_vet': false,
            'source': 'setup',
            'timestamp': DateTime.now().toIso8601String(),
          },
        );
      } catch (_) {
        failed = true;
        break;
      }
    }

    _logEventUsecase.call(
      eventName: AnalyticsEvents.healthSetupCompleted,
      properties: {
        'records_written': written,
        'records_answered': event.drafts.length,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    final loaded = _buildLoaded(cat: cat, events: events);
    emit(failed ? loaded.copyWith(bumpError: true) : loaded);
  }

  Future<void> _onDeleteRecord(
    HealthCarnetDeleteRecordEvent event,
    Emitter<HealthCarnetState> emit,
  ) async {
    final current = state;
    final cat = _cat;
    if (current is! HealthCarnetLoadedState || cat?.id == null) return;

    emit(current.copyWith(isSaving: true));
    try {
      await _deleteHealthEventUsecase.call(
        catId: cat!.id!,
        eventId: event.eventId,
      );
      final remaining =
          current.events.where((e) => e.id != event.eventId).toList();
      _logEventUsecase.call(
        eventName: AnalyticsEvents.healthRecordDeleted,
        properties: {'timestamp': DateTime.now().toIso8601String()},
      );
      emit(_buildLoaded(cat: cat, events: remaining));
    } catch (_) {
      emit(current.copyWith(isSaving: false, bumpError: true));
    }
  }

  Future<void> _onUpdateAllergies(
    HealthCarnetUpdateAllergiesEvent event,
    Emitter<HealthCarnetState> emit,
  ) async {
    final current = state;
    final cat = _cat;
    if (current is! HealthCarnetLoadedState || cat?.id == null) return;

    emit(current.copyWith(isSaving: true));
    try {
      await _updateCatAllergiesUsecase.call(
        catId: cat!.id!,
        allergies: event.allergies,
      );
      // The local cat is replaced so the card re-renders without a refetch, and
      // so anything downstream reading `state.cat` sees the new list.
      // `copyWith` keeps a null argument, so the empty list is passed as a
      // list, never as null — clearing every allergy must still land.
      _cat = cat.copyWith(allergies: List.of(event.allergies));
      _logEventUsecase.call(
        eventName: AnalyticsEvents.healthAllergiesUpdated,
        properties: {
          'allergen_count': event.allergies.length,
          'allergens': event.allergies,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      emit(current.copyWith(cat: _cat, isSaving: false));
    } catch (_) {
      emit(current.copyWith(isSaving: false, bumpError: true));
    }
  }

  /// Persists [draft], re-derives the schedule, and emits. Shared by every
  /// mutation so the "save → refresh → analytics" order can only be written
  /// once.
  Future<void> _write(
    Emitter<HealthCarnetState> emit,
    HealthEventEntity draft, {
    required String analyticsEvent,
    required Map<String, dynamic> analyticsProperties,
    String? supersedeSnoozesFor,
  }) async {
    final current = state;
    final cat = _cat;
    if (current is! HealthCarnetLoadedState || cat?.id == null) return;
    final catId = cat!.id!;

    emit(current.copyWith(isSaving: true));
    try {
      final saved = await _addHealthEventUsecase.call(
        catId: catId,
        event: draft,
      );

      var events = [...current.events, saved];

      if (supersedeSnoozesFor != null) {
        final stale = current.events.where(
          (e) =>
              e.protocolId == supersedeSnoozesFor &&
              e.status == HealthEventStatus.snoozed &&
              e.id != null,
        );
        for (final old in stale) {
          // Best-effort: a failed cleanup leaves a harmless extra row, and the
          // engine takes the furthest-out snooze anyway.
          try {
            await _deleteHealthEventUsecase.call(catId: catId, eventId: old.id!);
            events = events.where((e) => e.id != old.id).toList();
          } catch (_) {}
        }
      }

      _logEventUsecase.call(
        eventName: analyticsEvent,
        properties: {
          ...analyticsProperties,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      emit(_buildLoaded(cat: cat, events: events));
    } catch (_) {
      emit(current.copyWith(isSaving: false, bumpError: true));
    }
  }

  /// Re-derives everything the UI reads from the record list.
  ///
  /// The schedule is never stored — it is a pure function of history plus the
  /// profile — so every mutation funnels through here rather than patching a
  /// cached list of due items.
  HealthCarnetLoadedState _buildLoaded({
    required CatEntity cat,
    required List<HealthEventEntity> events,
  }) {
    final sorted = [...events];
    sorted.sort((a, b) {
      final da = a.effectiveDate;
      final db = b.effectiveDate;
      if (da == null && db == null) return 0;
      if (da == null) return 1;
      if (db == null) return -1;
      return db.compareTo(da);
    });

    // This bloc is the only writer, so it keeps Home's mirror current here —
    // every mutation funnels through this method.
    if (cat.id != null) cacheHealthEvents(cat.id!, sorted);

    return HealthCarnetLoadedState(
      cat: cat,
      events: sorted,
      dueItems: computeDueItems(
        cat: cat,
        history: sorted,
        now: DateTime.now(),
      ),
      weightPoints: weightSeries(sorted),
      tabIndex: _tabIndex,
    );
  }

  static const _tabNames = ['upcoming', 'history', 'calendar'];
}
