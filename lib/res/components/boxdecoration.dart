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
  );}