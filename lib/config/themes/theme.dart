import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DSColors {
  // Primary & Brand (legacy — kept for back-compat; prefer ink/tint tokens below)
  static const Color primary = Color(0xFFED67CA);
  static const Color primaryVibrant = Color(0xFFFF5FC9);
  static const Color primaryFocus = Color(0xFFFF61E5);
  static const Color primaryDisabled = Color(0xFFEDAFDD);
  static const Color primarySurface = Color(0xFFFEF5FE);
  static const Color primaryLight = Color(0xFFF5E8FF);
  static const Color primaryMuted = Color(0xFFF9E9F5);

  // Neutrals (legacy)
  static const Color black = Color(0xFF4A4A4A);
  static const Color darkBlue = Color(0xFF334156);
  static const Color bodyText = Color(0xFF686868);
  static const Color inputDarkGrey = Color(0xFF7D7D82);
  static const Color placeholder = Color(0xFFA0A8B6);
  static const Color darkGrey = Color(0xFFA2A2A2);
  static const Color inputLightGrey = Color(0xFFDFDFE0);
  static const Color border = Color(0xFFE6E7EB);
  static Color lightGrey = Colors.grey.shade200;
  static const Color surface = Color(0xFFF9FAFB);
  static const Color white = Color(0xFFFFFFFF);

  // Semantic (legacy)
  static const Color green = Color(0xFF84E475);
  static const Color red = Color(0xFFE53935);

  // --- BitePal-aligned tokens ---

  // Ink (text + dark surfaces)
  static const Color inkPrimary = Color(0xFF0E0E14);
  static const Color inkSecondary = Color(0xFF5C5C66);
  static const Color inkTertiary = Color(0xFF9999A3);
  static const Color inkInverse = Color(0xFFFFFFFF);

  // Section surface tints (page backgrounds)
  static const Color tintLavender = Color(0xFFE8E5F0);
  static const Color tintSky = Color(0xFFDCE9F4);
  static const Color tintMint = Color(0xFFD8F0DD);
  static const Color tintCoral = Color(0xFFF4D9D6);
  static const Color tintSand = Color(0xFFFAEBC8);
  static const Color tintAsh = Color(0xFFEFEEF0);
  static const Color tintCloud = Color(0xFFEFEEF5);

  // Soft pastel tints (onboarding gradient endpoints / highlighted surfaces)
  static const Color tintBlueSoft = Color(0xFFE7EEFA);
  static const Color tintCoralSoft = Color(0xFFF8CDC6);
  static const Color tintSkyBright = Color(0xFFF7FBFE);
  static const Color tintMintSoft = Color(0xFFDFEFE1);
  static const Color tintSandSoft = Color(0xFFF8EADA);
  static const Color tintCream = Color(0xFFFFF4DC);
  static const Color tintGreySoft = Color(0xFFE2DFE8);

  // Card surfaces
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color surfaceCardDim = Color(0xFFF5F5F8);

  // Accents
  static const Color accentSuccess = Color(0xFF36C078);
  static const Color accentSuccessSoft = Color(0xFFE3F5EA);
  static const Color accentDanger = Color(0xFFE5564B);
  static const Color accentInfo = Color(0xFF3F8CDB);

  // Brand (logo only — do not use as UI primary)
  static const Color brandPink = Color(0xFFED67CA);

  // Logo / splash background (matches the pink baked into logo.svg)
  static const Color splashPink = Color(0xFFFDD4DD);

  // Coral selection accent (chips, slider, selected card border)
  static const Color coralAccent = Color(0xFFFF7A59);
  static const Color coralSurface = Color(0xFFFFF1ED);

  // Paywall accent (feature-scoped — matches the paywall hero gradient and
  // replaces the app's green success accent within the paywall only)
  static const Color paywallAccent = Color(0xFFEC6A6A);
  static const Color paywallAccentSoft = Color(0xFFFBE6E6);
}

class DSGradients {
  /// Left→right pink gradient for the paywall "Plus" badges.
  static const LinearGradient paywallBadge = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFE85C5C), Color(0xFFF4A2A2)],
  );

  /// Coral wash behind the paywall hero (covered by the cloud illustration).
  static const LinearGradient paywallHero = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF09595), Color(0xFFF4B6B6)],
  );

  // --- Onboarding section backgrounds ---
  // Each fades a section accent into the neutral page tint (DSColors.tintCloud).

  static const LinearGradient onboardingWhyYucat = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFCAD8FF), DSColors.tintCloud],
  );

  static const LinearGradient onboardingProofChart = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFE3FFDD), DSColors.tintCloud],
  );

  static const LinearGradient onboardingHealthIntro = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFDFE6FD), DSColors.tintCloud],
  );

  static const LinearGradient onboardingSuccess = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFE5FEDE), DSColors.tintCloud],
  );

  static const LinearGradient onboardingReminders = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFEF8E6), DSColors.tintCloud],
  );

  static const LinearGradient onboardingNotifPrimer = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      DSColors.tintCoralSoft,
      DSColors.tintCoral,
      Color(0xFFF3EEEC),
    ],
    stops: [0.0, 0.45, 1.0],
  );

  /// Blue wash behind the cat-create water-intake fact step.
  static const LinearGradient catCreateBackground = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFA5CAFF), DSColors.tintCloud],
  );

  /// Soft full-page wash behind the home dashboard.
  static const LinearGradient homeBackground = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFEDEAF7), DSColors.tintCloud],
  );

  /// Warm coral wash behind the home scan hero card.
  static const LinearGradient homeScanCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [DSColors.tintCoralSoft, DSColors.tintCoral],
  );
}

