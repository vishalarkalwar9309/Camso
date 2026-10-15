import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class AppTypography {
  static TextStyle heading(double size, {Color color = AppColors.blue, FontWeight weight = FontWeight.w700}) =>
      GoogleFonts.barlowCondensed(fontSize: size, color: color, fontWeight: weight, letterSpacing: 0.6);
  static TextStyle body(double size, {Color color = AppColors.text, FontWeight weight = FontWeight.w400}) =>
      GoogleFonts.inter(fontSize: size, color: color, fontWeight: weight);
}
