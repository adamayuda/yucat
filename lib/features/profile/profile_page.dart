import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/profile/bloc/profile_bloc.dart';
import 'package:yucat/features/profile/bloc/profile_state.dart';
import 'package:yucat/features/profile/bloc/profile_event.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

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
      builder: (context, state) => _onStateChangeBuilder(state),
    );
  }

  Widget _onStateChangeBuilder(ProfileState state) {
    switch (state) {
      case ProfileLoadingState():
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      case ProfileLoadedState():
        return _ProfileLoadedState(
          onLogoutTap: () => _bloc.add(LogoutTapEvent()),
          onLoginTap: () => _bloc.add(LoginTapEvent(context: context)),
          onDeleteAccountTap: () => _bloc.add(DeleteAccountTapEvent()),
        );
      default:
        return const Scaffold(body: SizedBox.shrink());
    }
  }
}

class _ProfileLoadedState extends StatelessWidget {
  final void Function() onLogoutTap;
  final void Function() onLoginTap;
  final void Function() onDeleteAccountTap;

  const _ProfileLoadedState({
    required this.onLogoutTap,
    required this.onLoginTap,
    required this.onDeleteAccountTap,
  });

  Future<void> _launchEmail(BuildContext context) async {
    try {
      final Uri emailLaunchUri = Uri(
        scheme: 'mailto',
        path: 'yucat.app@gmail.com',
      );

      if (!await launchUrl(emailLaunchUri)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Could not launch email client. Please contact us at airsim.app@gmail.com',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not launch email client. Please contact us at airsim.app@gmail.com',
            ),
          ),
        );
      }
    }
  }

  Future<void> _launchTerms(BuildContext context) async {
    try {
      final Uri termsUri = Uri.parse(
        'https://yucat-web-production.up.railway.app/cgv.html',
      );

      if (!await launchUrl(termsUri, mode: LaunchMode.inAppWebView)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open Terms & Conditions')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Terms & Conditions')),
        );
      }
    }
  }

  Future<void> _launchPrivacyPolicy(BuildContext context) async {
    try {
      final Uri privacyUri = Uri.parse(
        'https://yucat-web-production.up.railway.app/policy.html',
      );

      if (!await launchUrl(privacyUri, mode: LaunchMode.inAppWebView)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open Privacy Policy')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Privacy Policy')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: DSColors.lightGrey,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Navigate to settings page
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: DSDimens.sizeS),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(DSDimens.sizeS),
            child: Container(
              decoration: BoxDecoration(
                color: DSColors.white,
                borderRadius: BorderRadius.circular(DSDimens.sizeS),
              ),
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Contact Us'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _launchEmail(context),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(DSDimens.sizeS),
                        topRight: Radius.circular(DSDimens.sizeS),
                      ),
                    ),
                    splashColor: DSColors.lightGrey.withOpacity(0.3),
                  ),
                  const Divider(height: 1, color: DSColors.lightGrey),
                  ListTile(
                    title: const Text('Privacy Policy'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _launchPrivacyPolicy(context),
                    splashColor: DSColors.lightGrey.withOpacity(0.3),
                  ),
                  const Divider(height: 1, color: DSColors.lightGrey),
                  ListTile(
                    title: const Text('Terms & Conditions'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _launchTerms(context),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(DSDimens.sizeS),
                        bottomRight: Radius.circular(DSDimens.sizeS),
                      ),
                    ),
                    splashColor: DSColors.lightGrey.withOpacity(0.3),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
