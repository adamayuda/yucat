import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/cat/domain/entities/cat_entity.dart';
import 'package:yucat/features/cat/presentation/utils/cat_labels.dart';
import 'package:yucat/features/cat_listing/mappers/cat_model_to_entity.dart';
import 'package:yucat/features/cat_listing/models/cat_model.dart';
import 'package:yucat/features/health_carnet/presentation/bloc/health_carnet_bloc.dart';
import 'package:yucat/features/health_carnet/presentation/models/health_due_item.dart';
import 'package:yucat/features/health_carnet/presentation/utils/cat_health_schedule.dart';
import 'package:yucat/features/health_carnet/presentation/utils/health_date_format.dart';
import 'package:yucat/features/health_carnet/presentation/widgets/add_health_record_sheet.dart';
import 'package:yucat/features/health_carnet/presentation/widgets/allergies_card.dart';
import 'package:yucat/features/health_carnet/presentation/widgets/due_item_card.dart';
import 'package:yucat/features/health_carnet/presentation/widgets/ongoing_treatments_card.dart';
import 'package:yucat/features/health_carnet/presentation/widgets/health_calendar_grid.dart';
import 'package:yucat/features/health_carnet/presentation/widgets/health_carnet_skeleton.dart';
import 'package:yucat/features/health_carnet/presentation/widgets/health_summary_tiles.dart';
import 'package:yucat/features/health_carnet/presentation/widgets/health_timeline_tile.dart';
import 'package:yucat/features/health_carnet/presentation/widgets/weight_chart_card.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/ds_app_bar.dart';
import 'package:yucat/presentation/components/ds_card.dart';
import 'package:yucat/presentation/components/ds_pill_button.dart';
import 'package:yucat/presentation/components/ds_confirm_dialog.dart';
import 'package:yucat/presentation/components/ds_quote_card.dart';
import 'package:yucat/presentation/components/ds_segmented_control.dart';
import 'package:yucat/presentation/components/ds_state_view.dart';
import 'package:yucat/presentation/components/cat_avatar.dart';
import 'package:yucat/service_locator.dart';

/// The cat's health record: what is due, what has been done, and how the weight
/// has moved.
///
/// Per the mockups the header, summary tiles and segmented control scroll with
/// the content — only the "Add a record" CTA is pinned.
@RoutePage()
class HealthCarnetPage extends StatefulWidget {
  final CatModel cat;

  const HealthCarnetPage({super.key, required this.cat});

  @override
  State<HealthCarnetPage> createState() => _HealthCarnetPageState();
}

class _HealthCarnetPageState extends State<HealthCarnetPage> {
  late final HealthCarnetBloc _bloc;
  late final CatEntity _cat;

