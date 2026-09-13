import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yucat/config/routes/router.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/cat_listing/bloc/cat_listing_bloc.dart';
import 'package:yucat/features/cat_listing/models/cat_model.dart';
import 'package:yucat/features/cat_listing/widgets/add_cat_card.dart';
import 'package:yucat/features/cat_listing/widgets/cat_summary_card.dart';
import 'package:yucat/features/analytics/analytics_events.dart';
import 'package:yucat/features/analytics/domain/usecase/log_event_usecase.dart';
import 'package:yucat/features/cat_listing/mappers/cat_model_to_entity.dart';
import 'package:yucat/features/health_carnet/presentation/models/cat_health_summary.dart';
import 'package:yucat/features/health_carnet/presentation/utils/health_entry_analytics.dart';
import 'package:yucat/service_locator.dart';

class CatListingLoadedWidget extends StatelessWidget {
  final List<CatModel> cats;

  /// Carnet summaries keyed by cat id; a cat missing here shows no pill.
  final Map<String, CatHealthSummary> health;
  final VoidCallback onPressed;

  const CatListingLoadedWidget({
    super.key,
    required this.cats,
    this.health = const {},
    required this.onPressed,
  });

  /// The pill on a card: the shared "carnet door" event with this surface,
  /// then the carnet, then the usual unconditional refetch on return.
  Future<void> _openCarnet(
    BuildContext context,
    CatModel cat,
    CatHealthSummary summary,
  ) async {
    sl<LogEventUsecase>().call(
      eventName: AnalyticsEvents.homeHealthCardTapped,
      properties: healthEntryTapProperties(
        surface: HealthEntrySurface.catListing,
        state: healthEntryStateOf(summary),
        cat: catEntityFromModel(cat),
        item: summary.nearest,
      ),
    );
    await context.router.push(HealthCarnetRoute(cat: cat));
    if (context.mounted) {
      context.read<CatListingBloc>().add(const CatListingFetchCatsEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(
        DSDimens.sizeL,
        DSDimens.sizeS,
        DSDimens.sizeL,
        bottomInset + DSDimens.size5xl + DSDimens.sizeL,
      ),
      itemCount: cats.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: DSDimens.sizeXs),
      itemBuilder: (context, index) {
        if (index == cats.length) {
          return AddCatCard(onTap: onPressed);
        }
        final cat = cats[index];
        final summary = cat.id == null ? null : health[cat.id!];
        return CatSummaryCard(
          cat: cat,
          health: summary,
          onHealthTap:
              summary == null ? null : () => _openCarnet(context, cat, summary),
          onTap: () async {
            await context.router.push<bool>(CatDetailRoute(cat: cat));
            // Detail can delete the cat, change its photo in place, or hand
            // off to the edit wizard — refetch unconditionally rather than
            // thread a "changed" flag through every one of those exits.
            if (context.mounted) {
              context.read<CatListingBloc>().add(
                const CatListingFetchCatsEvent(),
              );
            }
          },
        );
      },
    );
  }
}
