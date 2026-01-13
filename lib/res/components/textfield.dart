// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';
// import 'package:intl_phone_field/intl_phone_field.dart';

// import '../../View_Widgets/country_code.dart';
// import '../../view_models/Controller/auth_controller.dart';
// import '../app_colors.dart';

// class AppFormField extends StatefulWidget {
//   final String? hintText;
//   final String? labelText;
//   final Widget? prefixIcon;
//   final IconData? suffixIcon;
//   final ValueChanged<String>? onChanged;
//   final VoidCallback? onSuffixIconClick;
//   final TextEditingController? controller;
//   final TextInputType? keyboardType;
//   final int? maxLength, maxLines, minLines;
//   final bool? digitsOnly;
//   final bool? isOptional;
//   final bool? enabled;
//   final List<TextInputFormatter>? inputFormatters;
//   final bool isValidationEnabled;

//   const AppFormField({
//     super.key,
//     this.labelText,
//     this.isValidationEnabled = true,
//     this.hintText,
//     this.prefixIcon,
//     this.controller,
//     this.digitsOnly,
//     this.inputFormatters,
//     this.keyboardType,
//     this.maxLength,
//     this.maxLines = 1,
//     this.minLines,
//     this.enabled = true,
//     this.onChanged,
//     this.onSuffixIconClick,
//     this.isOptional = false,
//     this.suffixIcon,
//   });

//   @override
//   _AppFormFieldState createState() => _AppFormFieldState();
// }

// class _AppFormFieldState extends State<AppFormField> {
//   bool _obscureText = true; // Toggle password visibility

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             if (widget.labelText != null)
//               Text(
//                 widget.labelText!,
//                 style: TextStyle(
//                     color: AppColor.primaryColor,
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500),
//               ),
//             widget.isOptional == true
//                 ? const Text(
//                     "Optional",
//                     style: TextStyle(
//                         color: Color(0xff818181),
//                         fontSize: 13,
//                         fontWeight: FontWeight.w500),
//                   )
//                 : const SizedBox.shrink(),
//           ],
//         ),
//         const SizedBox(height: 4),
//         TextFormField(
//           controller: widget.controller,
//           obscureText: widget.keyboardType == TextInputType.visiblePassword
//               ? _obscureText
//               : false, // Toggle for password
//           maxLength: widget.maxLength,
//           minLines: widget.minLines,
//           maxLines: widget.maxLines, // Prevents multiline input
//           keyboardType: widget.keyboardType ?? TextInputType.text,
//           enabled: widget.enabled,
//           inputFormatters: widget.inputFormatters,
//           style: TextStyle(color: AppColor.whiteColor),
//           decoration: InputDecoration(
//               hintText: widget.hintText,
//               fillColor: AppColor.whiteColor,
//               prefixIcon: widget.prefixIcon,
//               prefixIconColor: AppColor.primaryColor,
//               suffixIcon: widget.keyboardType == TextInputType.visiblePassword
//                   ? IconButton(
//                       onPressed: () {
//                         setState(() {
//                           _obscureText = !_obscureText;
//                         });
//                       },
//                       icon: Icon(
//                         _obscureText ? Icons.visibility_off : Icons.visibility,
//                         color: AppColor.primaryColor,
//                       ),
//                     )
//                   : (widget.suffixIcon != null
//                       ? IconButton(
//                           onPressed: widget.onSuffixIconClick,
//                           icon: Icon(
//                             widget.suffixIcon,
//                             color: AppColor.primaryColor,
//                           ),
//                         )
//                       : null),
//               hintStyle: const TextStyle(
//                   color: Color(0xffCBCBCB),
//                   fontSize: 16,
//                   fontWeight: FontWeight.normal),
//               enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: const BorderSide(color: Color(0xffEBEBEB))),
//               focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: const BorderSide(
//                     color: AppColor.primaryColor,
//                   )),
//               disabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: const BorderSide(
//                       color: Color.fromARGB(171, 129, 128, 128)))),
//           validator: widget.isValidationEnabled
//               ? (String? value) {
//                   if (value == null || value.isEmpty) {
//                     return '${widget.labelText} is required';
//                   }
//                   if (widget.keyboardType == TextInputType.emailAddress) {
//                     final emailRegex = RegExp(
//                         r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
//                     if (!emailRegex.hasMatch(value)) {
//                       return 'Enter a valid email address';
//                     }
//                   }
//                   if (widget.keyboardType == TextInputType.visiblePassword) {
//                     if (value.length < 8) {
//                       return 'Password must be at least 8 characters';
//                     }
//                   }
//                   return null;
//                 }
//               : null,
//         ),
//       ],
//     );
//   }
// }

