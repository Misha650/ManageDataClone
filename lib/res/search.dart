// import 'package:flutter/material.dart';

// import 'app_colors.dart';
// import 'text_style.dart';

// class SearchBoxWidget extends StatelessWidget {
//   final double width;
//   final String hintText;
//   final Color backgroundColor;
//   final Color borderColor;
//   final double? height;
//   final Color hintTextColor;
//   final controller;
//   final ValueChanged<String>? onChanged;
//   final IconData? icon; // Add icon parameter
//   final Color iconColor; // Add icon color parameter

//   const SearchBoxWidget({
//     super.key,
//     this.height = 350,
//     this.controller,
//     this.width = 410,
//     this.hintText = "search user by id, name, phone",
//     this.backgroundColor = Colors.transparent,
//     this.borderColor = AppColor.appwhite,
//     this.hintTextColor = AppColor.appblue1,
//     this.onChanged,
//     this.icon = Icons.search, // Default icon is search
//     this.iconColor = AppColor.appblue1, // Default icon color
//   });

//   @override

//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: width,
//       child: TextField(
//         controller: controller,
//         onChanged: onChanged,
//         decoration: InputDecoration(
//           filled: true,
//           fillColor: backgroundColor,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(15.0),
//             borderSide: BorderSide(color: borderColor, width: 1.0),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(15.0),
//             borderSide: BorderSide(color: borderColor, width: 1.0),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(15.0),
//             borderSide: BorderSide(color: borderColor, width: 1.5),
//           ),
//           hintText: hintText,
//           hintStyle: AppTextStyle.nunitoSans_14_blue1.copyWith(
//             color: hintTextColor,
//           ),
//           contentPadding: EdgeInsets.only(left: 15),
//         ),
//       ),
//     );
//   }
// }
