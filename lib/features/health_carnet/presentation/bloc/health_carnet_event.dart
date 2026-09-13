part of 'health_carnet_bloc.dart';

sealed class HealthCarnetEvent extends Equatable {
  const HealthCarnetEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the carnet. Also fired by the error state's retry.
class HealthCarnetInitialEvent extends HealthCarnetEvent {
  final CatEntity cat;

  const HealthCarnetInitialEvent({required this.cat});

  @override
  List<Object?> get props => [cat.id];
}

class HealthCarnetTabChanged extends HealthCarnetEvent {
  final int index;

  const HealthCarnetTabChanged({required this.index});

  @override
  List<Object?> get props => [index];
}

/// "Marquer comme fait" — records the act as performed on [performedAt], which
/// advances the protocol's next due date from that day.
///
/// The date is asked for, not assumed: a vaccine given three weeks ago and
/// ticked off today would otherwise push every later due date three weeks late,
/// and getting that date right is the whole point of the carnet.
class HealthCarnetMarkDoneEvent extends HealthCarnetEvent {
  final HealthDueItem item;
  final DateTime performedAt;

  const HealthCarnetMarkDoneEvent({
    required this.item,
    required this.performedAt,
  });

  @override
  List<Object?> get props => [item.protocol.id, item.dueDate, performedAt];
}

/// The setup sheet was presented — by itself on first open (`auto`) or from
/// the standing card (`card`). Analytics only.
class HealthCarnetSetupShownEvent extends HealthCarnetEvent {
  final String source;

  const HealthCarnetSetupShownEvent({required this.source});

  @override
  List<Object?> get props => [source];
}

/// The setup sheet closed. [drafts] holds one `done` record per answered
/// question (empty when every step was skipped); [dismissed] is a barrier
/// dismiss rather than a walk-through.
///
/// One event, written sequentially — three `HealthCarnetAddRecordEvent`s fired
/// back to back would each append to the state they captured at entry and the
/// emitted list would lose rows (Firestore would keep all three; the UI would
/// show one until reload).
class HealthCarnetSetupCompletedEvent extends HealthCarnetEvent {
  final List<HealthEventEntity> drafts;

  /// `CatLifestyle.indoor` / `.outdoor` when the fourth step was answered.
  /// Written **before** the drafts: it changes which protocols they feed.
  final String? lifestyle;
  final bool dismissed;

  const HealthCarnetSetupCompletedEvent({
    required this.drafts,
    this.lifestyle,
    this.dismissed = false,
  });

  @override
  List<Object?> get props => [drafts.length, lifestyle, dismissed];
}

/// Replaces the cat's lifestyle on the **cat document** and re-derives the
/// schedule. Null clears it.
class HealthCarnetUpdateLifestyleEvent extends HealthCarnetEvent {
  final String? lifestyle;

  const HealthCarnetUpdateLifestyleEvent({required this.lifestyle});

  @override
  List<Object?> get props => [lifestyle];
}

/// "Reporter" — pushes this one occurrence back without touching history.
class HealthCarnetSnoozeEvent extends HealthCarnetEvent {
  final HealthDueItem item;
  final int days;

  const HealthCarnetSnoozeEvent({required this.item, required this.days});

  @override
  List<Object?> get props => [item.protocol.id, days];
}

class HealthCarnetAddRecordEvent extends HealthCarnetEvent {
  final HealthEventEntity draft;

  /// The photo to attach, uploaded after the record is written. Never on the
  /// entity: a `File` is a device-local handle, not record data.
  final File? attachment;

  const HealthCarnetAddRecordEvent({required this.draft, this.attachment});

  @override
  List<Object?> get props =>
      [draft.title, draft.performedAt, draft.protocolId, attachment?.path];
}

class HealthCarnetDeleteRecordEvent extends HealthCarnetEvent {
  final String eventId;

  const HealthCarnetDeleteRecordEvent({required this.eventId});

  @override
  List<Object?> get props => [eventId];
}

/// Replaces the cat's declared allergies. Writes to the **cat document**, not to
/// `health_events` — allergies are profile data the assessment engine reads, not
/// a dated act.
class HealthCarnetUpdateAllergiesEvent extends HealthCarnetEvent {
  final List<String> allergies;

  const HealthCarnetUpdateAllergiesEvent({required this.allergies});

  @override
  List<Object?> get props => [allergies];
}

/// Replaces the cat's vet contact on the **cat document**. Null or an empty
/// contact removes it.
class HealthCarnetUpdateVetEvent extends HealthCarnetEvent {
  final CatVetContact? vet;

  const HealthCarnetUpdateVetEvent({required this.vet});

  @override
  List<Object?> get props => [vet?.name, vet?.clinic, vet?.phone, vet?.address];
}

/// The rows the owner ticked in the booklet review sheet, written
/// sequentially like the setup's answers. [proposedCount] is what the reader
/// offered, for the accept-rate analytics.
class HealthCarnetImportRecordsEvent extends HealthCarnetEvent {
  final List<HealthEventEntity> drafts;
  final int proposedCount;

  const HealthCarnetImportRecordsEvent({
    required this.drafts,
    required this.proposedCount,
  });

  @override
  List<Object?> get props => [drafts.length, proposedCount];
}
