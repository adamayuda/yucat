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

/// "Marquer comme fait" — records the act as performed today, which advances
/// the protocol's next due date.
class HealthCarnetMarkDoneEvent extends HealthCarnetEvent {
  final HealthDueItem item;

  const HealthCarnetMarkDoneEvent({required this.item});

  @override
  List<Object?> get props => [item.protocol.id, item.dueDate];
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

  const HealthCarnetAddRecordEvent({required this.draft});

  @override
  List<Object?> get props => [draft.title, draft.performedAt, draft.protocolId];
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
