import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ColorScheme kDarkColorScheme = ColorScheme.fromSeed(
  seedColor: const Color(0xff00474B),
  brightness: Brightness.dark,
);

ThemeData darkTheme = ThemeData.dark().copyWith(
  colorScheme: kDarkColorScheme,
  scaffoldBackgroundColor: Colors.black,
  textTheme: const TextTheme().copyWith(
    headlineLarge: GoogleFonts.dancingScript(
      fontSize: 135,
      color: kDarkColorScheme.onSurface,
      fontWeight: FontWeight.bold,
    ),
    headlineMedium: GoogleFonts.satisfy(
      fontSize: 30,
      color: kDarkColorScheme.onSurface,
    ),
    headlineSmall: GoogleFonts.quicksand(
      fontSize: 24,
      color: kDarkColorScheme.onSurface,
      fontWeight: FontWeight.bold,
    ),
    labelMedium: GoogleFonts.quicksand(
      fontSize: 19,
      color: kDarkColorScheme.onSurface,
    ),
    bodyMedium: GoogleFonts.quicksand(
      fontSize: 17,
      color: kDarkColorScheme.onSurface,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      textStyle: GoogleFonts.quicksand(
        fontSize: 20,
        color: kDarkColorScheme.surface,
        fontWeight: FontWeight.bold,
      ),
      backgroundColor:  Color.fromARGB(255, 59, 197, 64),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          18,
        ),
      ),
      minimumSize: const Size(double.infinity, 60),
    ),
  ),
);
