import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

ThemeData buildTheme() => ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: AppColors.bg,
  colorScheme: ColorScheme.fromSeed(seedColor: AppColors.blue, primary: AppColors.blue, secondary: AppColors.orange),
  textTheme: GoogleFonts.interTextTheme(),
  appBarTheme: const AppBarTheme(backgroundColor: Colors.white, foregroundColor: AppColors.text, elevation: 0),
);
