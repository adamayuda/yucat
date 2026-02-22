import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yucat/features/splash/presentation/bloc/splash_bloc.dart';

@RoutePage()
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPage();
}

class _SplashPage extends State<SplashPage> {
  late SplashBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<SplashBloc>();
    _bloc.add(SplashInitialEvent(context: context));
  }

  @override
  void dispose() {
    super.dispose();
    _bloc.close();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SplashBloc, SplashState>(
      bloc: _bloc,
      builder: (context, state) => _onStateChangeBuilder(state),
    );
  }

  Widget _onStateChangeBuilder(SplashState state) {
    switch (state) {
      case SplashLoadingState():
        return const SplashLoading();
    }
  }
}

class SplashLoading extends StatelessWidget {
  const SplashLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset('assets/images/icon.png', width: 200, height: 200),
      ),
    );
  }
}
