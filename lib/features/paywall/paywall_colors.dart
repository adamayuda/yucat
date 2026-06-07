import 'package:flutter/material.dart';

/// Pink/red accent for the paywall (matches the hero gradient), replacing the
/// app's green success accent within this feature.
const kPaywallAccent = Color(0xFFEC6A6A);

/// Soft tint of [kPaywallAccent] for highlighted backgrounds.
const kPaywallAccentSoft = Color(0xFFFBE6E6);

/// Left→right pink gradient for the "Plus" badges.
const kPaywallAccentGradient = LinearGradient(
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
  colors: [Color(0xFFE85C5C), Color(0xFFF4A2A2)],
);