// // class CountryCodeField extends StatefulWidget {
// //   const CountryCodeField({
// //     Key? key,
// //     required this.authController,
// //   }) : super(key: key);
// //   final AuthController authController;
// //   @override
// //   _CountryCodeFieldState createState() => _CountryCodeFieldState();
// // }

// // class _CountryCodeFieldState extends State<CountryCodeField> {
// //   String selectedCountryCode = '+92'; // Default country code

// //   void _openCountryCodeDialog() {
// //     showDialog(
// //       context: context,
// //       builder: (BuildContext context) {
// //         return CountryCodeDialog(
// //           onCountrySelected: (String countryCode) {
// //             setState(() {
// //               selectedCountryCode = countryCode;
// //               widget.authController.countryCode.value.text = countryCode;
// //             });
// //           },
// //         );
// //       },
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return GestureDetector(
// //       onTap: _openCountryCodeDialog,
// //       child: AbsorbPointer(
// //           child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Row(
// //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //             children: [
// //               Text(
// //                 "Country",
// //                 style: TextStyle(
// //                     color: AppColor.whiteColor,
// //                     fontSize: 14,
// //                     fontWeight: FontWeight.w500),
// //               ),
// //             ],
// //           ),
// //           const SizedBox(height: 4),
// //           TextFormField(
// //             controller: widget.authController.countryCode.value,
// //             decoration: InputDecoration(
// //                 hintText: "Country",
// //                 fillColor: AppColor.whiteColor,
// //                 prefixIcon: Center(child: Text("+92")),
// //                 // const Icon(PhosphorIcons.globe_hemisphere_west),
// //                 suffixIcon: Icon(Icons.arrow_drop_down),
// //                 hintStyle: const TextStyle(
// //                     color: Color(0xffCBCBCB),
// //                     fontSize: 16,
// //                     fontWeight: FontWeight.normal),
// //                 enabledBorder: OutlineInputBorder(
// //                     borderRadius: BorderRadius.circular(12),
// //                     borderSide: const BorderSide(color: Color(0xffEBEBEB))),
// //                 focusedBorder: OutlineInputBorder(
// //                     borderRadius: BorderRadius.circular(12),
// //                     borderSide: const BorderSide(color: Color(0xffEBEBEB)))),
// //           ),
// //         ],
// //       )),
// //     );
// //   }
// // }

// class CountryCodeDialog extends StatefulWidget {
//   final ValueChanged<String> onCountrySelected;

//   const CountryCodeDialog({Key? key, required this.onCountrySelected})
//       : super(key: key);

//   @override
//   _CountryCodeDialogState createState() => _CountryCodeDialogState();
// }

// class _CountryCodeDialogState extends State<CountryCodeDialog> {
//   List<Map<String, String>> filteredCountries = countryCodes;
//   TextEditingController searchController = TextEditingController();

//   void _filterCountries(String query) {
//     setState(() {
//       filteredCountries = countryCodes
//           .where((country) =>
//               country['name']!.toLowerCase().contains(query.toLowerCase()) ||
//               country['code']!.contains(query))
//           .toList();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(
//               controller: searchController,
//               onChanged: _filterCountries,
//               decoration: InputDecoration(
//                 prefixIcon: Icon(Icons.search),
//                 hintText: 'Search by country or code',
//               ),
//             ),
//             Expanded(
//               child: ListView.builder(
//                 shrinkWrap: true,
//                 itemCount: filteredCountries.length,
//                 itemBuilder: (BuildContext context, int index) {
//                   final country = filteredCountries[index];
//                   return ListTile(
//                     title: Text(country['name']!),
//                     trailing: Text(country['code']!),
//                     onTap: () {
//                       widget.onCountrySelected(country['code']!);
//                       Navigator.of(context).pop();
//                     },
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// Widget searchTextField(title, memberController) {
//   return TextFormField(
//     onChanged: (value) {
//       // memberController.updateSearchQuery(value); // Update search query
//     },
//     decoration: InputDecoration(
//         hintText: "$title",
//         fillColor: AppColor.whiteColor,
//         prefixIcon: Icon(Icons.search),
//         hintStyle: const TextStyle(
//             color: Color(0xffCBCBCB),
//             fontSize: 16,
//             fontWeight: FontWeight.normal),
//         enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: const BorderSide(color: Color(0xffEBEBEB))),
//         focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: const BorderSide(color: Color(0xffEBEBEB)))),
//   );
// }

// class DateFormField extends StatefulWidget {
//   final String? labelText;
//   final String? hintText;
//   final Widget? prefixIcon;

//   final controller;
//   final bool isValidationEnabled;
//   const DateFormField(
//       {Key? key,
//       this.labelText,
//       this.hintText,
//       this.prefixIcon,
//       this.controller,
//       this.isValidationEnabled = true})
//       : super(key: key);

//   @override
//   _DateFormFieldState createState() => _DateFormFieldState();
// }

// class _DateFormFieldState extends State<DateFormField> {
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () async {
//         DateTime? selectedDate = await showDatePicker(
//           context: context,
//           initialDate: DateTime.now(),
//           firstDate: DateTime(2000),
//           lastDate: DateTime(2100),
//         );

//         if (selectedDate != null) {
//           String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
//           widget.controller!.updateDate(formattedDate);
//         }
//       },
//       child: AbsorbPointer(
//         // Prevent manual text input
//         child: TextFormField(
//           validator: widget.isValidationEnabled
//               ? (String? value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Date required';
//                   }
//                   return null;
//                 }
//               : null,
//           controller: widget.controller!.dateCTR.value,
//           enabled: true, // Make the field appear disabled
//           decoration: InputDecoration(
//             hintText: widget.hintText,
//             prefixIcon: widget.prefixIcon,
//             fillColor: Colors.white,
//             filled: true,
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: const BorderSide(color: Color(0xffEBEBEB)),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: const BorderSide(color: Color(0xffEBEBEB)),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class DateFormField2 extends StatefulWidget {
//   final String? labelText;
//   final String? hintText;
//   final Widget? prefixIcon;
//   final bool isEdit;
//   final controller;
//   final bool isValidationEnabled;
//   const DateFormField2(
//       {Key? key,
//       this.labelText,
//       this.hintText,
//       required this.isEdit,
//       this.prefixIcon,
//       this.controller,
//       this.isValidationEnabled = true})
//       : super(key: key);

//   @override
//   _DateFormField2State createState() => _DateFormField2State();
// }

// class _DateFormField2State extends State<DateFormField2> {
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () async {
//         DateTime? selectedDate = await showDatePicker(
//           context: context,
//           initialDate: DateTime.now(),
//           firstDate: DateTime(2000),
//           lastDate: DateTime(2100),
//         );

//         if (selectedDate != null) {
//           String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
//           widget.controller!.updateDate(formattedDate);
//         }
//       },
//       child: AbsorbPointer(
//         // Prevent manual text input
//         child: TextFormField(
//           validator: widget.isValidationEnabled
//               ? (String? value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Date required';
//                   }
//                   return null;
//                 }
//               : null,
//           controller: widget.controller!.dateCTR.value,
//           enabled: true, // Make the field appear disabled
//           decoration: InputDecoration(
//             hintText: widget.hintText,
//             prefixIcon: widget.prefixIcon,
//             fillColor: Colors.white,
//             filled: true,
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: const BorderSide(color: Color(0xffEBEBEB)),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: const BorderSide(color: Color(0xffEBEBEB)),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ignore: must_be_immutable
// class AppFormFieldCountry extends StatelessWidget {
//   final String? labelText;
//   final bool isValidationEnabled;

//   final AuthController authController;

//   AppFormFieldCountry({
//     super.key,
//     this.labelText,
//     this.isValidationEnabled = true,
//     required this.authController,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         if (labelText != null)
//           Text(
//             labelText!,
//             style: TextStyle(
//               color: AppColor.primaryColor,
//               fontSize: 14,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         const SizedBox(height: 4),
//         IntlPhoneField(
//           controller: authController.phoneController.value,
//           dropdownTextStyle: TextStyle(color: Colors.white),
//           style: TextStyle(color: AppColor.whiteColor),
//           decoration: InputDecoration(
//             hintText: "Phone",
//             fillColor: AppColor.whiteColor,
//             prefixIconColor: AppColor.primaryColor,
//             hintStyle: const TextStyle(
//               color: Color(0xffCBCBCB),
//               fontSize: 16,
//               fontWeight: FontWeight.normal,
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: const BorderSide(color: Color(0xffEBEBEB)),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: const BorderSide(
//                 color: AppColor.primaryColor,
//               ),
//             ),
//           ),
//           initialCountryCode: 'PK', // Set default country code (Pakistan)
//           onCountryChanged: (country) {
//             authController.updateCountryISO(country.code, country.dialCode);
//             authController.update(); // Refresh UI if using GetX
//           },
//           // onChanged: (phone) {
//           //   authController.updatePhone(phone);
//           // },
//           validator: isValidationEnabled
//               ? (value) {
//                   if (value == null || value.number.isEmpty) {
//                     return 'Phone number is required';
//                   }
//                   return null;
//                 }
//               : null,
//         ),
//       ],
//     );
//   }
// }

// class KycDropdownField extends StatefulWidget {
//   final TextEditingController controller;
//   final String hintText;
//   final bool isValidationEnabled;

//   const KycDropdownField({
//     Key? key,
//     required this.controller,
//     this.hintText = "Select Document Type",
//     this.isValidationEnabled = true,
//   }) : super(key: key);

//   @override
//   _KycDropdownFieldState createState() => _KycDropdownFieldState();
// }

// class _KycDropdownFieldState extends State<KycDropdownField> {
//   final List<String> documentTypes = [
//     "Passport",
//     "National ID",
//     "Driver’s License",
//     "Social Security Card",
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               "Document Type",
//               style: TextStyle(
//                   color: AppColor.primaryColor,
//                   fontSize: 14,
//                   fontWeight: FontWeight.w500),
//             ),
//             const SizedBox.shrink(),
//           ],
//         ),
//         DropdownButtonFormField<String>(
//           value:
//               widget.controller.text.isNotEmpty ? widget.controller.text : null,
//           items: documentTypes.map((String type) {
//             return DropdownMenuItem<String>(
//               value: type,
//               child: Text(type, style: TextStyle(color: Colors.black)),
//             );
//           }).toList(),
//           onChanged: (String? newValue) {
//             setState(() {
//               widget.controller.text = newValue ?? "";
//             });
//           },
//           style: TextStyle(
//             color: AppColor.primaryColor,
//           ),
//           decoration: InputDecoration(
//             hintText: widget.hintText,
//             hintStyle: const TextStyle(
//                 color: Color(0xffCBCBCB),
//                 fontSize: 16,
//                 fontWeight: FontWeight.normal),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: const BorderSide(
//                 color: AppColor.primaryColor,
//               ),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: const BorderSide(
//                 color: AppColor.primaryColor,
//               ),
//             ),
//             filled: true,
//             // fillColor: Colors.white,
//           ),
//           validator: widget.isValidationEnabled
//               ? (String? value) {
//                   if (value == null || value.isEmpty) {
//                     return "Document type is required";
//                   }
//                   return null;
//                 }
//               : null,
//         ),
//       ],
//     );
//   }
// }
