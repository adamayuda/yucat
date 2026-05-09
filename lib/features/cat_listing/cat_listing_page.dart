import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yucat/config/routes/router.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/cat_listing/bloc/cat_listing_bloc.dart';
import 'package:yucat/features/cat_listing/widgets/cat_listing_empty_page.dart';
import 'package:yucat/features/cat_listing/widgets/cat_listing_error_page.dart';
import 'package:yucat/features/cat_listing/widgets/cat_listing_loading_page.dart';
import 'package:yucat/features/cat_listing/widgets/cat_listing_loaded_page.dart';
import 'package:yucat/presentation/components/ds_app_bar.dart';

@RoutePage()
class CatListingPage extends StatefulWidget {
  const CatListingPage({super.key});

  @override
  State<CatListingPage> createState() => _CatListingPageState();
}

class _CatListingPageState extends State<CatListingPage> {
  late CatListingBloc _bloc;

  void _navigateToProfile() {
    context.router.push(const ProfileRoute());
  }

  @override
  void initState() {
    super.initState();
    _bloc = context.read<CatListingBloc>();
    _bloc.add(const CatListingInitialEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CatListingBloc, CatListingState>(
      bloc: _bloc,
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) => Scaffold(
        backgroundColor: DSColors.tintLavender,
        body: Column(
          children: [
            SafeArea(
              bottom: false,
              child: DSAppBar.tab(
                title: 'My cats',
                trailing: IconButton(
                  onPressed: _navigateToProfile,
                  icon: const Icon(
                    Icons.settings_rounded,
                    color: DSColors.inkPrimary,
                    size: 24,
                  ),
                ),
              ),
            ),
            Expanded(child: _onStateChangeBuilder(state)),
          ],
        ),
      ),
    );
  }

  Widget _onStateChangeBuilder(CatListingState state) {
    switch (state) {
      case CatListingLoadingState():
        return const CatListingLoadingWidget();
      case CatListingLoadedState():
        return CatListingLoadedWidget(
          cats: state.cats,
          onPressed: () =>
              _bloc.add(CatListingCreateCatEvent(context: context)),
        );
      case CatListingErrorState():
        return CatListingErrorWidget(
          message: state.message,
          onPressed: () => _bloc.add(const CatListingFetchCatsEvent()),
        );
      case CatListingEmptyState():
        return CatListingEmptyWidget(
          onPressed: () =>
              _bloc.add(CatListingCreateCatEvent(context: context)),
        );
      default:
        return const SizedBox();
    }
  }
}
