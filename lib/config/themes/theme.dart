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

  // Coral selection accent (chips, slider, selected card border)
  static const Color coralAccent = Color(0xFFFF7A59);
  static const Color coralSurface = Color(0xFFFFF1ED);
}

class DSDimens {
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
  static TextStyle get displayHero => GoogleFonts.sora(
    fontSize: 40,
    height: 44 / 40,
    fontWeight: FontWeight.w800,
    color: DSColors.inkPrimary,
    letterSpacing: -0.5,
  );

  static TextStyle get displayLg => GoogleFonts.sora(
    fontSize: 32,
    height: 38 / 32,
    fontWeight: FontWeight.w800,
    color: DSColors.inkPrimary,
    letterSpacing: -0.3,
  );

  static TextStyle get headlineMd => GoogleFonts.sora(
    fontSize: 22,
    height: 28 / 22,
    fontWeight: FontWeight.w700,
    color: DSColors.inkPrimary,
  );

  static TextStyle get titleMd => GoogleFonts.poppins(
    fontSize: 18,
    height: 24 / 18,
    fontWeight: FontWeight.w600,
    color: DSColors.inkPrimary,
  );

  static TextStyle get bodyLg => GoogleFonts.poppins(
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w500,
    color: DSColors.inkPrimary,
  );

  static TextStyle get bodyMd => GoogleFonts.poppins(
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w400,
    color: DSColors.inkSecondary,
  );

  static TextStyle get label => GoogleFonts.poppins(
    fontSize: 13,
    height: 16 / 13,
    fontWeight: FontWeight.w500,
    color: DSColors.inkPrimary,
  );

  static TextStyle get caption => GoogleFonts.poppins(
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
      fontFamily: GoogleFonts.poppins().fontFamily,
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
