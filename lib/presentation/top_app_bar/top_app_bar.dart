import 'package:yucat/config/themes/theme.dart';
import 'package:flutter/material.dart';

class TopAppBar extends StatelessWidget {
  final String title;
  final bool centerTitle;
  final TextStyle? style;
  final Color? backgroundColor;
  final bool hideBackButton;
  final String? countryCode;
  final Widget? rightButton;

  const TopAppBar({
    super.key,
    required this.title,
    this.centerTitle = false,
    this.style,
    this.backgroundColor,
    this.hideBackButton = false,
    this.countryCode,
    this.rightButton,
  });

  @override
  Widget build(BuildContext context) {
    final canPop = ModalRoute.of(context)?.canPop ?? false;
    final hasCustomBg = backgroundColor != null;

    return AppBar(
      backgroundColor: backgroundColor ?? DSColors.white,
      centerTitle: centerTitle,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      titleSpacing: hideBackButton || !canPop ? 16 : 0,
      leadingWidth: 40,
      automaticallyImplyLeading: !hideBackButton,
      iconTheme: hasCustomBg ? const IconThemeData(color: Colors.white) : null,
      title: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style:
                  style ??
                  (hasCustomBg ? const TextStyle(color: Colors.white) : null),
            ),
          ),
        ],
      ),
      actions: rightButton != null ? [rightButton!] : null,
    );
  }
}
