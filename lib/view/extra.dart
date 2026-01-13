// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter_speed_dial/flutter_speed_dial.dart'; // Add in pubspec

// // class MyprojectDetailPage extends StatefulWidget {
// //   final String projectId;
// //   const MyprojectDetailPage({super.key, required this.projectId});

// //   @override
// //   State<MyprojectDetailPage> createState() => _MyprojectDetailPageState();
// // }

// // class _MyprojectDetailPageState extends State<MyprojectDetailPage> {
// //   final uid = FirebaseAuth.instance.currentUser!.uid;

// //   final TextEditingController ownerPaidController = TextEditingController();
// //   final TextEditingController totalAmountPaidController =
// //       TextEditingController();
// //   final TextEditingController totalBalanceController = TextEditingController();
// //   int? _simpleDeleteIndex;
// //   int? _milestoneDeleteIndex;
// //   int? _labourDeleteIndex; // for main labour card
// //   int? _dualDeleteIndex; // for main dual card
  
// //   // for deleting a whole Dual card

// //   //dropdown hide and show
// //   final List<bool> _milestoneExpanded = []; // NEW
// //   final List<bool> _simpleExpanded = [];
// //   final List<bool> _dualExpanded = []; // NEW
// //   final List<bool> _labourExpanded = []; // NEW


// //   Map<DualFieldControllers, int?> _dualEntryDelete =
// //       {}; // delete specific entry

// //   void _recalculateTotals() {
// //     double totalPaid = 0;

// //     // Simple fields
// //     for (final c in amountPaidControllers) {
// //       totalPaid += double.tryParse(c.text.trim()) ?? 0;
// //     }

// //     // Milestones
// //     for (final c in milestoneAmountControllers) {
// //       totalPaid += double.tryParse(c.text.trim()) ?? 0;
// //     }

// //     // Dual Fields
// //     for (final dual in dualFields) {
// //       for (final e in dual.entries) {
// //         totalPaid += double.tryParse(e.amountPaidController.text.trim()) ?? 0;
// //       }
// //     }

// //     // Labour Fields
// //     for (final lf in labourFields) {
// //       for (final e in lf.entries) {
// //         totalPaid += double.tryParse(e.amountPaidController.text.trim()) ?? 0;
// //       }
// //     }

// //     // Always update Total Amount Paid
// //     totalAmountPaidController.text = totalPaid.toStringAsFixed(2);

// //     // ✅ Only update balance if ownerPaid is not empty
// //     final ownerPaidText = ownerPaidController.text.trim();
// //     if (ownerPaidText.isEmpty) {
// //       totalBalanceController.clear(); // keep it blank
// //     } else {
// //       final ownerPaid = double.tryParse(ownerPaidText) ?? 0;
// //       final balance = ownerPaid - totalPaid;
// //       totalBalanceController.text = balance.toStringAsFixed(2);
// //     }
// //   }

// //   bool _showAddMenu = false; // ✅ NEW - Controls menu visibility
// //   // ---------------- Simple fields ----------------
// //   final List<TextEditingController> keyControllers = [];
// //   final List<TextEditingController> valueControllers = [];
// //   // --- Add new list of controllers ---
// //   final List<TextEditingController> amountPaidControllers = []; // ✅ NEW

// //   // ---------------- Milestones fields (NEW) ----------------
// //   final List<TextEditingController> milestoneTitleControllers = [];
// //   final List<TextEditingController> milestoneAmountControllers = [];

// //   // ---------------- Dual fields ----------------
// //   final List<DualFieldControllers> dualFields = [];

// //   // ---------------- Labour fields ----------------
// //   final List<LabourFieldControllers> labourFields = [];

// //   @override
// //   void initState() {
// //     super.initState();
// //     _loadLatestForm();
// //   }

// //   Future<void> _loadLatestForm() async {
// //     final snap = await FirebaseFirestore.instance
// //         .collection('users')
// //         .doc(uid)
// //         .collection('projects')
// //         .doc(widget.projectId)
// //         .collection('formData')
// //         .orderBy('createdAt', descending: true)
// //         .limit(1)
// //         .get();

// //     if (snap.docs.isEmpty) return;
// //     final data = snap.docs.first.data();

// //     // -------- Simple --------
// //     for (var f in (data['fields'] ?? [])) {
// //       keyControllers.add(TextEditingController(text: f['title'] ?? ''));
// //       valueControllers.add(TextEditingController());
// //       amountPaidControllers.add(TextEditingController()); // keep blank if null
// //       _simpleExpanded.add(true); // start expanded
// //     }

// //     // -------- Milestones (NEW) --------
// //     for (var m in (data['milestones'] ?? [])) {
// //       milestoneTitleControllers.add(
// //         TextEditingController(text: m['title'] ?? ''),
// //       );
// //       milestoneAmountControllers.add(TextEditingController());
// //       _milestoneExpanded.add(true); // start expanded
// //     }

