import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yucat/config/routes/router.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/home/bloc/home_bloc.dart';
import 'package:yucat/features/home/bloc/home_event.dart';
import 'package:yucat/features/home/bloc/home_state.dart';
import 'package:yucat/features/home/widgets/home_dashboard_page.dart';
import 'package:yucat/features/home/widgets/home_loading_page.dart';
import 'package:yucat/presentation/components/ds_state_view.dart';

@RoutePage()
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  late HomeBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<HomeBloc>();
    _bloc.add(HomeInitialEvent());
  }

  @override
  void dispose() {
    super.dispose();
    _bloc.close();
  }

  void _openScanner() {
    context.router.push(const ScannerRoute());
  }

  void _openSearch() {
    final tabsRouter = AutoTabsRouter.of(context);
    tabsRouter.setActiveIndex(0);
  }

  void _openPaywall() {
    context.router.push(PaywallRoute());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      bloc: _bloc,
      builder: (context, state) => _onStateChangeBuilder(state),
    );
  }

  Widget _onStateChangeBuilder(HomeState state) {
    switch (state) {
      case HomeLoadingState():
        return Scaffold(
          backgroundColor: DSColors.tintLavender,
          body: const HomeLoadingWidget(),
        );
      case HomeLoadedState(
          :final scansRemaining,
          :final maxFreeScans,
          :final isPremium,
          :final primaryCatName,
          :final primaryCatPhotoUrl,
          :final currentStreak,
        ):
        return HomeDashboardPage(
          scansRemaining: scansRemaining,
          maxFreeScans: maxFreeScans,
          isPremium: isPremium,
          primaryCatName: primaryCatName,
          primaryCatPhotoUrl: primaryCatPhotoUrl,
          currentStreak: currentStreak,
          onScanTap: _openScanner,
          onSearchTap: _openSearch,
          onUpgradeTap: _openPaywall,
        );
      case HomeErrorState():
        return Scaffold(
          backgroundColor: DSColors.tintLavender,
          body: SafeArea(
            child: DSStateView.error(
              body: state.message,
              onCtaPressed: () => _bloc.add(HomeInitialEvent()),
            ),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
