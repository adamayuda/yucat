import 'package:auto_route/auto_route.dart';
import 'package:yucat/config/build_env.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yucat/config/routes/router.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/core/legal_urls.dart';
import 'package:yucat/features/analytics/domain/usecase/log_event_usecase.dart';
import 'package:yucat/features/cat/domain/entities/cat_entity.dart';
import 'package:yucat/features/cat_listing/mappers/cat_entity_to_model_mapper.dart';
import 'package:yucat/features/health_carnet/presentation/models/cat_health_summary.dart';
import 'package:yucat/features/health_carnet/presentation/utils/health_entry_analytics.dart';
import 'package:yucat/features/health_carnet/presentation/widgets/health_cat_picker_sheet.dart';
import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';
import 'package:yucat/features/product_detail/presentation/widgets/hatched_placeholder.dart';
import 'package:yucat/features/profile/bloc/profile_bloc.dart';
import 'package:yucat/features/profile/bloc/profile_event.dart';
import 'package:yucat/features/profile/bloc/profile_state.dart';
import 'package:yucat/features/profile/widgets/profile_skeleton.dart';
import 'package:yucat/l10n/app_localizations.dart';
import 'package:yucat/presentation/components/cat_avatar.dart';
import 'package:yucat/presentation/components/ds_bottom_nav.dart';
import 'package:yucat/presentation/components/ds_card.dart';
import 'package:yucat/presentation/components/ds_confirm_dialog.dart';
import 'package:yucat/service_locator.dart';
import 'package:yucat/features/litter_detail/presentation/models/litter_display_model.dart';
import 'package:yucat/features/analytics/analytics_events.dart';

@RoutePage()
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePage();
}

