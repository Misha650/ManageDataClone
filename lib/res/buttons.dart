// ignore_for_file: unnecessary_null_comparison
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'app_colors.dart';
import 'components/boxdecoration.dart';
import 'text_style.dart';

class AppButton {
  final String? img;
  final String? title;
  final String? title2;
  
  final String? followers;
  AppButton({this.title, this.title2, this.followers, this.img});
  // static Container blackbutton({required String title}) {
  //   return Container(
  //     width: 120,
  //     height: 30,
  //     decoration: AppBoxDecorationStyle.blackbutton,
  //     child: Row(
  //       crossAxisAlignment: CrossAxisAlignment.center,
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         title != null
  //             ? Text(title, style: AppTextStyle.MadimiOne_11_white)
  //             : SizedBox(),
  //         SizedBox(width: 5),
  //         Icon(
  //           FontAwesomeIcons.arrowRight,
  //           size: 15,
  //           color: AppColor.whiteColor,
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // static Container EditTask({required String title}) {
  //   return Container(
  //     width: 110,
  //     height: 30,
  //     decoration: AppBoxDecorationStyle.border,
  //     child: Center(child: Text(title, style: AppTextStyle.MadimiOne_11_grey)),
  //   );
  // }

  // static Widget black30({required String title, VoidCallback? onpressed}) {
  //   return InkWell(
  //     onTap: onpressed,
  //     child: Container(
  //       height: 50,
  //       width: double.infinity,
  //       decoration: AppBoxDecorationStyle.black30,
  //       child: Center(
  //         child: Text(title, style: AppTextStyle.MadimiOne_9_white),
  //       ),
  //     ),
  //   );
  // }
  //   static Widget black130({required String title, VoidCallback? onpressed}) {
  //   return InkWell(
  //     onTap: onpressed,
  //     child: Container(
  //       height: 55,
  //       width: double.infinity,
  //       decoration: AppBoxDecorationStyle.black30,
  //       child: Center(
  //         child: Text(title, style: AppTextStyle.MadimiOne_15_white),
  //       ),
  //     ),
  //   );
  // }

  // static Container lightpurple({required String title}) {
  //   return Container(
  //     height: 50,
  //     width: double.infinity,
  //     decoration: AppBoxDecorationStyle.black30,
  //     child: Center(child: Text(title, style: AppTextStyle.MadimiOne_9_white)),
  //   );
  // }

  // static Container lightblack30({required String title}) {
  //   return Container(
  //     height: 50,
  //     width: double.infinity,
  //     decoration: AppBoxDecorationStyle.lightblack30,
  //     child: Center(child: Text(title, style: AppTextStyle.MadimiOne_9_white)),
  //   );
  // }

  // static Container buttonlightpurple({required String title}) {
  //   return Container(
  //     height: 30,
  //     width: 190,
  //     margin: EdgeInsets.symmetric(vertical: 22),

  //     decoration: AppBoxDecorationStyle.buttonlightpurple,
  //     child: Row(
  //       crossAxisAlignment: CrossAxisAlignment.center,
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         Text(title, style: AppTextStyle.MadimiOne_9_black),
  //         SizedBox(width: 2),
  //         Icon(
  //           Icons.arrow_right,
  //           size: 10,
  //           color: AppColor.black,
  //         ), //Icon(FontAwesomeIcons.arrowRight, size: 15, color: AppColor.black),
  //       ],
  //     ),
  //   );
  // }

  // static Widget Addbutton() {
  //   return Align(
  //     alignment: Alignment.bottomRight,
  //     child: Container(
  //       height: 60,
  //       width: 60,
  //       decoration: BoxDecoration(
  //         shape: BoxShape.circle,
  //         color: Colors.deepPurple,
  //       ),
  //       child: Center(
  //         child: Icon(
  //           Icons.add,
  //           color: const Color.fromARGB(255, 206, 198, 218),
  //         ),
  //       ),
  //     ),
  //   );
  // }
  Container linearbutton30radious() {
    return Container(
      width: 60,
      height: 23,
      decoration: AppBoxDecorationStyle.linearbutton,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (title != null) Text(title!, style: AppTextStyle.dmSans_8_white),
        ],
      ),
    );
  }
  static Widget IconButton({
    
    VoidCallback? onTap,
    required IconData myicon,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(50), // Ripple matches shape
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange.shade300, Colors.orange.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.orange.shade200,
              blurRadius: 12,
              offset: const Offset(4, 4),
            ),
          ],
        ),
        child: Icon(
          myicon, // 💡 Choose any beautiful icon
          size: 36,
          color: Colors.white,
        ),
      ),
    );
  } //----------------------------------------------------------------------------------------------------
}
