// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// import '../app_colors.dart';


// class CustomPasswordField extends StatefulWidget {
//   final String hintText;
//   final Color borderColor;
//   final Color hintTextColor;
//   final double fontSize;
//   final FontWeight fontWeight;
//    final TextEditingController controller;

//   const CustomPasswordField({
//     super.key,
//     required this.hintText,
//     this.borderColor = AppColor.inputColor,
//     this.hintTextColor = AppColor.greyColor,
//     required this.controller,
//     this.fontSize = 14.0,
//     this.fontWeight = FontWeight.w400,
//   });

//   @override
//   State<CustomPasswordField> createState() => _CustomPasswordFieldState();
// }

// class _CustomPasswordFieldState extends State<CustomPasswordField> {
//   bool _obscureText = true;

//   @override
//   Widget build(BuildContext context) {
//     return TextField(
//        controller: widget.controller,
//       obscureText: _obscureText,
//       decoration: InputDecoration(
//         hintText: widget.hintText,
//         hintStyle: GoogleFonts.dmSans(
//           fontSize: widget.fontSize,
//           color: widget.hintTextColor,
//           fontWeight: widget.fontWeight,
//         ),
//         filled: true,
//         fillColor: AppColor.appwhite,
//         suffixIcon: IconButton(
//           icon: Icon(
//             _obscureText ? Icons.visibility : Icons.visibility_off,
//             color: widget.hintTextColor,
//           ),
//           onPressed: () {
//             setState(() {
//               _obscureText = !_obscureText;
//             });
//           },
//         ),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10.0),
//           borderSide: BorderSide(color: widget.borderColor, width: 1.0),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10.0),
//           borderSide: BorderSide(color: widget.borderColor, width: 1.0),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10.0),
//           borderSide: BorderSide(color: widget.borderColor, width: 1.0),
//         ),
//         errorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10.0),
//           borderSide: BorderSide(color: widget.borderColor, width: 1.0),
//         ),
//       ),
//     );
//   }
// }