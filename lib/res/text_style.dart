import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTextStyle {
   static TextStyle nunitoSans_12_600_white = GoogleFonts.nunitoSans(
    fontSize: 12.0,
    color: AppColor.white,
    fontWeight: FontWeight.w600,
  );
  static TextStyle nunitoSans_16_white = GoogleFonts.nunitoSans(
    fontSize: 16.0,
    color: AppColor.white,
    fontWeight: FontWeight.w500,
  );
  static TextStyle nunitoSans_16_600_white = GoogleFonts.nunitoSans(
    fontSize: 16.0,
    color: AppColor.appwhite,
    fontWeight: FontWeight.w600,
  );
      static TextStyle nunitoSans_16_600_green = GoogleFonts.nunitoSans(
    fontSize: 16.0,
 //   color: const Color.fromRGBO(52, 168, 83, 1),
 color: const Color.fromRGBO(26, 255, 60, 1),
    fontWeight: FontWeight.w600,
  );
     static TextStyle nunitoSans_16_600_red = GoogleFonts.nunitoSans(
    fontSize: 16.0,
    color: const Color.fromRGBO(255, 0, 0, 1),
    fontWeight: FontWeight.w600,
  );
    static TextStyle dmSans_8_white = GoogleFonts.dmSans(
    fontSize: 8.0,
    color: AppColor.appwhite,
    fontWeight: FontWeight.w700,
  );
}