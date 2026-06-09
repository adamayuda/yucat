import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yucat/config/themes/theme.dart';
import 'package:yucat/features/paywall/bloc/paywall_bloc.dart';
import 'package:yucat/features/paywall/bloc/paywall_event.dart';
import 'package:yucat/features/paywall/bloc/paywall_state.dart';
import 'package:yucat/features/paywall/widgets/paywall_error_widget.dart';
import 'package:yucat/features/paywall/widgets/paywall_loaded_widget.dart';
import 'package:yucat/features/paywall/widgets/paywall_skeleton.dart';

@RoutePage()
class PaywallPage extends StatefulWidget {
  /// When false the paywall is a hard gate: no close chip and system
  /// back/swipe is blocked. Used at the end of onboarding and at boot when
  /// the user has no active subscription.
  final bool dismissible;

  const PaywallPage({super.key, this.dismissible = true});

  @override
  State<PaywallPage> createState() => _PaywallPage();
}

class _PaywallPage extends State<PaywallPage> {
  late PaywallBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<PaywallBloc>();
    _bloc.add(const PaywallInitialEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PaywallBloc, PaywallState>(
      bloc: _bloc,
      listenWhen: _listenWhen,
      listener: _onStateChange,
      buildWhen: _buildWhen,
      builder: (context, state) => PopScope(
        canPop: widget.dismissible,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: _onStateChangeBuilder(state),
        ),
      ),
    );
  }

  bool _buildWhen(PaywallState previous, PaywallState current) {
    return current is! PaywallSuccessState &&
        current is! PaywallAlreadySubscribedState;
  }

  bool _listenWhen(PaywallState previous, PaywallState current) {
    if (current is PaywallSuccessState) return true;
    if (current is PaywallAlreadySubscribedState) return true;
    if (previous is PaywallLoadedState && current is PaywallLoadedState) {
      return current.transientError != null &&
          current.errorTick != previous.errorTick;
    }
    return false;
  }

  Future<void> _onStateChange(BuildContext context, PaywallState state) async {
    switch (state) {
      case PaywallSuccessState():
        // Dismiss the paywall, returning whether a subscription was purchased.
        Navigator.of(context).pop(state.purchasedSubscription);
        break;
      case PaywallAlreadySubscribedState():
        Navigator.of(context).pop(true);
        break;
      case PaywallLoadedState(:final transientError) when transientError != null:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(transientError),
            backgroundColor: DSColors.inkPrimary,
          ),
        );
        break;
      default:
        break;
    }
  }

  Widget _onStateChangeBuilder(PaywallState state) {
    return switch (state) {
      PaywallLoadingState() => const PaywallSkeleton(),
      PaywallErrorState(:final message) => PaywallErrorWidget(message: message),
      PaywallLoadedState() => PaywallLoadedWidget(
        state: state,
        bloc: _bloc,
        dismissible: widget.dismissible,
      ),
      _ => const SizedBox(),
    };
  }
}