  @override
  void initState() {
    super.initState();
    // Own instance, closed in dispose — the `FoodGuideBloc`/`ArticlesBloc`
    // pattern. A root-provided bloc would leak one cat's records into the next.
    _bloc = sl<HealthCarnetBloc>();
    _cat = catEntityFromModel(widget.cat);
    _bloc.add(HealthCarnetInitialEvent(cat: _cat));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocConsumer<HealthCarnetBloc, HealthCarnetState>(
      bloc: _bloc,
      listenWhen: (previous, current) =>
          previous is HealthCarnetLoadedState &&
          current is HealthCarnetLoadedState &&
          previous.errorTick != current.errorTick,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.healthCarnetSaveError),
            backgroundColor: DSColors.accentDanger,
          ),
        );
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: DSColors.pageBackground,
          body: SafeArea(
            child: Column(
              children: [
                DSAppBar.modal(
                  onBack: () => Navigator.of(context).pop(),
                  actions: [
                    if (state is HealthCarnetLoadedState &&
                        state.lastRecordedAt != null)
                      Padding(
                        padding: const EdgeInsets.only(right: DSDimens.sizeXs),
                        child: Center(
                          child: Text(
                            l10n.healthCarnetUpdatedOn(
                              healthFormatDate(
                                state.lastRecordedAt!,
                                healthLocaleOf(context),
                              ),
                            ),
                            style: DSTextStyles.bodyMd,
                          ),
                        ),
                      ),
                  ],
                ),
                Expanded(child: _buildBody(context, state)),
                if (state is HealthCarnetLoadedState)
                  _AddRecordBar(
                    busy: state.isSaving,
                    onPressed: () => _openAddSheet(context),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, HealthCarnetState state) {
    final l10n = AppLocalizations.of(context);

    if (state is HealthCarnetLoadingState) {
      return const HealthCarnetSkeleton();
    }
    if (state is! HealthCarnetLoadedState) {
      // Returned bare: DSStateView already centres and pads itself, and the
      // extra wrapper only ate vertical room on a short screen.
      return DSStateView.error(
        body: l10n.healthCarnetErrorBody,
        ctaLabel: l10n.healthCarnetRetry,
        onCtaPressed: () => _bloc.add(HealthCarnetInitialEvent(cat: _cat)),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        DSDimens.sizeL,
        DSDimens.sizeS,
        DSDimens.sizeL,
        DSDimens.sizeL,
      ),
      children: [
        _Header(cat: state.cat),
        const SizedBox(height: DSDimens.sizeL),
        _summaryTiles(context, state),
        const SizedBox(height: DSDimens.sizeS),
        DSSegmentedControl(
          segments: [
            l10n.healthCarnetTabUpcoming,
            l10n.healthCarnetTabHistory,
            l10n.healthCarnetTabCalendar,
          ],
          selectedIndex: state.tabIndex,
          onSelected: (index) =>
              _bloc.add(HealthCarnetTabChanged(index: index)),
        ),
        const SizedBox(height: DSDimens.sizeS),
        ..._tabContent(context, state),
      ],
    );
  }

  Widget _summaryTiles(BuildContext context, HealthCarnetLoadedState state) {
    final l10n = AppLocalizations.of(context);
    final locale = healthLocaleOf(context);
    // The same buckets the chart draws, so "+0.3 kg since April" can never
    // disagree with the bars the user is looking at.
    final points = monthlyWeightBuckets(state.weightPoints);

    // Falls back to the profile weight so the tile is never empty for a cat that
    // has a weight on its profile but has not been weighed inside the carnet.
    final latest = state.latestWeightKg ?? state.cat.weight;
    final weightValue =
        latest == null ? '—' : '${healthFormatKg(latest, locale)} kg';

    String? delta;
    var positive = false;
    if (points.length >= 2) {
      final diff = points.last.kg - points.first.kg;
      positive = diff > 0;
      delta = l10n.healthCarnetWeightDelta(
        healthFormatKgDelta(diff, locale),
        healthFormatMonthShort(points.first.date, locale),
      );
    } else if (points.isEmpty) {
      delta = l10n.healthCarnetWeightNoData;
    }

    final urgent = state.urgentCount;
    return HealthSummaryTiles(
      weightValue: weightValue,
      weightDelta: delta,
      weightDeltaPositive: positive,
      todoCount: state.dueItems.length,
      todoCaption: urgent == 0
          ? l10n.healthCarnetTodoNone
          : l10n.healthCarnetTodoUrgent(urgent),
    );
  }

  List<Widget> _tabContent(
    BuildContext context,
    HealthCarnetLoadedState state,
  ) {
    final l10n = AppLocalizations.of(context);

    if (state.tabIndex == 1) return _historyTab(context, state);

    if (state.tabIndex == 2) {
      return [
        HealthCalendarView(
          history: state.history,
          dueItems: state.dueItems,
        ),
      ];
    }

    final ongoing = state.ongoingTreatments;

    return [
      if (state.dueItems.isEmpty)
        DSCard(
          padding: const EdgeInsets.all(DSDimens.sizeL),
          child: Text(
            l10n.healthCarnetUpcomingEmpty,
            style: DSTextStyles.bodyMd,
          ),
        )
      else
        for (final item in state.dueItems) ...[
          DueItemCard(
            item: item,
            busy: state.isSaving,
            onMarkDone: () => _bloc.add(HealthCarnetMarkDoneEvent(item: item)),
            onSnooze: () => _openSnoozeSheet(context, item),
          ),
          const SizedBox(height: DSDimens.sizeS),
        ],
      if (ongoing.isNotEmpty) ...[
        const SizedBox(height: DSDimens.sizeXs),
        OngoingTreatmentsCard(treatments: ongoing),
      ],
      const SizedBox(height: DSDimens.sizeL),
      AllergiesCard(
        allergyKeys: state.cat.allergies ?? const [],
        onEdit: () => _openAllergiesSheet(context, state),
      ),
      const SizedBox(height: DSDimens.sizeL),
      _disclaimer(l10n),
    ];
  }

  /// Weight trend over the recorded months, then the full timeline.
  ///
  /// Reads `state.history`, not `state.events`: `snoozed` rows are scheduling
  /// residue and would otherwise appear as acts the cat never had.
  List<Widget> _historyTab(
    BuildContext context,
    HealthCarnetLoadedState state,
  ) {
    final l10n = AppLocalizations.of(context);
    final buckets = monthlyWeightBuckets(state.weightPoints);
    final history = state.history;

    if (history.isEmpty) {
      return [
        DSCard(
          padding: const EdgeInsets.all(DSDimens.sizeL),
          child: Text(
            l10n.healthCarnetHistoryEmpty,
            style: DSTextStyles.bodyMd,
          ),
        ),
      ];
    }

    return [
      // One bar is a dot, not a trend — the chart only earns its space once
      // there are two months to compare.
      if (buckets.length >= 2) ...[
        WeightChartCard(buckets: buckets),
        const SizedBox(height: DSDimens.sizeL),
      ],
      Row(
        children: [
          Expanded(
            child: Text(
              l10n.healthCarnetHistoryTitle,
              style: DSTextStyles.titleMd,
            ),
          ),
          Text(
            l10n.healthCarnetHistoryCount(history.length),
            style: DSTextStyles.bodyMd.copyWith(color: DSColors.inkTertiary),
          ),
        ],
      ),
      const SizedBox(height: DSDimens.sizeS),
      for (var i = 0; i < history.length; i++)
        HealthTimelineTile(
          event: history[i],
          isLast: i == history.length - 1,
          onConfirmDelete: () => _confirmDelete(context, history[i].id!),
        ),
    ];
  }

  Future<void> _confirmDelete(BuildContext context, String eventId) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDSConfirmDialog(
      context,
      title: l10n.healthCarnetDeleteTitle,
      body: l10n.healthCarnetDeleteBody,
      confirmLabel: l10n.healthCarnetDeleteConfirm,
      cancelLabel: l10n.healthCarnetDeleteCancel,
    );
    if (confirmed != true) return;
    _bloc.add(HealthCarnetDeleteRecordEvent(eventId: eventId));
  }

  /// Every date on this screen is guidance derived from general veterinary
  /// protocols, not a prescription — and the app must never imply it knows what
  /// the user's country requires. The card says so, in place, once.
  Widget _disclaimer(AppLocalizations l10n) => DSQuoteCard(
        sourceTitle: l10n.healthCarnetDisclaimerTitle,
        body: l10n.healthCarnetDisclaimerBody,
        sourceLinkLabel: l10n.healthCarnetDisclaimerSource,
      );

  Future<void> _openAllergiesSheet(
    BuildContext context,
    HealthCarnetLoadedState state,
  ) async {
    final picked = await showAllergiesSheet(
      context,
      state.cat.allergies ?? const [],
    );
    if (picked == null) return;
    _bloc.add(HealthCarnetUpdateAllergiesEvent(allergies: picked));
  }

  Future<void> _openAddSheet(BuildContext context) async {
    final draft = await showAddHealthRecordSheet(context);
    if (draft == null) return;
    _bloc.add(HealthCarnetAddRecordEvent(draft: draft));
  }

  Future<void> _openSnoozeSheet(
    BuildContext context,
    HealthDueItem item,
  ) async {
    final days = await _showSnoozeSheet(context);
    if (days == null) return;
    _bloc.add(HealthCarnetSnoozeEvent(item: item, days: days));
  }
}

Future<int?> _showSnoozeSheet(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  return showModalBottomSheet<int>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => Container(
      decoration: const BoxDecoration(
        color: DSColors.surfaceCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(DSRadii.xl)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            DSDimens.sizeL,
            DSDimens.sizeS,
            DSDimens.sizeL,
            DSDimens.sizeL,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: DSColors.surfaceCardDim,
                    borderRadius: BorderRadius.circular(DSRadii.pill),
                  ),
                ),
              ),
              const SizedBox(height: DSDimens.sizeL),
              Text(l10n.healthCarnetSnoozeTitle, style: DSTextStyles.titleMd),
              const SizedBox(height: DSDimens.sizeS),
              _SnoozeOption(
                label: l10n.healthCarnetSnoozeWeek,
                onTap: () => Navigator.pop(sheetContext, 7),
              ),
              _SnoozeOption(
                label: l10n.healthCarnetSnoozeMonth,
                onTap: () => Navigator.pop(sheetContext, 30),
              ),
              _SnoozeOption(
                label: l10n.healthCarnetSnoozeThreeMonths,
                onTap: () => Navigator.pop(sheetContext, 91),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _SnoozeOption extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SnoozeOption({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DSRadii.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: DSDimens.sizeXs),
        child: Row(
          children: [
            const Icon(
              Icons.schedule_rounded,
              size: 20,
              color: DSColors.inkSecondary,
            ),
            const SizedBox(width: DSDimens.sizeXs),
            Text(label, style: DSTextStyles.bodyLg),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final CatEntity cat;

  const _Header({required this.cat});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final subtitle = [
      cat.name,
      if (cat.age != null) catFormatLifeStageFromMonths(cat.age!, l10n),
      if (cat.breed != null) cat.breed!,
    ].join(' · ');

    return Row(
      children: [
        CatAvatar(photoUrl: cat.profileImageUrl, size: 56),
        const SizedBox(width: DSDimens.sizeXs),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.healthCarnetTitle, style: DSTextStyles.headlineMd),
              const SizedBox(height: DSDimens.sizeXxxs),
              Text(
                subtitle,
                style: DSTextStyles.bodyMd,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AddRecordBar extends StatelessWidget {
  final bool busy;
  final VoidCallback onPressed;

  const _AddRecordBar({required this.busy, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        DSDimens.sizeL,
        DSDimens.sizeXxs,
        DSDimens.sizeL,
        DSDimens.sizeS,
      ),
      child: DSPillButton(
        label: l10n.healthCarnetAddCta,
        onPressed: busy ? null : onPressed,
        loading: busy,
        showChevron: false,
        leadingIcon: Icons.add_rounded,
      ),
    );
  }
}
