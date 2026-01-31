import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DSColors {
  static const Color primary = Color(0xFFED67CA);
  static const Color black = Color(0xFF4A4A4A);
  static const Color white = Color(0xFFFFFFFF);
  static Color lightGrey = Colors.grey.shade200;
  static const Color darkGrey = Color(0xFFA2A2A2);
  static const Color inputLightGrey = Color(0xFFDFDFE0);
  static const Color inputDarkGrey = Color(0xFF7D7D82);
  static const Color green = Color(0xFF84E475);
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
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: DSColors.white,
      // listTileTheme: ListTileThemeData(
      //   tileColor: DSColors.lightGrey,
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.circular(DSDimensions.sizeS),
      //   ),
      //   titleTextStyle: const TextStyle(
      //     color: DSColors.black,
      //   ),
      //   iconColor: DSColors.black,
      // ),
      // colorSchemeSeed: DefaultColors.primary,

      // colorScheme: ColorScheme.fromSeed(
      //   seedColor: DefaultColors.primary,
      //   primary: DefaultColors.primary,
      //   // brightness: Brightness.light,
      // ),
      // focusColor: Color.fromARGB(255, 28, 192, 132),
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
