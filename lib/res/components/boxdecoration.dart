// import 'package:flutter/material.dart';
// import '../app_colors.dart';
import 'package:flutter/material.dart';

import '../app_colors.dart';

class AppBoxDecorationStyle {
  static BoxDecoration linearbutton = BoxDecoration(
    gradient: LinearGradient(
      colors: [AppColor.buttonyellow1, AppColor.buttonyellow2],
    ),
    borderRadius: BorderRadius.all(Radius.circular(15)),
  );

  static Widget smallgreyBoxDecoration = Container(
    height: 10,
    width: 100,
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey.shade200),
      color: Colors.grey.shade200.withValues(alpha: 0.5),
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(40),
        topRight: Radius.circular(40),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          offset: const Offset(0, -4),
          blurRadius: 16,
        ),
      ],
    ),
  );

  static BoxDecoration whiteRoundBoxDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(50),
      topRight: Radius.circular(50),
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        offset: const Offset(0, -4),
        blurRadius: 16,
      ),
    ],
  );
}
