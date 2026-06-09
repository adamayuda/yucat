import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yucat/config/routes/router.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/analytics/domain/usecase/log_event_usecase.dart';
import 'package:yucat/features/cat/domain/entities/cat_entity.dart';
import 'package:yucat/features/cat_listing/mappers/cat_entity_to_model_mapper.dart';
import 'package:yucat/features/product_detail/presentation/models/product_display_model.dart';
import 'package:yucat/features/product_detail/presentation/widgets/hatched_placeholder.dart';
import 'package:yucat/features/profile/bloc/profile_bloc.dart';
import 'package:yucat/features/profile/bloc/profile_event.dart';
import 'package:yucat/features/profile/bloc/profile_state.dart';
import 'package:yucat/presentation/components/cat_avatar.dart';
import 'package:yucat/presentation/components/ds_bottom_nav.dart';
import 'package:yucat/presentation/components/ds_card.dart';
import 'package:yucat/presentation/widgets/app_loading_widget.dart';
import 'package:yucat/service_locator.dart';

const _termsUrl = 'https://yucat-web-production.up.railway.app/cgv.html';
const _privacyUrl = 'https://yucat-web-production.up.railway.app/policy.html';
const _supportEmail = 'yucat.app@gmail.com';
const _manageSubscriptionUrl = 'https://apps.apple.com/account/subscriptions';

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
    final fallbackMessage = errorMessage ?? 'Could not open this link.';
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
      eventName: 'Profile Cat Tapped',
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

  void _openSavedProducts() {
    context.router.push(const SavedProductsRoute());
  }

  void _openScanHistory() {
    sl<LogEventUsecase>().call(
      eventName: 'Scan History Viewed',
      properties: {'timestamp': DateTime.now().toIso8601String()},
    );
    context.router.push(const ScanHistoryRoute());
  }

  void _restorePurchases() {
    _bloc.add(RestorePurchasesTapEvent(context: context));
  }

  void _manageSubscription() {
    sl<LogEventUsecase>().call(
      eventName: 'Manage Subscription Tapped',
      properties: {'timestamp': DateTime.now().toIso8601String()},
    );
    _launchUri(
      Uri.parse(_manageSubscriptionUrl),
      errorMessage: 'Could not open subscription settings.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      bloc: _bloc,
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) => switch (state) {
        ProfileLoadedState(:final cats, :final savedProducts, :final scanHistory) =>
          _ProfileHub(
            cats: cats,
            savedProducts: savedProducts,
            scanHistory: scanHistory,
            onRestore: _restorePurchases,
            onManageSubscription: _manageSubscription,
            onCatTap: _openCatDetail,
            onAddCat: _openCreateCat,
            onManageCats: _openManageCats,
            onSavedProductsTap: _openSavedProducts,
            onScanHistoryTap: _openScanHistory,
            onContactTap: () => _launchUri(
              Uri(scheme: 'mailto', path: _supportEmail),
              errorMessage:
                  'Could not launch email. Please contact us at $_supportEmail',
            ),
            onPrivacyTap: () => _launchUri(
              Uri.parse(_privacyUrl),
              mode: LaunchMode.inAppWebView,
              errorMessage: 'Could not open Privacy Policy',
            ),
            onTermsTap: () => _launchUri(
              Uri.parse(_termsUrl),
              mode: LaunchMode.inAppWebView,
              errorMessage: 'Could not open Terms & Conditions',
            ),
            onResetOnboardingTap: () =>
                _bloc.add(ResetOnboardingTapEvent(context: context)),
          ),
        _ => const Scaffold(
            backgroundColor: DSColors.tintLavender,
            body: AppLoadingWidget(),
          ),
      },
    );
  }
}

class _ProfileHub extends StatelessWidget {
  final List<CatEntity> cats;
  final List<ProductDisplayModel> savedProducts;
  final List<ProductDisplayModel> scanHistory;
  final VoidCallback onRestore;
  final VoidCallback onManageSubscription;
  final ValueChanged<CatEntity> onCatTap;
  final VoidCallback onAddCat;
  final VoidCallback onManageCats;
  final VoidCallback onSavedProductsTap;
  final VoidCallback onScanHistoryTap;
  final VoidCallback onContactTap;
  final VoidCallback onPrivacyTap;
  final VoidCallback onTermsTap;
  final VoidCallback onResetOnboardingTap;

