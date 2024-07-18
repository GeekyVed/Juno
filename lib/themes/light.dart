import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ColorScheme kLightColorScheme = ColorScheme.fromSeed(
  seedColor: const Color(0xffF2C94C),
  brightness: Brightness.light,
);

ThemeData lightTheme = ThemeData.light().copyWith(
  colorScheme: kLightColorScheme,
  scaffoldBackgroundColor: Colors.white,
  textTheme: const TextTheme().copyWith(
    headlineLarge: GoogleFonts.dancingScript(
      fontSize: 135,
      color: kLightColorScheme.onSurface,
      fontWeight: FontWeight.bold,
    ),
    headlineMedium: GoogleFonts.satisfy(
      fontSize: 30,
      color: kLightColorScheme.onSurface,
    ),
    headlineSmall: GoogleFonts.quicksand(
      fontSize: 24,
      color: kLightColorScheme.onSurface,
      fontWeight: FontWeight.bold,
    ),
    labelMedium: GoogleFonts.quicksand(
      fontSize: 19,
      color: kLightColorScheme.onSurface,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      textStyle: GoogleFonts.quicksand(
        fontSize: 20,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      backgroundColor: Color.fromARGB(255, 59, 197, 64),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          18,
        ),
      ),
      minimumSize: const Size(double.infinity, 60),
    ),
  ),
);