// //     // -------- Dual --------
// //     for (var df in (data['dualFields'] ?? [])) {
// //       final remembered = (df['myValue'] as List? ?? [])
// //           .where((e) => e['remembered'] == true)
// //           .toList();
// //       if (remembered.isEmpty) continue;
// //       final dual = DualFieldControllers();
// //       dual.mainKeyController.text = df['keyTitle'] ?? '';
// //       dual.entries = remembered.map((e) {
// //         final entry = DualEntryControllers();
// //         entry.titleController.text = e['title'] ?? '';
// //         entry.remembered = true;
// //         return entry;
// //       }).toList();
// //       dualFields.add(dual);
// //       _dualExpanded.add(true); // start expanded
// //     }

// //     // -------- Labour --------
// //     for (var lf in (data['labourFields'] ?? [])) {
// //       final remembered = (lf['myValue'] as List? ?? [])
// //           .where((e) => e['remembered'] == true)
// //           .toList();
// //       if (remembered.isEmpty) continue;
// //       final labour = LabourFieldControllers();
// //       labour.mainKeyController.text = lf['labourkeyTitle'] ?? '';
// //       labour.entries = remembered.map((e) {
// //         final entry = LabourEntryControllers();
// //         entry.titleController.text = e['title'] ?? '';
// //         entry.remembered = true;
// //         return entry;
// //       }).toList();
// //       labourFields.add(labour);
// //       _labourExpanded.add(true); // start expanded

// //     }

// //     setState(() {
// //       _recalculateTotals();
// //     });
// //   }

// //   // ---------- Add buttons ----------
// //   void _addField() {
// //     keyControllers.add(TextEditingController());
// //     valueControllers.add(TextEditingController());
// //     amountPaidControllers.add(TextEditingController()); // <-- FIX
// //     _simpleExpanded.add(true); // start expanded

// //     setState(() {});
// //   }

// //   void _addMilestone() {
// //     milestoneTitleControllers.add(TextEditingController());
// //     milestoneAmountControllers.add(TextEditingController());
// //     _milestoneExpanded.add(true); // start expanded
// //     setState(() {});
// //   }

// //   void _addDualField() {
// //     dualFields.add(DualFieldControllers());
// //     _dualExpanded.add(true); // start expanded
// //     setState(() {});
// //   }

// //   void _addDualEntry(DualFieldControllers dual) {
// //     setState(() => dual.entries.add(DualEntryControllers()));
// //   }

// //   void _addLabourField() {
// //     labourFields.add(LabourFieldControllers());
// //     _labourExpanded.add(true); // start expanded
// //     setState(() {});
// //   }

// //   void _addLabourEntry(LabourFieldControllers labour) {
// //     setState(() => labour.entries.add(LabourEntryControllers()));
// //   }

// //   // ---------- Submit ----------
// //   Future<void> _submit() async {
// //     // Simple fields
// //     final simpleFields = <Map<String, dynamic>>[];
// //     for (int i = 0; i < keyControllers.length; i++) {
// //       final k = keyControllers[i].text.trim();
// //       final v = valueControllers[i].text.trim();
// //       final amt =
// //           int.tryParse(amountPaidControllers[i].text.trim()) ?? 0; // ✅ NEW

// //       if (k.isNotEmpty)
// //         simpleFields.add({
// //           'title': k, 'value': v, 'amountPaid': amt, // ✅ NEW
// //         });
// //     }

// //     // Milestones (NEW)
// //     final milestones = <Map<String, dynamic>>[];
// //     for (int i = 0; i < milestoneTitleControllers.length; i++) {
// //       final t = milestoneTitleControllers[i].text.trim();
// //       final amt = int.tryParse(milestoneAmountControllers[i].text.trim()) ?? 0;
// //       if (t.isNotEmpty || amt != 0) {
// //         milestones.add({'title': t, 'amountPaid': amt});
// //       }
// //     }

// //     // Dual fields
// //     final dualData = <Map<String, dynamic>>[];
// //     for (var dual in dualFields) {
// //       final key = dual.mainKeyController.text.trim();
// //       if (key.isEmpty) continue;
// //       final entries = <Map<String, dynamic>>[];
// //       for (var e in dual.entries) {
// //         final t = e.titleController.text.trim();
// //         final d = e.descriptionController.text.trim();
// //         final paid = int.tryParse(e.amountPaidController.text.trim()) ?? 0;
// //         final bal = int.tryParse(e.balanceController.text.trim()) ?? 0;
// //         if (t.isNotEmpty ||
// //             d.isNotEmpty ||
// //             paid != 0 ||
// //             bal != 0 ||
// //             e.remembered) {
// //           entries.add({
// //             'title': t,
// //             'description': d,
// //             'amountPaid': paid,
// //             'balance': bal,
// //             'remembered': e.remembered,
// //           });
// //         }
// //       }
// //       if (entries.isNotEmpty)
// //         dualData.add({'keyTitle': key, 'myValue': entries});
// //     }

