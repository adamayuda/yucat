import 'package:flutter/material.dart';
import 'package:mixpanel_flutter_session_replay/mixpanel_flutter_session_replay.dart'
    show MixpanelMask;
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/analytics/analytics_events.dart';
import 'package:yucat/features/analytics/domain/usecase/log_event_usecase.dart';
import 'package:yucat/features/health_carnet/domain/entities/health_booklet_proposal.dart';
import 'package:yucat/features/health_carnet/domain/entities/health_event_entity.dart';
import 'package:yucat/features/health_carnet/domain/usecases/read_health_booklet_usecase.dart';
import 'package:yucat/features/health_carnet/presentation/utils/health_date_format.dart';
import 'package:yucat/features/health_carnet/presentation/utils/health_labels.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/ds_option_row.dart';
import 'package:yucat/presentation/components/ds_pill_button.dart';
import 'package:yucat/service_locator.dart';

/// Reads the booklet page and shows what it found, one toggleable row per act.
///
/// Returns the accepted drafts to write (possibly empty), or null when
/// dismissed or nothing could be read. The read happens *inside* the sheet so
/// the page has one call site and the loading state has somewhere to live;
/// the write stays the bloc's job, sequentially, like the setup sheet.
Future<List<HealthEventEntity>?> showHealthBookletReviewSheet(
  BuildContext context, {
  required String imageBase64,
  required String catName,
}) {
  return showModalBottomSheet<List<HealthEventEntity>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _BookletReviewSheet(
      imageBase64: imageBase64,
      catName: catName,
    ),
  );
}

class _BookletReviewSheet extends StatefulWidget {
  final String imageBase64;
  final String catName;

  const _BookletReviewSheet({
    required this.imageBase64,
    required this.catName,
  });

  @override
  State<_BookletReviewSheet> createState() => _BookletReviewSheetState();
}

class _BookletReviewSheetState extends State<_BookletReviewSheet> {
  HealthBookletProposal? _proposal;
  bool _failed = false;
  late List<HealthBookletRecord> _records;
  late List<bool> _accepted;

  @override
  void initState() {
    super.initState();
    _read();
  }