  const _ProfileHub({
    required this.cats,
    required this.savedProducts,
    required this.scanHistory,
    required this.onRestore,
    required this.onManageSubscription,
    required this.onCatTap,
    required this.onAddCat,
    required this.onManageCats,
    required this.onSavedProductsTap,
    required this.onScanHistoryTap,
    required this.onContactTap,
    required this.onPrivacyTap,
    required this.onTermsTap,
    required this.onResetOnboardingTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DSColors.tintLavender,
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
            Text('Profile', style: DSTextStyles.displayLg),
            const SizedBox(height: DSDimens.sizeL),
            _SubscriptionCard(
              onRestore: onRestore,
              onManageSubscription: onManageSubscription,
            ),
            const SizedBox(height: DSDimens.sizeM),
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
                  _LibraryRow(
                    icon: Icons.bookmark_outline_rounded,
                    label: 'Saved products',
                    count: savedProducts.length,
                    emptyLabel: 'Nothing saved yet',
                    countLabel: (n) => '$n saved',
                    previews: savedProducts,
                    onTap: onSavedProductsTap,
                  ),
                  const _MenuDivider(),
                  _LibraryRow(
                    icon: Icons.history_rounded,
                    label: 'Scan history',
                    count: scanHistory.length,
                    emptyLabel: 'No scans yet',
                    countLabel: (n) => '$n scan${n == 1 ? '' : 's'}',
                    previews: scanHistory,
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
                    label: 'Contact us',
                    onTap: onContactTap,
                  ),
                  const _MenuDivider(),
                  _ProfileMenuItem(
                    icon: Icons.shield_outlined,
                    label: 'Privacy policy',
                    onTap: onPrivacyTap,
                  ),
                  const _MenuDivider(),
                  _ProfileMenuItem(
                    icon: Icons.description_outlined,
                    label: 'Terms & conditions',
                    onTap: onTermsTap,
                  ),
                  // Debug-only: compiled out of release builds via kDebugMode.
                  if (kDebugMode) ...[
                    const _MenuDivider(),
                    _ProfileMenuItem(
                      icon: Icons.refresh_rounded,
                      label: 'Reset onboarding',
                      sublabel: 'Debug only',
                      onTap: onResetOnboardingTap,
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

class _SubscriptionCard extends StatelessWidget {
  final VoidCallback onRestore;
  final VoidCallback onManageSubscription;

  const _SubscriptionCard({
    required this.onRestore,
    required this.onManageSubscription,
  });

  @override
  Widget build(BuildContext context) {
    // Hard paywall: every user who reaches Profile is an active subscriber,
    // so the card always reflects the Pro state.
    return DSCard(
      padding: const EdgeInsets.all(DSDimens.sizeL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: DSColors.accentSuccessSoft,
                  borderRadius: BorderRadius.circular(DSRadii.md),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: DSColors.accentSuccess,
                  size: 22,
                ),
              ),
              const SizedBox(width: DSDimens.sizeS),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('YuCat Pro', style: DSTextStyles.titleMd),
                    const SizedBox(height: 2),
                    Text(
                      'Your subscription is active',
                      style: DSTextStyles.bodyMd.copyWith(
                        color: DSColors.inkSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: DSDimens.sizeS),
          _InlineAction(
            icon: Icons.restore_rounded,
            label: 'Restore purchases',
            onTap: onRestore,
          ),
          const _MenuDivider(),
          _InlineAction(
            icon: Icons.settings_outlined,
            label: 'Manage subscription',
            onTap: onManageSubscription,
          ),
        ],
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
    return DSCard(
      padding: const EdgeInsets.all(DSDimens.sizeL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('Your cats', style: DSTextStyles.titleMd)),
              if (cats.isNotEmpty)
                GestureDetector(
                  onTap: onManageCats,
                  child: Text(
                    'Manage',
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
              'Add',
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

class _InlineAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _InlineAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: DSDimens.sizeS),
          child: Row(
            children: [
              Icon(icon, color: DSColors.inkPrimary, size: 20),
              const SizedBox(width: DSDimens.sizeS),
              Expanded(child: Text(label, style: DSTextStyles.titleMd)),
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

/// Library entry (Saved products / Scan history) — icon + title + count, with
/// a small stack of recent cover thumbnails as a peek into the list.
class _LibraryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final String emptyLabel;
  final String Function(int) countLabel;
  final List<ProductDisplayModel> previews;
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

/// Up to three overlapping product covers, newest on the left.
class _CoverStack extends StatelessWidget {
  final List<ProductDisplayModel> covers;

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
              child: _CoverThumb(product: covers[i], size: _size),
            ),
        ],
      ),
    );
  }
}

class _CoverThumb extends StatelessWidget {
  final ProductDisplayModel product;
  final double size;

  const _CoverThumb({required this.product, required this.size});

  @override
  Widget build(BuildContext context) {
    final hasImage = product.imageUrl != null && product.imageUrl!.isNotEmpty;
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
                product.imageUrl!,
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