// //     // Labour fields
// //     final labourData = <Map<String, dynamic>>[];
// //     for (var lf in labourFields) {
// //       final key = lf.mainKeyController.text.trim();
// //       if (key.isEmpty) continue;
// //       final entries = <Map<String, dynamic>>[];
// //       for (var e in lf.entries) {
// //         final t = e.titleController.text.trim();
// //         final paid = int.tryParse(e.amountPaidController.text.trim()) ?? 0;
// //         if (t.isNotEmpty || paid != 0 || e.remembered) {
// //           entries.add({
// //             'title': t,
// //             'amountPaid': paid,
// //             'remembered': e.remembered,
// //           });
// //         }
// //       }
// //       if (entries.isNotEmpty) {
// //         labourData.add({'labourkeyTitle': key, 'myValue': entries});
// //       }
// //     }

// //     await FirebaseFirestore.instance
// //         .collection('users')
// //         .doc(uid)
// //         .collection('projects')
// //         .doc(widget.projectId)
// //         .collection('formData')
// //         .add({
// //           'fields': simpleFields,
// //           'milestones': milestones, // ✅ NEW
// //           'dualFields': dualData,
// //           'labourFields': labourData,
// //           'ownerPaid': double.tryParse(ownerPaidController.text.trim()) ?? 0,
// //           'totalAmountPaid':
// //               double.tryParse(totalAmountPaidController.text.trim()) ?? 0,
// //           'totalBalance':
// //               double.tryParse(totalBalanceController.text.trim()) ?? 0,
// //           'createdAt': FieldValue.serverTimestamp(),
// //         });

// //     if (!mounted) return;
// //     ScaffoldMessenger.of(
// //       context,
// //     ).showSnackBar(const SnackBar(content: Text('Form Data Saved')));
// //     Navigator.pop(context);
// //   }

// //   bool _dialOpen = false;

// //   // --- Your controller lists here (unchanged) ---

// //   @override
// //   Widget build(BuildContext context) {
// //     final theme = Theme.of(context);

// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('Project Details'),
// //         flexibleSpace: Container(
// //           decoration: const BoxDecoration(
// //             // gradient: LinearGradient(
// //             //   colors: [Color(0xff6a11cb), Color(0xff2575fc)],
// //             //   begin: Alignment.topLeft,
// //             //   end: Alignment.bottomRight,
// //             // ),
// //           ),
// //         ),
// //         elevation: 4,
// //       ),

// //       // ✅ Floating Speed Dial instead of add-menu column
// //       floatingActionButton: SpeedDial(
// //         icon: Icons.add,
// //         activeIcon: Icons.close,
// //         openCloseDial: ValueNotifier(_dialOpen),
// //         // backgroundColor: const Color(0xff6a11cb),
// //         // overlayColor: Colors.black,
// //         overlayOpacity: 0.4,
// //         children: [
// //           SpeedDialChild(
// //             child: const Icon(Icons.post_add, color: Colors.white),
// //             backgroundColor: Colors.orange,
// //             label: 'Add Task Set',
// //             onTap: _addDualField,
// //           ),
// //           SpeedDialChild(
// //             child: const Icon(Icons.list_alt, color: Colors.white),
// //             backgroundColor: Colors.teal,
// //             label: 'Add Task',
// //             onTap: _addLabourField,
// //           ),
// //           SpeedDialChild(
// //             child: const Icon(Icons.playlist_add, color: Colors.white),
// //             backgroundColor: Colors.indigo,
// //             label: 'Add Detail',
// //             onTap: _addField,
// //           ),
// //           SpeedDialChild(
// //             child: const Icon(Icons.notes, color: Colors.white),
// //             backgroundColor: Colors.deepPurple,
// //             label: 'Add Field',
// //             onTap: _addMilestone,
// //           ),
// //         ],
// //       ),

// //       body: Container(
// //         decoration: const BoxDecoration(
// //           // gradient: LinearGradient(
// //           //   colors: [Colors.white, Color(0xffeef1f5)],
// //           //   begin: Alignment.topCenter,
// //           //   end: Alignment.bottomCenter,
// //           // ),
// //         ),
// //         child: Padding(
// //           padding: const EdgeInsets.all(12),
// //           child: ListView(
// //             children: [
// //               const SizedBox(height: 8),
// //               _buildSectionHeader('Milestones'),
// //               ...List.generate(milestoneTitleControllers.length, _milestoneRow),

// //               _buildSectionHeader('Simple Fields'),
// //               ...List.generate(keyControllers.length, _simpleRow),

// //               _buildSectionHeader('Labour'),
// //               ...labourFields.map(_buildLabourCard),

// //               _buildSectionHeader('Task Sets'),
// //               ...dualFields.map(_buildDualCard),

