import 'package:yucat/features/cat/domain/entities/cat_entity.dart';
import 'package:yucat/features/health_carnet/presentation/models/health_due_item.dart';

/// What Home's "Next up" card shows: the single nearest dated act across every
/// cat, or an invitation to set up a carnet that has no history yet.
///
/// Null (no card) when there are no cats, when every read failed, or when every
/// carnet is set up and nothing falls inside the 12-month horizon — a well-kept
/// carnet earns a quiet Home, not a placeholder.
sealed class HealthNextUp {
  final CatEntity cat;

  const HealthNextUp(this.cat);
}

/// The nearest dated item across all cats. [item] is never `toSchedule`.
class HealthNextUpDue extends HealthNextUp {
  final HealthDueItem item;

  const HealthNextUpDue({required CatEntity cat, required this.item})
      : super(cat);
}

/// No cat has a dated item, and [cat] has no history at all — the setup sheet
/// is the next useful thing to do.
class HealthNextUpSetup extends HealthNextUp {
  const HealthNextUpSetup({required CatEntity cat}) : super(cat);
}
