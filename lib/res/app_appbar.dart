// import 'dart:ui';

// import 'package:flutter/material.dart';

// import 'text_style.dart';

// class ProAppbar {
//   final String? img;
//   final String? title;
//   final IconData? icon1;
//     final IconData? icon2;

//   final String? title2;
//   final String? followers;
//   final VoidCallback? onpressed;
//     final VoidCallback? onpressed1;


//   ProAppbar({
//     this.title,
//     this.title2,
//     this.icon1,
//     this.icon2,
//     this.followers,
//     this.onpressed,
//     this.onpressed1,
//     this.img,
//   });

//   static AppBar titleAppBar({required String title, VoidCallback? onpressed}) {
//     return AppBar(
//       backgroundColor: Colors.transparent,
//       leading: IconButton(
//         icon: Icon(Icons.chevron_left, size: 35, color: Colors.black),
//         onPressed: onpressed,
//       ),
//       title: Text(title, style: AppTextStyle.MadimiOne_18_dynaPuff_900),
//       centerTitle: true,
//       elevation: 0,
//       foregroundColor: Colors.black,
//     );
//   }

//   static AppBar LeftIconTwo({required IconData icon1, required IconData icon2,VoidCallback? onpressed, VoidCallback? onpressed1,}) {
//     return AppBar(
//       backgroundColor: Colors.transparent,
//       actions: [
//         IconButton(
//           icon: Icon(icon1, color: Colors.black,),
//           onPressed: onpressed,
//         ),
//         IconButton(
//           icon: Icon(icon2, color: Colors.black,),
//           onPressed:onpressed1,
//         ),
//       ],
//     );
//   }

//   static AppBar BackAppBar({VoidCallback? onpressed}) {
//     return AppBar(
//       backgroundColor: Colors.transparent,
//       leading: IconButton(
//         icon: Icon(Icons.chevron_left, size: 35, color: Colors.black),
//         onPressed: onpressed,
//       ),
//       elevation: 0,
//       foregroundColor: Colors.black,
//     );
//   }



//     static AppBar BackAppBarwhite({VoidCallback? onpressed}) {
//     return AppBar(
//       backgroundColor: Colors.transparent,
//       leading: IconButton(
//         icon: Icon(Icons.cancel_outlined, size: 35, color: Colors.white),
//         onPressed: onpressed,
//       ),
//       elevation: 0,
//       foregroundColor: Colors.white,
//     );
//   }
// }
