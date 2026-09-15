import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yucat/features/analytics/analytics_events.dart';
import 'package:yucat/features/analytics/domain/usecase/log_event_usecase.dart';
import 'package:yucat/features/cat/domain/entities/cat_entity.dart';
import 'package:yucat/features/cat/domain/entities/cat_vet_contact.dart';
import 'package:yucat/features/cat/domain/usecases/update_cat_allergies_usecase.dart';
import 'package:yucat/features/cat/domain/usecases/update_cat_lifestyle_usecase.dart';
import 'package:yucat/features/cat/domain/usecases/update_cat_vet_usecase.dart';
import 'package:yucat/features/cat/domain/usecases/update_cat_weight_usecase.dart';
import 'package:yucat/features/cat/presentation/utils/cat_product_recommendations.dart';
import 'package:yucat/features/health_carnet/domain/entities/health_event_entity.dart';
import 'package:yucat/features/health_carnet/domain/repositories/health_carnet_repository.dart'
    show HealthAttachmentFailed;
import 'package:yucat/features/health_carnet/domain/usecases/add_health_event_usecase.dart';
import 'package:yucat/features/health_carnet/domain/usecases/delete_health_event_usecase.dart';
import 'package:yucat/features/health_carnet/domain/usecases/get_health_events_usecase.dart';
import 'package:yucat/features/health_carnet/presentation/models/health_due_item.dart';
import 'package:yucat/features/health_carnet/presentation/utils/cat_health_schedule.dart';
import 'package:yucat/features/health_carnet/presentation/utils/health_events_cache.dart';
import 'package:yucat/services/review_prompt_service.dart';

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
  final UpdateCatVetUsecase _updateCatVetUsecase;
  final UpdateCatLifestyleUsecase _updateCatLifestyleUsecase;
  final UpdateCatWeightUsecase _updateCatWeightUsecase;
  final LogEventUsecase _logEventUsecase;
  final ReviewPromptService _reviewPromptService;

  CatEntity? _cat;
  int _tabIndex = 0;

  HealthCarnetBloc({
    required GetHealthEventsUsecase getHealthEventsUsecase,
    required AddHealthEventUsecase addHealthEventUsecase,
    required DeleteHealthEventUsecase deleteHealthEventUsecase,
    required UpdateCatAllergiesUsecase updateCatAllergiesUsecase,
    required UpdateCatVetUsecase updateCatVetUsecase,
    required UpdateCatLifestyleUsecase updateCatLifestyleUsecase,
    required UpdateCatWeightUsecase updateCatWeightUsecase,
    required LogEventUsecase logEventUsecase,
    required ReviewPromptService reviewPromptService,
  })  : _getHealthEventsUsecase = getHealthEventsUsecase,
        _addHealthEventUsecase = addHealthEventUsecase,
        _deleteHealthEventUsecase = deleteHealthEventUsecase,
        _updateCatAllergiesUsecase = updateCatAllergiesUsecase,
        _updateCatVetUsecase = updateCatVetUsecase,
        _updateCatLifestyleUsecase = updateCatLifestyleUsecase,
        _updateCatWeightUsecase = updateCatWeightUsecase,
        _logEventUsecase = logEventUsecase,
        _reviewPromptService = reviewPromptService,
        super(const HealthCarnetLoadingState()) {
    on<HealthCarnetInitialEvent>(_onInitial);
    on<HealthCarnetTabChanged>(_onTabChanged);
    on<HealthCarnetMarkDoneEvent>(_onMarkDone);
    on<HealthCarnetSnoozeEvent>(_onSnooze);
    on<HealthCarnetAddRecordEvent>(_onAddRecord);
    on<HealthCarnetSetupShownEvent>(_onSetupShown);
    on<HealthCarnetSetupCompletedEvent>(_onSetupCompleted);
    on<HealthCarnetImportRecordsEvent>(_onImportRecords);
    on<HealthCarnetDeleteRecordEvent>(_onDeleteRecord);
    on<HealthCarnetUpdateAllergiesEvent>(_onUpdateAllergies);
    on<HealthCarnetUpdateVetEvent>(_onUpdateVet);
    on<HealthCarnetUpdateLifestyleEvent>(_onUpdateLifestyle);
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
          'lifestyle': event.cat.lifestyle ?? 'unknown',
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
    // Decided against the carnet *before* the write, so a back-dated weigh-in
    // typed in after today's is recognised as history.
    final before = state;
    final syncsWeight = before is HealthCarnetLoadedState &&
        isLatestWeighing(event.draft, before.events);
    final countBefore =
        before is HealthCarnetLoadedState ? before.events.length : 0;

    await _write(
      emit,
      event.draft,
      attachment: event.attachment,
      analyticsEvent: AnalyticsEvents.healthRecordAdded,
      analyticsProperties: {
        'protocol_id': event.draft.protocolId ?? 'freeform',
        'category': event.draft.category.wire,
        'has_notes': event.draft.notes != null,
        'has_weight': event.draft.weightKg != null,
        'has_vet': event.draft.vetName != null,
        'has_attachment': event.attachment != null,
        'is_course': event.draft.courseEndAt != null,
        'source': 'add_sheet',
        'syncs_profile_weight': syncsWeight,
      },
    );

    final after = state;
    final written =
        after is HealthCarnetLoadedState && after.events.length > countBefore;
    if (syncsWeight && written) await _syncProfileWeight(event.draft, emit);
  }

  /// A weigh-in that is the carnet's newest becomes the profile's `weight` —
  /// the number `cat_product_assessment.dart` and the diet tips read, which
  /// until now was a snapshot from the wizard that never moved. Best-effort:
  /// the record is already saved, and a failed profile write only leaves the
  /// snapshot one weigh-in stale. The owner's body-condition answer
  /// (`weightCategory`) is theirs and is not touched.
  Future<void> _syncProfileWeight(
    HealthEventEntity draft,
    Emitter<HealthCarnetState> emit,
  ) async {
    final cat = _cat;
    final kg = draft.weightKg;
    if (cat?.id == null || kg == null || cat!.weight == kg) return;
    try {
      await _updateCatWeightUsecase.call(catId: cat.id!, weight: kg);
      _cat = cat.copyWith(weight: kg);
      // Picks are ranked on the profile, and the profile just changed.
      invalidateProductPicksCache(cat.id);
      _logEventUsecase.call(
        eventName: AnalyticsEvents.catProfileUpdated,
        properties: {
          'cat_name': cat.name,
          'cat_age_group': cat.ageGroup ?? 'unknown',
          'cat_breed': cat.breed ?? 'unknown',
          'fields_changed': const ['weight'],
          'source': 'health_carnet',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      final current = state;
      if (current is HealthCarnetLoadedState) {
        emit(current.copyWith(cat: _cat));
      }
    } catch (_) {
      // The weigh-in itself landed; the profile catches up on the next one.
    }
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
    final initial = _cat;
    if (current is! HealthCarnetLoadedState || initial?.id == null) return;
    var cat = initial!;
    final catId = cat.id!;

    // Lifestyle first: it changes which protocols the records below feed, so
    // the schedule derived at the end must already know it. Best-effort — a
    // failed write here must not cost the three dates.
    var lifestyleChanged = false;
    if (event.lifestyle != null && event.lifestyle != cat.lifestyle) {
      try {
        await _updateCatLifestyleUsecase.call(
          catId: catId,
          lifestyle: event.lifestyle,
        );
        cat = cat.copyWith(lifestyle: event.lifestyle);
        _cat = cat;
        lifestyleChanged = true;
        _logLifestyleUpdated(event.lifestyle!, source: 'setup');
      } catch (_) {
        // Fall through; the records still get written.
      }
    }

    if (event.drafts.isEmpty) {
      _logEventUsecase.call(
        eventName: AnalyticsEvents.healthSetupSkipped,
        properties: {
          'dismissed': event.dismissed,
          'lifestyle_answered': event.lifestyle != null,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      if (lifestyleChanged) emit(_buildLoaded(cat: cat, events: current.events));
      return;
    }

    emit(current.copyWith(cat: cat, isSaving: true));
    final (:events, :written, :failed) = await _writeSequentially(
      catId: catId,
      existing: current.events,
      drafts: event.drafts,
      source: 'setup',
    );

    _logEventUsecase.call(
      eventName: AnalyticsEvents.healthSetupCompleted,
      properties: {
        'records_written': written,
        'records_answered': event.drafts.length,
        'lifestyle_answered': event.lifestyle != null,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    final loaded = _buildLoaded(cat: cat, events: events);
    emit(failed ? loaded.copyWith(bumpError: true) : loaded);
    _promptForReview(written, ReviewTrigger.healthSetupCompleted);
  }

  /// A carnet that just filled up is a positive moment — but only if something
  /// actually landed; a failed write ends on an error SnackBar, not a success.
  void _promptForReview(int written, String trigger) {
    if (written == 0) return;
    unawaited(_reviewPromptService.recordPositiveMoment(trigger: trigger));
  }

  /// Records the owner accepted from a booklet page. Same sequential loop as
  /// the setup, for the same reason: parallel add events would each append
  /// to the state they captured and the emitted list would lose rows.
  Future<void> _onImportRecords(
    HealthCarnetImportRecordsEvent event,
    Emitter<HealthCarnetState> emit,
  ) async {
    final current = state;
    final cat = _cat;
    if (current is! HealthCarnetLoadedState || cat?.id == null) return;
    if (event.drafts.isEmpty) return;

    emit(current.copyWith(isSaving: true));
    final (:events, :written, :failed) = await _writeSequentially(
      catId: cat!.id!,
      existing: current.events,
      drafts: event.drafts,
      source: 'booklet',
    );

    _logEventUsecase.call(
      eventName: AnalyticsEvents.healthBookletImported,
      properties: {
        'records_proposed': event.proposedCount,
        'records_accepted': event.drafts.length,
        'records_written': written,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    final loaded = _buildLoaded(cat: cat, events: events);
    emit(failed ? loaded.copyWith(bumpError: true) : loaded);
    _promptForReview(written, ReviewTrigger.healthBookletImported);
  }

  /// Writes [drafts] one after another, appending each saved record to a
  /// copy of [existing]. Stops at the first failure and reports it; what
  /// landed before it is kept. One `Health Record Added { source }` per row.
  Future<({List<HealthEventEntity> events, int written, bool failed})>
      _writeSequentially({
    required String catId,
    required List<HealthEventEntity> existing,
    required List<HealthEventEntity> drafts,
    required String source,
  }) async {
    final events = [...existing];
    var written = 0;
    var failed = false;
    for (final draft in drafts) {
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
            'has_notes': draft.notes != null,
            'has_weight': draft.weightKg != null,
            'has_vet': draft.vetName != null,
            'source': source,
            'timestamp': DateTime.now().toIso8601String(),
          },
        );
      } catch (_) {
        failed = true;
        break;
      }
    }
    return (events: events, written: written, failed: failed);
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

  void _logLifestyleUpdated(String lifestyle, {required String source}) {
    _logEventUsecase.call(
      eventName: AnalyticsEvents.healthLifestyleUpdated,
      properties: {
        'lifestyle': lifestyle,
        'source': source,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Unlike allergies and the vet, lifestyle changes the **schedule** — so the
  /// state is rebuilt through [_buildLoaded], not patched with `copyWith`.
  Future<void> _onUpdateLifestyle(
    HealthCarnetUpdateLifestyleEvent event,
    Emitter<HealthCarnetState> emit,
  ) async {
    final current = state;
    final cat = _cat;
    if (current is! HealthCarnetLoadedState || cat?.id == null) return;
    if (event.lifestyle == cat!.lifestyle) return;

    emit(current.copyWith(isSaving: true));
    try {
      await _updateCatLifestyleUsecase.call(
        catId: cat.id!,
        lifestyle: event.lifestyle,
      );
      _cat = event.lifestyle == null
          ? cat.copyWith(clearLifestyle: true)
          : cat.copyWith(lifestyle: event.lifestyle);
      if (event.lifestyle != null) {
        _logLifestyleUpdated(event.lifestyle!, source: 'row');
      }
      emit(_buildLoaded(cat: _cat!, events: current.events));
    } catch (_) {
      emit(current.copyWith(isSaving: false, bumpError: true));
    }
  }

  /// Same shape as [_onUpdateAllergies]: a cat-document write, then the local
  /// cat is swapped so the card re-renders without a refetch. An empty
  /// contact is a removal — the sheet returns one for "Remove vet" and for a
  /// save with every field blank.
  Future<void> _onUpdateVet(
    HealthCarnetUpdateVetEvent event,
    Emitter<HealthCarnetState> emit,
  ) async {
    final current = state;
    final cat = _cat;
    if (current is! HealthCarnetLoadedState || cat?.id == null) return;

    final vet = event.vet == null || event.vet!.isEmpty ? null : event.vet;
    emit(current.copyWith(isSaving: true));
    try {
      await _updateCatVetUsecase.call(catId: cat!.id!, vet: vet);
      _cat = vet == null ? cat.copyWith(clearVet: true) : cat.copyWith(vet: vet);
      _logEventUsecase.call(
        eventName: AnalyticsEvents.healthVetUpdated,
        properties: {
          'cleared': vet == null,
          'has_phone': (vet?.phone ?? '').trim().isNotEmpty,
          'has_address': (vet?.address ?? '').trim().isNotEmpty,
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
    File? attachment,
  }) async {
    final current = state;
    final cat = _cat;
    if (current is! HealthCarnetLoadedState || cat?.id == null) return;
    final catId = cat!.id!;

    emit(current.copyWith(isSaving: true));
    try {
      HealthEventEntity saved;
      var attachmentFailed = false;
      try {
        saved = await _addHealthEventUsecase.call(
          catId: catId,
          event: draft,
          attachment: attachment,
        );
      } on HealthAttachmentFailed catch (e) {
        // The record is in; only the photo is missing. Keep the row and say
        // so, rather than reporting a failure for a write that succeeded.
        saved = e.saved;
        attachmentFailed = true;
      }

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
          if (attachment != null) 'attachment_uploaded': !attachmentFailed,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      final loaded = _buildLoaded(cat: cat, events: events);
      emit(attachmentFailed
          ? loaded.copyWith(
              bumpError: true,
              errorKind: HealthCarnetErrorKind.attachment,
            )
          : loaded);
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

    // Carry the error tick across rebuilds: a fresh state at tick 0 would let
    // a second failure land on the same number the page already showed.
    final previous = state;
    return HealthCarnetLoadedState(
      cat: cat,
      events: sorted,
      dueItems: computeDueItems(
        cat: cat,
        history: sorted,
        now: DateTime.now(),
      ),
      weightPoints: weightSeries(sorted),
      courses: activeCourses(sorted, DateTime.now()),
      tabIndex: _tabIndex,
      errorTick: previous is HealthCarnetLoadedState ? previous.errorTick : 0,
    );
  }

  static const _tabNames = ['upcoming', 'history', 'calendar'];
}