class _ProfilePage extends State<ProfilePage> {
  late ProfileBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<ProfileBloc>();
    _bloc.add(ProfileInitialEvent());
  }

  Future<void> _launchUri(Uri uri,
      {String? errorMessage,
      LaunchMode mode = LaunchMode.platformDefault}) async {
    final fallbackMessage = errorMessage ?? AppLocalizations.of(context).profileLinkError;
    try {
      if (!await launchUrl(uri, mode: mode)) {
        _showSnack(fallbackMessage);
      }
    } catch (_) {
      _showSnack(fallbackMessage);
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _openCatDetail(CatEntity cat) async {
    sl<LogEventUsecase>().call(
      eventName: AnalyticsEvents.profileCatTapped,
      properties: {
        'cat_id': cat.id,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
    final model = sl<CatEntityToModelMapper>()(cat);
    await context.router.push(CatDetailRoute(cat: model));
    _bloc.add(ProfileInitialEvent());
  }

  Future<void> _openCreateCat() async {
    await context.router.push(CreateCatRoute());
    _bloc.add(ProfileInitialEvent());
  }

  Future<void> _openManageCats() async {
    await context.router.push(const CatListingRoute());
    _bloc.add(ProfileInitialEvent());
  }

  /// The Health row. One cat opens its carnet directly; several ask which.
  /// The shared "carnet door" event fires once the cat is known, so `state`
  /// describes the carnet actually opened, and the row re-derives on return.
  Future<void> _openHealth(List<CatHealthSummary> health) async {
    if (health.isEmpty) return;
    CatHealthSummary? chosen;
    if (health.length == 1) {
      chosen = health.first;
    } else {
      final cat = await showHealthCatPickerSheet(context, summaries: health);
      if (cat == null) return;
      for (final summary in health) {
        if (summary.cat.id == cat.id) chosen = summary;
      }
    }
    if (chosen == null || !mounted) return;
    var dueSoon = 0;
    for (final summary in health) {
      dueSoon += summary.dueSoonCount;
    }
    sl<LogEventUsecase>().call(
      eventName: AnalyticsEvents.homeHealthCardTapped,
      properties: healthEntryTapProperties(
        surface: HealthEntrySurface.profile,
        state: healthEntryStateOf(chosen),
        cat: chosen.cat,
        item: chosen.nearest,
        extra: {'cats_count': health.length, 'due_soon_count': dueSoon},
      ),
    );
    final model = sl<CatEntityToModelMapper>()(chosen.cat);
    await context.router.push(HealthCarnetRoute(cat: model));
    if (!mounted) return;
    _bloc.add(ProfileInitialEvent());
  }

  void _openSavedProducts() {
    context.router.push(const SavedProductsRoute());
  }

  void _openScanHistory() {
    sl<LogEventUsecase>().call(
      eventName: AnalyticsEvents.scanHistoryViewed,
      properties: {'timestamp': DateTime.now().toIso8601String()},
    );
    context.router.push(const ScanHistoryRoute());
  }

  Future<void> _confirmResetTestUser(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDSConfirmDialog(
      context,
      title: l10n.profileResetTestUserConfirmTitle,
      body: l10n.profileResetTestUserConfirmBody,
      confirmLabel: l10n.profileResetTestUserConfirm,
      cancelLabel: l10n.commonGoBack,
      icon: Icons.person_off_outlined,
    );
    if (ok == true && context.mounted) {
      _bloc.add(ResetTestUserTapEvent(context: context));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<ProfileBloc, ProfileState>(
      bloc: _bloc,
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) => switch (state) {
        ProfileLoadedState(
          :final cats,
          :final health,
          :final savedProducts,
          :final savedLitters,
          :final scanHistory,
          :final litterHistory,
        ) =>
          _ProfileHub(
            cats: cats,
            health: health,
            savedProducts: savedProducts,
            savedLitters: savedLitters,
            scanHistory: scanHistory,
            litterHistory: litterHistory,
            onCatTap: _openCatDetail,
            onAddCat: _openCreateCat,
            onManageCats: _openManageCats,
            onHealthTap: () => _openHealth(health),
            onSavedProductsTap: _openSavedProducts,
            onScanHistoryTap: _openScanHistory,
            onContactTap: () => _launchUri(
              Uri(scheme: 'mailto', path: kSupportEmail),
              errorMessage: l10n.profileEmailError(kSupportEmail),
            ),
            onPrivacyTap: () => _launchUri(
              Uri.parse(kPrivacyUrl),
              mode: LaunchMode.externalApplication,
              errorMessage: l10n.profilePrivacyError,
            ),
            onTermsTap: () => _launchUri(
              Uri.parse(kTermsUrl),
              mode: LaunchMode.externalApplication,
              errorMessage: l10n.profileTermsError,
            ),
            onResetOnboardingTap: () =>
                _bloc.add(ResetOnboardingTapEvent(context: context)),
            onResetTestUserTap: () => _confirmResetTestUser(context),
          ),
        _ => const Scaffold(
            backgroundColor: DSColors.pageBackground,
            body: ProfileSkeleton(),
          ),
      },
    );
  }
}

class _ProfileHub extends StatelessWidget {
  final List<CatEntity> cats;
  final List<CatHealthSummary> health;
  final List<ProductDisplayModel> savedProducts;
  final List<LitterDisplayModel> savedLitters;
  final List<ProductDisplayModel> scanHistory;
  final List<LitterDisplayModel> litterHistory;
  final ValueChanged<CatEntity> onCatTap;
  final VoidCallback onAddCat;
  final VoidCallback onManageCats;
  final VoidCallback onHealthTap;
  final VoidCallback onSavedProductsTap;
  final VoidCallback onScanHistoryTap;
  final VoidCallback onContactTap;
  final VoidCallback onPrivacyTap;
  final VoidCallback onTermsTap;
  final VoidCallback onResetOnboardingTap;
  final VoidCallback onResetTestUserTap;

  const _ProfileHub({
    required this.cats,
    required this.health,
    required this.savedProducts,
    required this.savedLitters,
    required this.scanHistory,
    required this.litterHistory,
    required this.onCatTap,
    required this.onAddCat,
    required this.onManageCats,
    required this.onHealthTap,
    required this.onSavedProductsTap,
    required this.onScanHistoryTap,
    required this.onContactTap,
    required this.onPrivacyTap,
    required this.onTermsTap,
    required this.onResetOnboardingTap,
    required this.onResetTestUserTap,
  });

  /// The Health row's subtitle when nothing is due soon: the first cat that
  /// has never been set up wins, else "all up to date". Computed here rather
  /// than in `_LibraryRow`, which only knows a count.
  String _healthEmptyLabel(AppLocalizations l10n) {
    for (final summary in health) {
      if (!summary.hasHistory) return l10n.profileHealthSetup(summary.cat.name);
    }
    return l10n.catDetailHealthAllClear;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    var dueSoon = 0;
    for (final summary in health) {
      dueSoon += summary.dueSoonCount;
    }
    return Scaffold(
      backgroundColor: DSColors.pageBackground,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            DSDimens.sizeL,
            DSDimens.sizeS,
            DSDimens.sizeL,
            MediaQuery.of(context).padding.bottom + kFloatingNavClearance,
          ),
          children: [
            Text(l10n.profileTitle, style: DSTextStyles.displayLg),
            const SizedBox(height: DSDimens.sizeL),
            _YourCatsCard(
              cats: cats,
              onCatTap: onCatTap,
              onAddCat: onAddCat,
              onManageCats: onManageCats,
            ),
            const SizedBox(height: DSDimens.sizeM),
            DSCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  // Hidden, not empty, when no carnet could be read — the
                  // row must never invite setup of a carnet it couldn't see.
                  if (health.isNotEmpty) ...[
                    _LibraryRow(
                      icon: Icons.favorite_outline_rounded,
                      label: l10n.profileHealthLabel,
                      count: dueSoon,
                      emptyLabel: _healthEmptyLabel(l10n),
                      countLabel: (n) => l10n.profileHealthCount(n),
                      previews: [
                        for (final summary in health)
                          if (summary.cat.profileImageUrl != null)
                            summary.cat.profileImageUrl,
                      ],
                      onTap: onHealthTap,
                    ),
                    const _MenuDivider(),
                  ],
                  _LibraryRow(
                    icon: Icons.bookmark_outline_rounded,
                    label: l10n.profileSavedProductsLabel,
                    count: savedProducts.length + savedLitters.length,
                    emptyLabel: l10n.profileSavedProductsEmpty,
                    countLabel: (n) => l10n.profileSavedProductsCount(n),
                    previews: [
                      ...savedProducts.map((p) => p.imageUrl),
                      ...savedLitters.map((l) => l.imageUrl),
                    ],
                    onTap: onSavedProductsTap,
                  ),
                  const _MenuDivider(),
                  _LibraryRow(
                    icon: Icons.history_rounded,
                    label: l10n.profileScanHistoryLabel,
                    count: scanHistory.length + litterHistory.length,
                    emptyLabel: l10n.profileScanHistoryEmpty,
                    countLabel: (n) => l10n.profileScanHistoryCount(n),
                    previews: [
                      ...scanHistory.map((p) => p.imageUrl),
                      ...litterHistory.map((l) => l.imageUrl),
                    ],
                    onTap: onScanHistoryTap,
                  ),
                ],
              ),
            ),
            const SizedBox(height: DSDimens.sizeM),
            DSCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _ProfileMenuItem(
                    icon: Icons.mail_outline_rounded,
                    label: l10n.profileContactUs,
                    onTap: onContactTap,
                  ),
                  const _MenuDivider(),
                  _ProfileMenuItem(
                    icon: Icons.shield_outlined,
                    label: l10n.profilePrivacyPolicy,
                    onTap: onPrivacyTap,
                  ),
                  const _MenuDivider(),
                  _ProfileMenuItem(
                    icon: Icons.description_outlined,
                    label: l10n.profileTermsAndConditions,
                    onTap: onTermsTap,
                  ),
                  // Debug builds and TestFlight, never the App Store.
                  // ⚠️ NOT `kDebugMode`: TestFlight ships a *release* build, so
                  // that stripped this row out of the one build it existed for.
                  if (kQaToolsEnabled) ...[
                    const _MenuDivider(),
                    _ProfileMenuItem(
                      icon: Icons.refresh_rounded,
                      label: l10n.profileResetOnboarding,
                      sublabel: l10n.profileDebugOnly,
                      onTap: onResetOnboardingTap,
                    ),
                    const _MenuDivider(),
                    // Deleting the app keeps the Keychain-persisted Firebase
                    // session, so it is *not* a fresh user — this is.
                    _ProfileMenuItem(
                      icon: Icons.person_off_outlined,
                      label: l10n.profileResetTestUser,
                      sublabel: l10n.profileDebugOnly,
                      onTap: onResetTestUserTap,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _YourCatsCard extends StatelessWidget {
  final List<CatEntity> cats;
  final ValueChanged<CatEntity> onCatTap;
  final VoidCallback onAddCat;
  final VoidCallback onManageCats;

  const _YourCatsCard({
    required this.cats,
    required this.onCatTap,
    required this.onAddCat,
    required this.onManageCats,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DSCard(
      padding: const EdgeInsets.all(DSDimens.sizeL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(l10n.profileYourCats, style: DSTextStyles.titleMd)),
              if (cats.isNotEmpty)
                GestureDetector(
                  onTap: onManageCats,
                  child: Text(
                    l10n.profileManage,
                    style: DSTextStyles.label.copyWith(
                      color: DSColors.inkSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: DSDimens.sizeS),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final cat in cats) ...[
                  _CatTile(cat: cat, onTap: () => onCatTap(cat)),
                  const SizedBox(width: DSDimens.sizeS),
                ],
                _AddCatTile(onTap: onAddCat),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CatTile extends StatelessWidget {
  final CatEntity cat;
  final VoidCallback onTap;

  const _CatTile({required this.cat, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 64,
        child: Column(
          children: [
            CatAvatar(photoUrl: cat.profileImageUrl, size: 56),
            const SizedBox(height: DSDimens.sizeXxs),
            Text(
              cat.name,
              style: DSTextStyles.caption.copyWith(color: DSColors.inkPrimary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _AddCatTile extends StatelessWidget {
  final VoidCallback onTap;

  const _AddCatTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 64,
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: DSColors.surfaceCardDim,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.add_rounded,
                color: DSColors.inkPrimary,
                size: 24,
              ),
            ),
            const SizedBox(height: DSDimens.sizeXxs),
            Text(
              l10n.profileAddCat,
              style: DSTextStyles.caption.copyWith(
                color: DSColors.inkSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Library entry (Saved products / Scan history) — icon + title + count, with
/// a small stack of recent cover thumbnails as a peek into the list.
class _LibraryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final String emptyLabel;
  final String Function(int) countLabel;
  /// Image URLs for the cover stack — plain strings so a row can mix
  /// categories (saved products and saved litters share one row).
  final List<String?> previews;
  final VoidCallback onTap;

  const _LibraryRow({
    required this.icon,
    required this.label,
    required this.count,
    required this.emptyLabel,
    required this.countLabel,
    required this.previews,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final subtitle = count == 0 ? emptyLabel : countLabel(count);
    final covers = previews.take(3).toList();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: DSDimens.sizeS,
            vertical: DSDimens.sizeS,
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: DSColors.tintLavender,
                  borderRadius: BorderRadius.circular(DSRadii.md),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: DSColors.inkPrimary, size: 20),
              ),
              const SizedBox(width: DSDimens.sizeS),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: DSTextStyles.titleMd),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: DSTextStyles.caption.copyWith(
                        color: DSColors.inkSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (covers.isNotEmpty) ...[
                _CoverStack(covers: covers),
                const SizedBox(width: DSDimens.sizeXs),
              ],
              const Icon(
                Icons.chevron_right_rounded,
                color: DSColors.inkTertiary,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Up to three overlapping covers, newest on the left.
class _CoverStack extends StatelessWidget {
  final List<String?> covers;

  const _CoverStack({required this.covers});

  static const double _size = 32;
  static const double _overlap = 20;

  @override
  Widget build(BuildContext context) {
    final n = covers.length;
    return SizedBox(
      width: _size + (n - 1) * _overlap,
      height: _size,
      child: Stack(
        children: [
          for (var i = 0; i < n; i++)
            Positioned(
              left: i * _overlap,
              child: _CoverThumb(imageUrl: covers[i], size: _size),
            ),
        ],
      ),
    );
  }
}

class _CoverThumb extends StatelessWidget {
  final String? imageUrl;
  final double size;

  const _CoverThumb({required this.imageUrl, required this.size});

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: DSColors.surfaceCard,
        borderRadius: BorderRadius.circular(DSRadii.sm),
        // White ring so overlapping covers stay visually separated.
        border: Border.all(color: DSColors.surfaceCard, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(DSRadii.sm - 2),
        child: hasImage
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const HatchedPlaceholder(),
              )
            : const HatchedPlaceholder(),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? sublabel;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    this.sublabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: DSDimens.sizeS,
            vertical: DSDimens.sizeS,
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: DSColors.tintLavender,
                  borderRadius: BorderRadius.circular(DSRadii.md),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: DSColors.inkPrimary, size: 20),
              ),
              const SizedBox(width: DSDimens.sizeS),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: DSTextStyles.titleMd),
                    if (sublabel != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        sublabel!,
                        style: DSTextStyles.caption.copyWith(
                          color: DSColors.inkSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: DSColors.inkTertiary,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuDivider extends StatelessWidget {
  const _MenuDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 1,
      color: DSColors.surfaceCardDim,
    );
  }
}