class DSDimens {
  static const double sizeXxxxs = 2;
  static const double sizeXxxs = 4;
  static const double sizeXxs = 8;
  static const double sizeXs = 12;
  static const double sizeS = 16;
  static const double sizeM = 20;
  static const double sizeL = 24;
  static const double sizeXl = 28;
  static const double sizeXxl = 32;
  static const double size3xl = 40;
  static const double size4xl = 48;
  static const double size5xl = 64;
}

class DSRadii {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double pill = 999;
}

class DSShadows {
  static const List<BoxShadow> e1 = [
    BoxShadow(
      color: Color(0x0A000000),
      offset: Offset(0, 1),
      blurRadius: 2,
    ),
  ];

  static const List<BoxShadow> e2 = [
    BoxShadow(
      color: Color(0x0F000000),
      offset: Offset(0, 4),
      blurRadius: 12,
    ),
  ];

  static const List<BoxShadow> e3 = [
    BoxShadow(
      color: Color(0x14000000),
      offset: Offset(0, 8),
      blurRadius: 24,
    ),
  ];
}

class DSMotion {
  static const Duration durFast = Duration(milliseconds: 150);
  static const Duration durMed = Duration(milliseconds: 250);
  static const Duration durSlow = Duration(milliseconds: 400);

  static const Curve curveStandard = Curves.easeInOutCubic;
  static const Curve curveEmphasized = Curves.easeOutBack;
  static const Curve curveDecelerate = Curves.easeOut;
}

class DSTextStyles {
  /// Bundled variable font (see `pubspec.yaml` `fonts:`).
  static const String _titleFamily = 'BricolageGrotesque';

  /// Shared title/display style — Bricolage Grotesque, heavy + condensed.
  /// All headings use this; only the [size] varies.
  static TextStyle title(double size, {Color color = DSColors.inkPrimary}) =>
      TextStyle(
        fontFamily: _titleFamily,
        fontSize: size,
        height: 0.92,
        letterSpacing: size * -0.013,
        color: color,
        fontVariations: const [
          FontVariation('wght', 800), // heaviest
          FontVariation('wdth', 75), // condensed
        ],
      );

  static TextStyle get displayHero => title(44);

  static TextStyle get displayLg => title(36);

  static TextStyle get headlineMd => title(24);

  static TextStyle get titleMd => GoogleFonts.dmSans(
    fontSize: 18,
    height: 24 / 18,
    fontWeight: FontWeight.w700,
    color: DSColors.inkPrimary,
  );

  static TextStyle get bodyLg => GoogleFonts.dmSans(
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w500,
    color: DSColors.inkPrimary,
  );

  static TextStyle get bodyMd => GoogleFonts.dmSans(
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w400,
    color: DSColors.inkSecondary,
  );

  static TextStyle get label => GoogleFonts.dmSans(
    fontSize: 13,
    height: 16 / 13,
    fontWeight: FontWeight.w600,
    color: DSColors.inkPrimary,
  );

  static TextStyle get caption => GoogleFonts.dmSans(
    fontSize: 11,
    height: 14 / 11,
    fontWeight: FontWeight.w500,
    color: DSColors.inkTertiary,
  );
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: DSColors.white,
      fontFamily: GoogleFonts.dmSans().fontFamily,
      textTheme: TextTheme(
        displaySmall: TextStyle(fontFamily: GoogleFonts.satisfy().fontFamily),
      ).apply(bodyColor: DSColors.black),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: DSColors.primary,
        unselectedItemColor: DSColors.darkGrey,
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: DSColors.inputLightGrey,
        focusColor: DSColors.black,
        hoverColor: DSColors.inputLightGrey,
        labelStyle: const TextStyle(color: DSColors.black),
        floatingLabelStyle: const TextStyle(color: DSColors.black),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: DSDimens.sizeXs,
          vertical: DSDimens.sizeXxs,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DSDimens.sizeXs),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DSDimens.sizeXs),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DSDimens.sizeXs),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
