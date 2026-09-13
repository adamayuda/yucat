import 'package:yucat/features/cat/domain/entities/cat_entity.dart';
import 'package:yucat/features/health_carnet/presentation/models/health_due_item.dart';

/// What Home's health card shows: the single nearest dated act across every
/// cat, an invitation to set up a carnet that has no history yet, or — for a
/// household whose carnets are all set up and quiet — an all-clear.
///
/// Null (no card) only when there are no cats or every read failed. A quiet,
/// well-kept carnet used to earn no card at all; it now earns the all-clear,
/// so the carnet's door on the screen every user sees never disappears for
/// exactly the users who keep it best. Built by `resolveNextUp`.
sealed class HealthNextUp {
  final CatEntity cat;

  const HealthNextUp(this.cat);
}

/// The nearest dated item across all cats. [item] is never `toSchedule`.
class HealthNextUpDue extends HealthNextUp {
  final HealthDueItem item;

  /// Other items overdue or due within a month across the household, not
  /// counting [item] — the "+2 more" a multi-cat home needs to know the card
  /// is showing the tip of a list.
  final int othersDueCount;

  const HealthNextUpDue({
    required CatEntity cat,
    required this.item,
    this.othersDueCount = 0,
  }) : super(cat);
}

/// No cat has a dated item, and [cat] has no history at all — the setup sheet
/// is the next useful thing to do.
class HealthNextUpSetup extends HealthNextUp {
  const HealthNextUpSetup({required CatEntity cat}) : super(cat);
}

/// Every cat has history and nothing is due inside the horizon. [nextItem] is
/// the earliest act beyond it across the household, when one is known, and
/// [cat] is the cat it belongs to (else the first cat).
class HealthNextUpAllClear extends HealthNextUp {
  final HealthDueItem? nextItem;

  const HealthNextUpAllClear({required CatEntity cat, this.nextItem})
      : super(cat);
}
