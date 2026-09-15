import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:yucat/config/themes/theme.dart';
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
      builder: (context, state) => const _SplashContent(),
    );
  }
}

/// The logo face popping in (YUC-31): ~1 s scale-in, then a subtle settle to
/// 2.5 s, played once. ⚠️ The native launch screens (iOS storyboard, Android
/// `launch_background.xml`) are deliberately **plain splash pink** — a static
/// face there would visibly shrink to the animation's 30 % first frame and
/// re-pop. `SplashBloc` holds the route for the pop so a fast boot can't cut it.
class _SplashContent extends StatelessWidget {
  const _SplashContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DSColors.splashPink,
      body: SafeArea(
        child: Center(
          child: ExcludeSemantics(
            child: Lottie.asset(
              'assets/images/splash-face.json',
              width: 220,
              repeat: false,
              frameRate: FrameRate.composition,
            ),
          ),
        ),
      ),
    );
  }
}