// //               const SizedBox(height: 16),
// //               const SizedBox(height: 20),
// //               _buildSectionHeader('Summary'),
// //               TextField(
// //                 controller: ownerPaidController,
// //                 keyboardType: TextInputType.number,
// //                 decoration: _input('Owner Paid'),
// //                 onChanged: (_) => setState(_recalculateTotals),
// //               ),
// //               const SizedBox(height: 8),
// //               TextField(
// //                 controller: totalAmountPaidController,
// //                 readOnly: true,
// //                 decoration: _input('Total Amount Paid'),
// //               ),
// //               const SizedBox(height: 8),
// //               TextField(
// //                 controller: totalBalanceController,
// //                 readOnly: true,
// //                 decoration: _input('Total Balance'),
// //               ),
// //               const SizedBox(height: 20),

// //               ElevatedButton.icon(
// //                 icon: const Icon(Icons.save_alt),
// //                 style: ElevatedButton.styleFrom(
// //                   minimumSize: const Size.fromHeight(50),
// //                   backgroundColor: theme.primaryColor,
// //                   shape: RoundedRectangleBorder(
// //                     borderRadius: BorderRadius.circular(12),
// //                   ),
// //                 ),
// //                 onPressed: _submit,

// //                 label: const Text(
// //                   'Submit All',
// //                   style: TextStyle(fontSize: 20, color: Colors.white),
// //                 ),
// //               ),
// //               const SizedBox(height: 40),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   // ---------- Reusable UI ----------

// //   Widget _buildSectionHeader(String title) =>
// //       Padding(padding: const EdgeInsets.symmetric(vertical: 12));

// //   InputDecoration _input(String label) => InputDecoration(
// //     labelText: label,
// //     filled: true,
// //     // fillColor: Colors.white,
// //     border: OutlineInputBorder(
// //       borderRadius: BorderRadius.circular(12),
// //       borderSide: BorderSide.none,
// //     ),
// //     contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
// //   );

// //   Widget _simpleRow(int i) => GestureDetector(
// //     onLongPress: () => setState(() => _simpleDeleteIndex = i),
// //     child: Stack(
// //       children: [
// //         Card(
// //           elevation: 2,
// //           margin: const EdgeInsets.symmetric(vertical: 6),
// //           shape: RoundedRectangleBorder(
// //             borderRadius: BorderRadius.circular(12),
// //           ),
// //           child: Padding(
// //             padding: const EdgeInsets.all(12),
// //             child: Column(
// //               children: [
// //                 // ---- Title Row with arrow ----
// //                 Row(
// //                   children: [
// //                     Expanded(
// //                       child: TextField(
// //                         controller: keyControllers[i],
// //                         decoration: _input('Title ${i + 1}'),
// //                         minLines: 1,
// //                         maxLines: null,
// //                       ),
// //                     ),
// //                     IconButton(
// //                       icon: Icon(
// //                         _simpleExpanded[i]
// //                             ? Icons.keyboard_arrow_up
// //                             : Icons.keyboard_arrow_down,
// //                       ),
// //                       onPressed: () => setState(
// //                         () => _simpleExpanded[i] = !_simpleExpanded[i],
// //                       ),
// //                     ),
// //                   ],
// //                 ),

// //                 // ---- Show/Hide rest of fields ----
// //                 if (_simpleExpanded[i]) ...[
// //                   const SizedBox(height: 8),
// //                   TextField(
// //                     controller: valueControllers[i],
// //                     decoration: _input('Value'),
// //                   ),
// //                   const SizedBox(height: 8),
// //                   TextField(
// //                     controller: amountPaidControllers[i],
// //                     keyboardType: TextInputType.number,
// //                     decoration: _input('Amount Paid'),
// //                     onChanged: (_) => setState(_recalculateTotals),
// //                   ),
// //                 ],
// //               ],
// //             ),
// //           ),
// //         ),

// //         // ---- Delete icon ----
// //         if (_simpleDeleteIndex == i)
// //           Positioned(
// //             top: 4,
// //             right: 4,
// //             child: IconButton(
// //               icon: const Icon(Icons.delete, color: Colors.red),
// //               onPressed: () {
// //                 setState(() {
// //                   keyControllers.removeAt(i);
// //                   valueControllers.removeAt(i);
// //                   amountPaidControllers.removeAt(i);
// //                   _simpleExpanded.removeAt(i);
// //                   _simpleDeleteIndex = null;
// //                 });
// //                 _recalculateTotals();
// //               },
// //             ),
// //           ),
// //       ],
// //     ),
// //   );

// //   Widget _milestoneRow(int i) => GestureDetector(
// //     onLongPress: () => setState(() => _milestoneDeleteIndex = i),
// //     child: Stack(
// //       children: [
// //         Card(
// //           elevation: 2,
// //           margin: const EdgeInsets.symmetric(vertical: 6),
// //           shape: RoundedRectangleBorder(
// //             borderRadius: BorderRadius.circular(12),
// //           ),
// //           child: Padding(
// //             padding: const EdgeInsets.all(12),
// //             child: Column(
// //               children: [
// //                 // --- Title row with arrow ---
// //                 Row(
// //                   children: [
// //                     Expanded(
// //                       child: TextField(
// //                         controller: milestoneTitleControllers[i],
// //                         decoration: _input('Title ${i + 1}'),
// //                       ),
// //                     ),
// //                     IconButton(
// //                       icon: Icon(
// //                         _milestoneExpanded[i]
// //                             ? Icons.keyboard_arrow_up
// //                             : Icons.keyboard_arrow_down,
// //                       ),
// //                       onPressed: () => setState(
// //                         () => _milestoneExpanded[i] = !_milestoneExpanded[i],
// //                       ),
// //                     ),
// //                   ],
// //                 ),