  Future<void> _read() async {
    setState(() {
      _proposal = null;
      _failed = false;
    });
    final started = DateTime.now();
    try {
      final proposal = await sl<ReadHealthBookletUsecase>()(
        imageBase64: widget.imageBase64,
        today: DateTime.now(),
        catName: widget.catName,
      );
      sl<LogEventUsecase>().call(
        eventName: AnalyticsEvents.healthBookletScanned,
        properties: {
          'outcome': proposal.outcome.name,
          'records_proposed': proposal.records.length,
          'low_confidence': proposal.records
              .where((r) => r.confidence == HealthBookletConfidence.low)
              .length,
          'duration_ms': DateTime.now().difference(started).inMilliseconds,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      if (!mounted) return;
      setState(() {
        _proposal = proposal;
        _records = List.of(proposal.records);
        _accepted = _records.map((r) => r.acceptedByDefault).toList();
      });
    } catch (e) {
      sl<LogEventUsecase>().call(
        eventName: AnalyticsEvents.healthBookletScanned,
        properties: {
          'outcome': 'error',
          'error_message': e.toString(),
          'records_proposed': 0,
          'duration_ms': DateTime.now().difference(started).inMilliseconds,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      if (!mounted) return;
      setState(() => _failed = true);
    }
  }

  Future<void> _editDate(int index) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _records[index].performedAt,
      firstDate: DateTime(now.year - 25),
      lastDate: now,
    );
    if (!mounted || picked == null) return;
    setState(() {
      _records[index] = _records[index].copyWith(performedAt: picked);
      _accepted[index] = true;
    });
  }

  void _submit() {
    final drafts = <HealthEventEntity>[];
    for (var i = 0; i < _records.length; i++) {
      if (_accepted[i]) drafts.add(_records[i].toDraft());
    }
    Navigator.of(context).pop(drafts);
  }

  int get _acceptedCount => _accepted.where((a) => a).length;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final media = MediaQuery.of(context);
    return Container(
      constraints: BoxConstraints(maxHeight: media.size.height * 0.9),
      decoration: const BoxDecoration(
        color: DSColors.surfaceCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(DSRadii.xl)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: DSDimens.sizeS),
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
            Flexible(child: _body(l10n)),
          ],
        ),
      ),
    );
  }

  Widget _body(AppLocalizations l10n) {
    if (_failed) return _message(l10n.healthBookletError, retry: true);
    final proposal = _proposal;
    if (proposal == null) {
      return Padding(
        padding: const EdgeInsets.all(DSDimens.size3xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: DSColors.accentInfo),
            const SizedBox(height: DSDimens.sizeL),
            Text(l10n.healthBookletReading, style: DSTextStyles.bodyLg),
          ],
        ),
      );
    }
    return switch (proposal.outcome) {
      HealthBookletOutcome.unreadable =>
        _message(l10n.healthBookletUnreadable, retry: false),
      HealthBookletOutcome.notBooklet =>
        _message(l10n.healthBookletNotBooklet, retry: false),
      HealthBookletOutcome.records => _records.isEmpty
          ? _message(l10n.healthBookletNone, retry: false)
          : _review(l10n),
    };
  }

  Widget _message(String text, {required bool retry}) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        DSDimens.sizeL,
        DSDimens.sizeL,
        DSDimens.sizeL,
        DSDimens.sizeL,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(text, style: DSTextStyles.bodyLg),
          const SizedBox(height: DSDimens.sizeL),
          if (retry)
            DSPillButton(
              label: l10n.healthBookletTryAgain,
              showChevron: false,
              onPressed: _read,
            )
          else
            DSPillButton(
              label: l10n.commonGoBack,
              showChevron: false,
              onPressed: () => Navigator.of(context).pop(),
            ),
        ],
      ),
    );
  }

  Widget _review(AppLocalizations l10n) {
    final locale = healthLocaleOf(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              DSDimens.sizeL,
              DSDimens.sizeL,
              DSDimens.sizeL,
              DSDimens.sizeS,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.healthBookletReviewTitle, style: DSTextStyles.titleMd),
                const SizedBox(height: DSDimens.sizeXxs),
                Text(
                  l10n.healthBookletReviewIntro,
                  style: DSTextStyles.bodyMd.copyWith(
                    color: DSColors.inkSecondary,
                  ),
                ),
                const SizedBox(height: DSDimens.sizeS),
                for (var i = 0; i < _records.length; i++) ...[
                  _row(i, l10n, locale),
                  const SizedBox(height: DSDimens.sizeXxs),
                ],
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            DSDimens.sizeL,
            DSDimens.sizeXxs,
            DSDimens.sizeL,
            DSDimens.sizeS,
          ),
          child: DSPillButton(
            label: l10n.healthBookletAdd(_acceptedCount),
            showChevron: false,
            onPressed: _acceptedCount == 0 ? null : _submit,
          ),
        ),
      ],
    );
  }

  Widget _row(int i, AppLocalizations l10n, String locale) {
    final record = _records[i];
    final name = record.protocolId != null
        ? healthProtocolName(record.protocolId!, l10n)
        : record.title;
    final parts = [
      healthFormatDate(record.performedAt, locale),
      if (record.vet != null || record.clinic != null)
        [record.vet, record.clinic].whereType<String>().join(' · '),
      if (record.confidence == HealthBookletConfidence.low)
        l10n.healthBookletLowConfidence,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Vet and clinic came off a stamp — the owner's data, masked like
        // the timeline's attribution line.
        MixpanelMask(
          child: DSOptionRow(
            label: name,
            description: parts.join(' · '),
            leadingIcon: healthCategoryIcon(record.category),
            selected: _accepted[i],
            showTrailingCheck: true,
            onTap: () => setState(() => _accepted[i] = !_accepted[i]),
          ),
        ),
        DSTextLink(
          label: l10n.healthBookletEditDate,
          onPressed: () => _editDate(i),
        ),
      ],
    );
  }
}
