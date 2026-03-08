import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yucat/config/routes/router.dart';
import 'package:yucat/features/paywall/bloc/paywall_bloc.dart';
import 'package:yucat/features/paywall/bloc/paywall_event.dart';
import 'package:yucat/features/paywall/bloc/paywall_state.dart';
import 'package:yucat/features/paywall/widgets/paywall_error_widget.dart';
import 'package:yucat/features/paywall/widgets/paywall_loaded_widget.dart';
import 'package:yucat/features/paywall/widgets/paywall_loading_widget.dart';

@RoutePage()
class PaywallPage extends StatefulWidget {
  const PaywallPage({super.key});

  @override
  State<PaywallPage> createState() => _PaywallPage();
}

class _PaywallPage extends State<PaywallPage> {
  late PaywallBloc _bloc;

  @override
  void initState() {
    debugPrint('PaywallPage initState');
    super.initState();
    _bloc = context.read<PaywallBloc>();
    _bloc.add(const PaywallInitialEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PaywallBloc, PaywallState>(
      bloc: _bloc,
      listenWhen: _listenWhen,
      listener: _onStateChangeListener,
      buildWhen: _buildWhen,
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: _onStateChangeBuilder(state),
        );
      },
    );
  }

  bool _buildWhen(PaywallState previous, PaywallState current) {
    return current is! PaywallSuccessState &&
        current is! PaywallAlreadySubscribedState;
  }

  bool _listenWhen(PaywallState previous, PaywallState current) {
    return current is PaywallSuccessState ||
        current is PaywallAlreadySubscribedState;
  }

  void _onStateChangeListener(BuildContext context, PaywallState state) {
    switch (state) {
      case PaywallSuccessState():
        Navigator.of(context).pop(state.purchasedSubscription);
        break;
      case PaywallAlreadySubscribedState():
        Navigator.of(context).pop(true);
        break;
      default:
        Navigator.of(context).pop(false);
        break;
    }
  }

  Widget _onStateChangeBuilder(PaywallState state) {
    switch (state) {
      case PaywallLoadingState():
        return PaywallLoadingWidget();
      case PaywallErrorState():
        return PaywallErrorWidget();
      case PaywallLoadedState():
        return PaywallLoadedWidget();
      default:
        return const SizedBox();
    }
  }
}