// //                 // --- Collapsible content ---
// //                 if (_milestoneExpanded[i]) ...[
// //                   const SizedBox(height: 8),
// //                   TextField(
// //                     controller: milestoneAmountControllers[i],
// //                     keyboardType: TextInputType.number,
// //                     decoration: _input('Amount Paid'),
// //                     onChanged: (_) => setState(_recalculateTotals),
// //                   ),
// //                 ],
// //               ],
// //             ),
// //           ),
// //         ),

// //         // --- Delete icon overlay ---
// //         if (_milestoneDeleteIndex == i)
// //           Positioned(
// //             top: 4,
// //             right: 4,
// //             child: IconButton(
// //               icon: const Icon(Icons.delete, color: Colors.red),
// //               onPressed: () {
// //                 setState(() {
// //                   milestoneTitleControllers.removeAt(i);
// //                   milestoneAmountControllers.removeAt(i);
// //                   _milestoneExpanded.removeAt(i); // keep lists in sync
// //                   _milestoneDeleteIndex = null;
// //                 });
// //                 _recalculateTotals();
// //               },
// //             ),
// //           ),
// //       ],
// //     ),
// //   );
// //   Widget _buildDualCard(DualFieldControllers dual) {
// //   final i = dualFields.indexOf(dual);

// //   return GestureDetector(
// //     onLongPress: () => setState(() => _dualDeleteIndex = i),
// //     child: Stack(
// //       children: [
// //         Card(
// //           elevation: 3,
// //           shape: RoundedRectangleBorder(
// //             borderRadius: BorderRadius.circular(16),
// //           ),
// //           margin: const EdgeInsets.symmetric(vertical: 8),
// //           child: Padding(
// //             padding: const EdgeInsets.all(12),
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 // --- Row with Main Key + Arrow ---
// //                 Row(
// //                   children: [
// //                     Expanded(
// //                       child: TextField(
// //                         controller: dual.mainKeyController,
// //                         decoration: _input('Main Key Title'),
// //                       ),
// //                     ),
// //                     IconButton(
// //                       icon: Icon(
// //                         _dualExpanded[i]
// //                             ? Icons.keyboard_arrow_up
// //                             : Icons.keyboard_arrow_down,
// //                       ),
// //                       onPressed: () => setState(() {
// //                         _dualExpanded[i] = !_dualExpanded[i];
// //                       }),
// //                     ),
// //                   ],
// //                 ),

// //                 // --- Collapsible content ---
// //                 if (_dualExpanded[i]) ...[
// //                   const SizedBox(height: 8),
// //                   ...dual.entries.map(_buildDualEntry(dual)),
// //                   Align(
// //                     alignment: Alignment.centerRight,
// //                     child: TextButton.icon(
// //                       icon: const Icon(Icons.add_circle_outline),
// //                       label: const Text('Add Entry'),
// //                       onPressed: () => _addDualEntry(dual),
// //                     ),
// //                   ),
// //                 ],
// //               ],
// //             ),
// //           ),
// //         ),

// //         // --- Delete overlay ---
// //         if (_dualDeleteIndex == i)
// //           Positioned(
// //             top: 4,
// //             right: 4,
// //             child: IconButton(
// //               icon: const Icon(Icons.delete, color: Colors.red),
// //               onPressed: () {
// //                 setState(() {
// //                   dualFields.removeAt(i);
// //                   _dualExpanded.removeAt(i); // keep synced
// //                   _dualDeleteIndex = null;
// //                 });
// //                 _recalculateTotals();
// //               },
// //             ),
// //           ),
// //       ],
// //     ),
// //   );
// // }

// //   Widget Function(DualEntryControllers) _buildDualEntry(
// //     DualFieldControllers dual,
// //   ) {
// //     return (DualEntryControllers e) {
// //       final dualIndex = dualFields.indexOf(dual);
// //       final entryIndex = dual.entries.indexOf(e);
// //       final deleteKey = dual;
// //       final deleting = _dualEntryDelete[deleteKey] == entryIndex;

