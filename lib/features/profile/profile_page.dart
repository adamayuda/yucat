import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yucat/config/routes/router.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/profile/bloc/profile_bloc.dart';
import 'package:yucat/features/profile/bloc/profile_event.dart';
import 'package:yucat/features/profile/bloc/profile_state.dart';
import 'package:yucat/presentation/components/ds_app_bar.dart';
import 'package:yucat/presentation/components/ds_card.dart';
import 'package:yucat/presentation/widgets/app_loading_widget.dart';

const _termsUrl = 'https://yucat-web-production.up.railway.app/cgv.html';
const _privacyUrl = 'https://yucat-web-production.up.railway.app/policy.html';
const _supportEmail = 'yucat.app@gmail.com';

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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      bloc: _bloc,
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) => switch (state) {
        ProfileLoadingState() => const Scaffold(
            backgroundColor: DSColors.tintLavender,
            body: AppLoadingWidget(),
          ),
        ProfileLoadedState() => _ProfileLoadedState(
            onResetOnboardingTap: () =>
                _bloc.add(ResetOnboardingTapEvent(context: context)),
            onSavedProductsTap: () =>
                context.router.push(const SavedProductsRoute()),
          ),
        _ => const Scaffold(
            backgroundColor: DSColors.tintLavender,
            body: SizedBox.shrink(),
          ),
      },
    );
  }
}

class _ProfileLoadedState extends StatelessWidget {
  final VoidCallback onResetOnboardingTap;
  final VoidCallback onSavedProductsTap;

  const _ProfileLoadedState({
    required this.onResetOnboardingTap,
    required this.onSavedProductsTap,
  });

  Future<void> _launchUri(BuildContext context, Uri uri,
      {String? errorMessage, LaunchMode mode = LaunchMode.platformDefault}) async {
    final fallbackMessage = errorMessage ?? 'Could not open this link.';
    try {
      if (!await launchUrl(uri, mode: mode)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(fallbackMessage)),
          );
        }
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(fallbackMessage)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DSColors.tintLavender,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DSAppBar.modal(onBack: () => Navigator.of(context).pop()),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  DSDimens.sizeL,
                  DSDimens.sizeS,
                  DSDimens.sizeL,
                  DSDimens.size4xl,
                ),
                children: [
                  Text('Profile', style: DSTextStyles.displayLg),
                  const SizedBox(height: DSDimens.sizeL),
                  DSCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        _ProfileMenuItem(
                          icon: Icons.bookmark_outline_rounded,
                          label: 'Saved products',
                          onTap: onSavedProductsTap,
                        ),
                        const _MenuDivider(),
                        _ProfileMenuItem(
                          icon: Icons.mail_outline_rounded,
                          label: 'Contact us',
                          onTap: () => _launchUri(
                            context,
                            Uri(scheme: 'mailto', path: _supportEmail),
                            errorMessage:
                                'Could not launch email. Please contact us at $_supportEmail',
                          ),
                        ),
                        const _MenuDivider(),
                        _ProfileMenuItem(
                          icon: Icons.shield_outlined,
                          label: 'Privacy policy',
                          onTap: () => _launchUri(
                            context,
                            Uri.parse(_privacyUrl),
                            mode: LaunchMode.inAppWebView,
                            errorMessage: 'Could not open Privacy Policy',
                          ),
                        ),
                        const _MenuDivider(),
                        _ProfileMenuItem(
                          icon: Icons.description_outlined,
                          label: 'Terms & conditions',
                          onTap: () => _launchUri(
                            context,
                            Uri.parse(_termsUrl),
                            mode: LaunchMode.inAppWebView,
                            errorMessage: 'Could not open Terms & Conditions',
                          ),
                        ),
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
          ],
        ),
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
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: DSDimens.sizeS),
      child: Divider(
        height: 1,
        thickness: 1,
        color: DSColors.surfaceCardDim,
      ),
    );
  }
}
