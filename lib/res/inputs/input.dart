// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// import '../app_colors.dart';

// class CustomInputField extends StatelessWidget {
//   final String hintText;
//   final Color borderColor;
//   final Color hintTextColor;
//   final double fontSize;
//   final FontWeight fontWeight;
//   final TextEditingController controller;  // Added controller

//   const CustomInputField({
//     super.key,
//     required this.hintText,
//     this.borderColor = AppColor.inputColor,
//     this.hintTextColor = AppColor.greyColor,
//      required this.controller,  // Made required
//     this.fontSize = 14.0,
//     this.fontWeight = FontWeight.w400,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return TextField(
//       controller: controller,  // Using the controller
//       decoration: InputDecoration(
//         hintText: hintText,
//         hintStyle: GoogleFonts.dmSans(
//           fontSize: fontSize,
//           color: hintTextColor,
//           fontWeight: fontWeight,
//         ),
//         filled: true,
//         fillColor: AppColor.appwhite,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10.0),
//           borderSide: BorderSide(color: borderColor, width: 1.0),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10.0),
//           borderSide: BorderSide(color: borderColor, width: 1.0),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10.0),
//           borderSide: BorderSide(color: borderColor, width: 1.0),
//         ),
//         errorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10.0),
//           borderSide: BorderSide(color: borderColor, width: 1.0),
//         ),
//       ),
//     );
//   }
// }