// //       return GestureDetector(
// //         onLongPress: () =>
// //             setState(() => _dualEntryDelete[deleteKey] = entryIndex),
// //         child: Stack(
// //           children: [
// //             Card(
// //               margin: const EdgeInsets.symmetric(vertical: 6),
// //               shape: RoundedRectangleBorder(
// //                 borderRadius: BorderRadius.circular(12),
// //               ),
// //               child: Padding(
// //                 padding: const EdgeInsets.all(8),
// //                 child: Column(
// //                   children: [
// //                     Row(
// //                       children: [
// //                         Expanded(
// //                           child: TextField(
// //                             controller: e.titleController,
// //                             decoration: _input('Title'),
// //                           ),
// //                         ),
// //                         IconButton(
// //                           icon: Icon(
// //                             Icons.bookmark,
// //                             color: e.remembered ? Colors.orange : Colors.grey,
// //                           ),
// //                           onPressed: () =>
// //                               setState(() => e.remembered = !e.remembered),
// //                         ),
// //                       ],
// //                     ),
// //                     const SizedBox(height: 6),
// //                     TextField(
// //                       controller: e.descriptionController,
// //                       decoration: _input('Description'),
// //                     ),
// //                     const SizedBox(height: 6),
// //                     Row(
// //                       children: [
// //                         Expanded(
// //                           child: TextField(
// //                             controller: e.amountPaidController,
// //                             keyboardType: TextInputType.number,
// //                             decoration: _input('Amount Paid'),
// //                             onChanged: (_) => setState(_recalculateTotals),
// //                           ),
// //                         ),
// //                         const SizedBox(width: 8),
// //                         Expanded(
// //                           child: TextField(
// //                             controller: e.balanceController,
// //                             keyboardType: TextInputType.number,
// //                             decoration: _input('Balance'),
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //             if (deleting)
// //               Positioned(
// //                 top: 4,
// //                 right: 4,
// //                 child: IconButton(
// //                   icon: const Icon(Icons.delete, color: Colors.red),
// //                   onPressed: () {
// //                     setState(() {
// //                       dual.entries.removeAt(entryIndex);
// //                       _dualEntryDelete[deleteKey] = null;
// //                     });
// //                     _recalculateTotals();
// //                   },
// //                 ),
// //               ),
// //           ],
// //         ),
// //       );
// //     };
// //   }
// // Widget _buildLabourCard(LabourFieldControllers lf) {
// //   final i = labourFields.indexOf(lf);

// //   return GestureDetector(
// //     onLongPress: () => setState(() => _labourDeleteIndex = i),
// //     child: Stack(
// //       children: [
// //         Card(
// //           elevation: 3,
// //           margin: const EdgeInsets.symmetric(vertical: 8),
// //           shape: RoundedRectangleBorder(
// //             borderRadius: BorderRadius.circular(16),
// //           ),
// //           child: Padding(
// //             padding: const EdgeInsets.all(12),
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 // --- Title row with arrow ---
// //                 Row(
// //                   children: [
// //                     Expanded(
// //                       child: TextField(
// //                         controller: lf.mainKeyController,
// //                         decoration: _input('Labour Key Title'),
// //                       ),
// //                     ),
// //                     IconButton(
// //                       icon: Icon(
// //                         _labourExpanded[i]
// //                             ? Icons.keyboard_arrow_up
// //                             : Icons.keyboard_arrow_down,
// //                       ),
// //                       onPressed: () => setState(() {
// //                         _labourExpanded[i] = !_labourExpanded[i];
// //                       }),
// //                     ),
// //                   ],
// //                 ),

// //                 // --- Collapsible content ---
// //                 if (_labourExpanded[i]) ...[
// //                   const SizedBox(height: 8),
// //                   ...lf.entries.map(_buildLabourEntry),
// //                   Align(
// //                     alignment: Alignment.centerRight,
// //                     child: TextButton.icon(
// //                       icon: const Icon(Icons.add_circle_outline),
// //                       label: const Text('Add Entry'),
// //                       onPressed: () => _addLabourEntry(lf),
// //                     ),
// //                   ),
// //                 ],
// //               ],
// //             ),
// //           ),
// //         ),

// //         // ---- red delete icon overlay ----
// //         if (_labourDeleteIndex == i)
// //           Positioned(
// //             top: 4,
// //             right: 4,
// //             child: IconButton(
// //               icon: const Icon(Icons.delete, color: Colors.red),
// //               onPressed: () {
// //                 setState(() {
// //                   labourFields.removeAt(i);
// //                   _labourExpanded.removeAt(i); // keep in sync
// //                   _labourDeleteIndex = null;
// //                 });
// //                 _recalculateTotals();
// //               },
// //             ),
// //           ),
// //       ],
// //     ),
// //   );
// // }
// //   Widget _buildLabourEntry(LabourEntryControllers e) => Card(
// //     // color: Colors.grey[50],
// //     margin: const EdgeInsets.symmetric(vertical: 6),
// //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// //     child: Padding(
// //       padding: const EdgeInsets.all(8),
// //       child: Row(
// //         children: [
// //           Expanded(
// //             child: TextField(
// //               controller: e.titleController,
// //               decoration: _input('Title'),
// //             ),
// //           ),
// //           const SizedBox(width: 8),
// //           Expanded(
// //             child: TextField(
// //               controller: e.amountPaidController,
// //               keyboardType: TextInputType.number,
// //               decoration: _input('Amount Paid'),
// //               onChanged: (_) => setState(_recalculateTotals), // ✅
// //             ),
// //           ),
// //           IconButton(
// //             icon: Icon(
// //               Icons.bookmark,
// //               color: e.remembered ? Colors.orange : Colors.grey,
// //             ),
// //             onPressed: () => setState(() => e.remembered = !e.remembered),
// //           ),
// //         ],
// //       ),
// //     ),
// //   );

