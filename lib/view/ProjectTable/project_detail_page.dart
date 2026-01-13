
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class ProjectDetailPage extends StatelessWidget {
//   final Map<String, dynamic> formData;

//   const ProjectDetailPage({
//     Key? key,
//     required this.formData,
//     required String formId,
//   }) : super(key: key);

//   Widget _buildSectionTitle(String title) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Text(
//         title,
//         style: const TextStyle(
//           fontSize: 18,
//           fontWeight: FontWeight.bold,
//           color: Colors.blue,
//         ),
//       ),
//     );
//   }

//   Widget _buildKeyValueTile(String key, dynamic value) {
//     return ListTile(dense: true, title: Text("$key: $value"));
//   }

//   @override
//   Widget build(BuildContext context) {
//       DateTime? createdAt;

//   if (formData["createdAt"] is DateTime) {
//     createdAt = formData["createdAt"] as DateTime;
//   } else if (formData["createdAt"] is Timestamp) {
//     createdAt = (formData["createdAt"] as Timestamp).toDate();
//   } else {
//     createdAt = null;
//   }

//   final formattedDate = createdAt != null
//       ? DateFormat("dd MMM yyyy").format(createdAt)
//       : "N/A";

//     return Scaffold(
//       appBar: AppBar(title: const Text("Project Details")),
//       body: Padding(
//         padding: const EdgeInsets.all(12),
//         child: ListView(
//           children: [
//             Card(
//               elevation: 2,
//               child: ListTile(
//                 title: Text("Created At"),
//                 subtitle: Text(formattedDate),
//                 leading: const Icon(Icons.calendar_today),
//               ),
//             ),

//             /// Milestones
//             if (formData["milestones"] != null) ...[
//               // _buildSectionTitle("Milestones"),
//               ...List.generate((formData["milestones"] as List).length, (i) {
//                 final milestone = formData["milestones"][i];
//                 return Card(
//                   child: ListTile(
//                     leading: CircleAvatar(child: Text("${i + 1}")),
//                     title: Text(milestone["keyTitle"] ?? ""),
//                     subtitle: Text("Amount Paid: ${milestone["amountPaid"]}"),
//                   ),
//                 );
//               }),
//             ],

//             /// Fields
//             if (formData["fields"] != null) ...[
//               // _buildSectionTitle("Fields"),
//               ...List.generate((formData["fields"] as List).length, (i) {
//                 final field = formData["fields"][i];
//                 return Card(
//                   child: ListTile(
//                     leading: CircleAvatar(child: Text("${i + 1}")),
//                     title: Text(field["keyTitle"] ?? ""),
//                     subtitle: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         if (field["value"] != null)
//                           Text("Value: ${field["value"]}"),
//                         Text("Amount Paid: ${field["amountPaid"] ?? 0}"),
//                       ],
//                     ),
//                   ),
//                 );
//               }),
//             ],

//             /// Dual Fields
//             if (formData["dualFields"] != null) ...[
//               // _buildSectionTitle("Dual Fields"),
//               ...List.generate((formData["dualFields"] as List).length, (i) {
//                 final dual = formData["dualFields"][i];
//                 return Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       dual["keyTitle"] ?? "",
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     ...List.generate((dual["myValue"] as List).length, (j) {
//                       final val = dual["myValue"][j];
//                       return Card(
//                         child: ListTile(
//                           leading: CircleAvatar(child: Text("${j + 1}")),
//                           title: Text(val["title"] ?? ""),
//                           subtitle: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               if (val["description"] != null &&
//                                   val["description"].toString().isNotEmpty)
//                                 Text("Description: ${val["description"]}"),
//                               Text(
//                                 "Paid: ${val["amountPaid"]}, Balance: ${val["balance"]}",
//                               ),
//                             ],
//                           ),
//                           trailing: Icon(
//                             val["remembered"] == true
//                                 ? Icons.bookmark
//                                 : Icons.bookmark_border,
//                             color: val["remembered"] == true
//                                 ? Colors.orange
//                                 : Colors.grey,
//                           ),
//                         ),
//                       );
//                     }),
//                   ],
//                 );
//               }),
//             ],

//             /// Labour Fields
//             if (formData["labourFields"] != null) ...[
//               // _buildSectionTitle("Labour Fields"),
//               ...List.generate((formData["labourFields"] as List).length, (i) {
//                 final lf = formData["labourFields"][i];
//                 return Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       lf["keyTitle"] ?? "",
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     ...List.generate((lf["myValue"] as List).length, (j) {
//                       final worker = lf["myValue"][j];
//                       return Card(
//                         child: ListTile(
//                           leading: CircleAvatar(child: Text("${j + 1}")),
//                           title: Text(worker["title"] ?? ""),
//                           subtitle: Text("Paid: ${worker["amountPaid"]}"),
//                           trailing: Icon(
//                             worker["remembered"] == true
//                                 ? Icons.bookmark
//                                 : Icons.bookmark,
//                             color: worker["remembered"] == true
//                                 ? Colors.orange
//                                 : Colors.grey,
//                           ),
//                         ),
//                       );
//                     }),
//                   ],
//                 );
//               }),
//             ],

//             Card(
//               elevation: 2,
//               child: Column(
//                 children: [
//                   _buildKeyValueTile("Owner Paid", formData["ownerPaid"] ?? 0),
//                   _buildKeyValueTile(
//                     "Total Paid",
//                     formData["totalAmountPaid"] ?? 0,
//                   ),
//                   _buildKeyValueTile(
//                     "Total Balance",
//                     formData["totalBalance"] ?? 0,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