// //   // ----- Your original functions like _addField, _submit, etc remain unchanged -----
// // }

// // // ---------- Helper Classes ----------
// // class DualEntryControllers {
// //   TextEditingController titleController = TextEditingController();
// //   TextEditingController descriptionController = TextEditingController();
// //   TextEditingController amountPaidController = TextEditingController();
// //   TextEditingController balanceController = TextEditingController();
// //   bool remembered = false;
// // }

// // class DualFieldControllers {
// //   TextEditingController mainKeyController = TextEditingController();
// //   List<DualEntryControllers> entries = [DualEntryControllers()];
// // }

// // class LabourEntryControllers {
// //   TextEditingController titleController = TextEditingController();
// //   TextEditingController amountPaidController = TextEditingController();
// //   bool remembered = false;
// // }

// // class LabourFieldControllers {
// //   TextEditingController mainKeyController = TextEditingController();
// //   List<LabourEntryControllers> entries = [LabourEntryControllers()];
// // }






























// /////////////////////////////////////////////////////////////////////////////////////////



















// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';

// import 'ProjectTable/project_detail_page.dart';

// class ProjectGridListPage extends StatefulWidget {
//   final String projectId;
//   final Map<String, dynamic> projectData;
//   final String uid;

//   const ProjectGridListPage({
//     Key? key,
//     required this.projectId,
//     required this.projectData,
//     required this.uid,
//   }) : super(key: key);

//   @override
//   State<ProjectGridListPage> createState() => _ProjectGridListPageState();
// }

// class _ProjectGridListPageState extends State<ProjectGridListPage> {
//   final selectedIdsNotifier = ValueNotifier<Set<String>>({});
//   final showCheckboxesNotifier = ValueNotifier(false);

//   final totalOwnerSumNotifier = ValueNotifier(0.0);
//   final totalPaidSumNotifier = ValueNotifier(0.0);
//   final totalBalanceNotifier = ValueNotifier(0.0);

//   void _updateTotals(List<QueryDocumentSnapshot> formDocs, Set<String> selectedIds) {
//     double totalPaid = 0, totalOwner = 0;
//     for (var doc in formDocs) {
//       final data = doc.data() as Map<String, dynamic>;
//       if (selectedIds.isEmpty || selectedIds.contains(doc.id)) {
//         totalPaid += (data["totalAmountPaid"] ?? 0).toDouble();
//         totalOwner += (data["ownerPaid"] ?? 0).toDouble();
//       }
//     }
//     totalOwnerSumNotifier.value = totalOwner;
//     totalPaidSumNotifier.value = totalPaid;
//     totalBalanceNotifier.value = totalOwner - totalPaid;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.projectData["title"] ?? "Project Detail"),
//         actions: [
//           ValueListenableBuilder<bool>(
//             valueListenable: showCheckboxesNotifier,
//             builder: (_, show, __) => InkWell(
//               onTap: () {
//                 showCheckboxesNotifier.value = !show;
//                 if (!showCheckboxesNotifier.value) selectedIdsNotifier.value = {};
//               },
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 12.0),
//                 child: Text(show ? "Cancel" : "Select", style: const TextStyle(fontSize: 18)),
//               ),
//             ),
//           ),
//           ValueListenableBuilder2<Set<String>, bool>(
//             first: selectedIdsNotifier,
//             second: showCheckboxesNotifier,
//             builder: (_, ids, show, __) =>
//                 show ? Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
//                   child: Text(" ${ids.length}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
//                 ) : const SizedBox.shrink(),
//           ),
//         ],
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection("users").doc(widget.uid)
//             .collection("projects").doc(widget.projectId)
//             .collection("formData")
//             .orderBy("createdAt", descending: true)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text("No form data found"));

//           final docs = snapshot.data!.docs;
//           _updateTotals(docs, selectedIdsNotifier.value);

//           return Column(
//             children: [
//               Expanded(
//                 child: SingleChildScrollView(
//                   scrollDirection: Axis.horizontal,
//                   child: ValueListenableBuilder2<Set<String>, bool>(
//                     first: selectedIdsNotifier,
//                     second: showCheckboxesNotifier,
//                     builder: (_, selectedIds, show, __) {
//                       return DataTable(
//                         columnSpacing: 40,
//                         columns: [
//                           if (show) const DataColumn(label: Text("")),
//                           const DataColumn(label: Text("Created At")),
//                           const DataColumn(label: Text("Client Name")),
//                           const DataColumn(label: Text("Trade Name")),
//                           const DataColumn(label: Text("Payment History")),
//                           const DataColumn(label: Text("Labour History")),
//                           const DataColumn(label: Text("Owner Paid")),
//                           const DataColumn(label: Text("Total Paid")),
//                           const DataColumn(label: Text("Total Balance")),
//                         ],
//                         rows: docs.map((doc) {
//                           final data = doc.data() as Map<String, dynamic>;
//                           final createdAt = (data["createdAt"] as Timestamp?)?.toDate();
//                           final date = createdAt != null ? DateFormat("MMM d, yyyy").format(createdAt) : "N/A";

//                           final client = (data["milestones"] as List?)?.isNotEmpty == true
//                               ? "amountPaid : ${data["milestones"][0]["amountPaid"] ?? 0}" : "";

//                           final trade = (data["fields"] as List?)?.isNotEmpty == true
//                               ? "value: ${data["fields"][0]["value"]}, amountPaid: ${data["fields"][0]["amountPaid"]}" : "";

//                           final paymentHistory = (data["dualFields"] as List?)
//                                   ?.expand((df) => (df["myValue"] as List).map((v) => "${v["title"]} (Paid: ${v["amountPaid"]}, Bal: ${v["balance"]})"))
//                                   .join("\n") ?? "";

//                           final labourHistory = (data["labourFields"] as List?)
//                                   ?.expand((lf) => (lf["myValue"] as List).map((v) => "${v["title"]} (Paid: ${v["amountPaid"]})"))
//                                   .join("\n") ?? "";

//                           final isChecked = selectedIds.contains(doc.id);

//                           return DataRow(cells: [
//                             if (show)
//                               DataCell(Checkbox(
//                                 value: isChecked,
//                                 onChanged: (val) {
//                                   final newSet = {...selectedIds};
//                                   val! ? newSet.add(doc.id) : newSet.remove(doc.id);
//                                   selectedIdsNotifier.value = newSet;
//                                   _updateTotals(docs, newSet);
//                                 },
//                               )),
//                             _cell(date, doc.id, data),
//                             _cell(client, doc.id, data),
//                             _cell(trade, doc.id, data),
//                             _cell(paymentHistory, doc.id, data),
//                             _cell(labourHistory, doc.id, data),
//                             _cell("${data["ownerPaid"] ?? 0}", doc.id, data),
//                             _cell("${data["totalAmountPaid"] ?? 0}", doc.id, data),
//                             _cell("${data["totalBalance"] ?? 0}", doc.id, data),
//                           ]);
//                         }).toList(),
//                       );
//                     },
//                   ),
//                 ),
//               ),
//               buildTotalCard(title: "Owner Paid", icon: Icons.account_balance_wallet, color: Colors.orange, cardColor: Colors.orange.shade50, notifier: totalOwnerSumNotifier),
//               buildTotalCard(title: "Total Paid", icon: Icons.attach_money, color: Colors.green, cardColor: Colors.green.shade50, notifier: totalPaidSumNotifier),
//               buildTotalCard(title: "Total Balance", icon: Icons.balance, color: Colors.purple, cardColor: Colors.purple.shade50, notifier: totalBalanceNotifier),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   /////////////////////////////////////////////////////////////////////////////////////

//     void _openDetail(String formId, Map<String, dynamic> formData) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => ProjectDetailPage(formId: formId, formData: formData),
//       ),
//     );
//   }

//   DataCell _cell(String text, String formId, Map<String, dynamic> formData) {
//     return DataCell(Text(text), onTap: () => _openDetail(formId, formData));
//   }
// }

// /////////////////////////////////////////////////////////////////////////////
//   Widget buildTotalCard({
//     required String title,
//     required IconData icon,
//     required Color color,
//     required Color cardColor,
//     required ValueNotifier<double> notifier,
//   }) {
//     return Card(
//       color: cardColor,
//       margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
//       child: ListTile(
//         leading: Icon(icon, color: color, size: 30),
//         title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
//         trailing: ValueListenableBuilder<double>(
//           valueListenable: notifier,
//           builder: (_, value, __) => Text(
//             value.toStringAsFixed(2),
//             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
//           ),
//         ),
//       ),
//     );
//   }

// //////////////////////////////////////////////////////////////////////////////

// class ValueListenableBuilder2<A, B> extends StatelessWidget {
//   final ValueNotifier<A> first;
//   final ValueNotifier<B> second;
//   final Widget Function(BuildContext, A, B, Widget?) builder;

//   const ValueListenableBuilder2({
//     Key? key,
//     required this.first,
//     required this.second,
//     required this.builder,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return ValueListenableBuilder<A>(
//       valueListenable: first,
//       builder: (context, a, _) => ValueListenableBuilder<B>(
//         valueListenable: second,
//         builder: (context, b, __) => builder(context, a, b, null),
//       ),
//     );
//   }
// }

// /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// ///
// ///
// ///