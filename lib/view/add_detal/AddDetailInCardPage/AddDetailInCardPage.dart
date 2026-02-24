import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';

import '../../../controller/MyprojectDetail_controller.dart';
import 'wdgets/AddDetail.dart';
import 'wdgets/AddField.dart';
import 'wdgets/AddTask.dart.dart';
import 'wdgets/AddTaskSet.dart'; // Add in pubspec

class AddDetailInCardPage extends StatefulWidget {
  final String subprojectId;
  final String projectId;
  const AddDetailInCardPage({
    super.key,
    required this.subprojectId,
    required this.projectId,
  });

  @override
  State<AddDetailInCardPage> createState() => _AddDetailInCardPageState();
}

class _AddDetailInCardPageState extends State<AddDetailInCardPage> {
  final uid = FirebaseAuth.instance.currentUser!.uid;

  DateTime _selectedDate = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = DateTime(picked.year, picked.month, picked.day);
      });
    }
  }

  final TextEditingController totalAmountPaidController =
      TextEditingController();

  int? _simpleDeleteIndex;
  int? _milestoneDeleteIndex;
  int? _labourDeleteIndex; // for main labour card
  int? _dualDeleteIndex; // for main dual card

  // for deleting a whole Dual card

  //dropdown hide and show
  final List<bool> _milestoneExpanded = []; // NEW
  final List<bool> _simpleExpanded = [];
  final List<bool> _dualExpanded = []; // NEW
  final List<bool> _labourExpanded = []; // NEW

  Map<DualFieldControllers, int?> _dualEntryDelete =
      {}; // delete specific entry

  void _recalculateTotals() {
    double totalPaid = 0;

    // Simple fields
    for (final c in amountPaidControllers) {
      totalPaid += double.tryParse(c.text.trim()) ?? 0;
    }

    // Milestones
    for (final c in milestoneAmountControllers) {
      totalPaid += double.tryParse(c.text.trim()) ?? 0;
    }

    // Dual Fields
    for (final dual in dualFields) {
      for (final e in dual.entries) {
        totalPaid += double.tryParse(e.amountPaidController.text.trim()) ?? 0;
      }
    }

    // Labour Fields
    for (final lf in labourFields) {
      for (final e in lf.entries) {
        totalPaid += double.tryParse(e.amountPaidController.text.trim()) ?? 0;
      }
    }

    // Always update Total Amount Paid
    totalAmountPaidController.text = totalPaid.toStringAsFixed(2);
  }

  bool _showAddMenu = false; // ✅ NEW - Controls menu visibility
  // ---------------- Simple fields ----------------
  final List<TextEditingController> keyControllers = [];
  final List<TextEditingController> valueControllers = [];
  // --- Add new list of controllers ---
  final List<TextEditingController> amountPaidControllers = []; // ✅ NEW

  // ---------------- Milestones fields (NEW) ----------------
  final List<TextEditingController> milestoneTitleControllers = [];
  final List<TextEditingController> milestoneAmountControllers = [];

  // ---------------- Dual fields ----------------
  final List<DualFieldControllers> dualFields = [];

  // ---------------- Labour fields ----------------
  final List<LabourFieldControllers> labourFields = [];

  @override
  void initState() {
    super.initState();
    _loadLatestForm();
  }

  Future<void> _loadLatestForm() async {
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('projects')
        .doc(widget.projectId)
        .collection('subprojects')
        .doc(widget.subprojectId)
        .collection('formData')
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    if (snap.docs.isEmpty) return;
    final data = snap.docs.first.data();

    // -------- Simple --------
    for (var f in (data['fields'] ?? [])) {
      keyControllers.add(TextEditingController(text: f['keyTitle'] ?? ''));
      valueControllers.add(TextEditingController());
      amountPaidControllers.add(TextEditingController()); // keep blank if null
      _simpleExpanded.add(true); // start expanded
    }

    // -------- Milestones (NEW) --------
    for (var m in (data['milestones'] ?? [])) {
      milestoneTitleControllers.add(
        TextEditingController(text: m['keyTitle'] ?? ''),
      );
      milestoneAmountControllers.add(TextEditingController());
      _milestoneExpanded.add(true); // start expanded
    }

    // -------- Dual --------
    for (var df in (data['dualFields'] ?? [])) {
      final dual = DualFieldControllers();
      dual.mainKeyController.text = df['keyTitle'] ?? '';

      final remembered = (df['myValue'] as List? ?? [])
          .where((e) => e['remembered'] == true)
          .toList();

      if (remembered.isEmpty) {
        dual.entries = [DualEntryControllers()]; // default one empty entry
      } else {
        dual.entries = remembered.map((e) {
          final entry = DualEntryControllers();
          entry.titleController.text = e['title'] ?? '';
          entry.remembered = true;
          return entry;
        }).toList();
      }

      dualFields.add(dual);
      _dualExpanded.add(true); // start expanded
    }

    // -------- Labour --------
    for (var lf in (data['labourFields'] ?? [])) {
      final labour = LabourFieldControllers();
      labour.mainKeyController.text = lf['keyTitle'] ?? '';

      final remembered = (lf['myValue'] as List? ?? [])
          .where((e) => e['remembered'] == true)
          .toList();

      if (remembered.isEmpty) {
        labour.entries = [LabourEntryControllers()]; // default one empty entry
      } else {
        labour.entries = remembered.map((e) {
          final entry = LabourEntryControllers();
          entry.titleController.text = e['title'] ?? '';
          entry.remembered = true;
          return entry;
        }).toList();
      }

      labourFields.add(labour);
      _labourExpanded.add(true); // start expanded
    }

    setState(() {
      _recalculateTotals();
    });
  }

  // ---------- Add buttons ----------
  void _addDetail() {
    keyControllers.add(TextEditingController());
    valueControllers.add(TextEditingController());
    amountPaidControllers.add(TextEditingController()); // <-- FIX
    _simpleExpanded.add(true); // start expanded

    setState(() {});
  }

  void _addField() {
    milestoneTitleControllers.add(TextEditingController());
    milestoneAmountControllers.add(TextEditingController());
    _milestoneExpanded.add(true); // start expanded
    setState(() {});
  }

  void _addTaskSet() {
    dualFields.add(DualFieldControllers());
    _dualExpanded.add(true); // start expanded
    setState(() {});
  }

  void _addDualEntry(DualFieldControllers dual) {
    setState(() => dual.entries.add(DualEntryControllers()));
  }

  void _addTask() {
    labourFields.add(LabourFieldControllers());
    _labourExpanded.add(true); // start expanded
    setState(() {});
  }

  void _addLabourEntry(LabourFieldControllers labour) {
    setState(() => labour.entries.add(LabourEntryControllers()));
  }

  // ---------- Submit ----------
  Future<void> _submit() async {
    // Check if data already exists for this date
    final startOfDay = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final existingData = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('projects')
        .doc(widget.projectId)
        .collection('subprojects')
        .doc(widget.subprojectId)
        .collection('formData')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay))
        .limit(1)
        .get();

    if (existingData.docs.isNotEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Data already submitted for ${DateFormat('dd/MM/yyyy').format(_selectedDate)}. One entry per date allowed.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Simple fields
    final simpleFields = <Map<String, dynamic>>[];
    for (int i = 0; i < keyControllers.length; i++) {
      final k = keyControllers[i].text.trim();
      final v = valueControllers[i].text.trim();
      final amt =
          int.tryParse(amountPaidControllers[i].text.trim()) ?? 0; // ✅ NEW

      if (k.isNotEmpty)
        simpleFields.add({
          'keyTitle': k, 'value': v, 'amountPaid': amt, // ✅ NEW
        });
    }

    // Milestones (NEW)
    final milestones = <Map<String, dynamic>>[];
    for (int i = 0; i < milestoneTitleControllers.length; i++) {
      final t = milestoneTitleControllers[i].text.trim();
      final amt = int.tryParse(milestoneAmountControllers[i].text.trim()) ?? 0;
      if (t.isNotEmpty || amt != 0) {
        milestones.add({'keyTitle': t, 'amountPaid': amt});
      }
    }

    // Dual fields
    final dualData = <Map<String, dynamic>>[];
    for (var dual in dualFields) {
      final key = dual.mainKeyController.text.trim();
      if (key.isEmpty) continue;
      final entries = <Map<String, dynamic>>[];
      for (var e in dual.entries) {
        final t = e.titleController.text.trim();
        final d = e.descriptionController.text.trim();
        final paid = int.tryParse(e.amountPaidController.text.trim()) ?? 0;
        final bal = int.tryParse(e.balanceController.text.trim()) ?? 0;
        if (t.isNotEmpty ||
            d.isNotEmpty ||
            paid != 0 ||
            bal != 0 ||
            e.remembered) {
          entries.add({
            'title': t,
            'description': d,
            'amountPaid': paid,
            'balance': bal,
            'remembered': e.remembered,
          });
        }
      }
      // Always save the category if the key is not empty
      dualData.add({'keyTitle': key, 'myValue': entries});
    }

    // Labour fields
    final labourData = <Map<String, dynamic>>[];
    for (var lf in labourFields) {
      final key = lf.mainKeyController.text.trim();
      if (key.isEmpty) continue;
      final entries = <Map<String, dynamic>>[];
      for (var e in lf.entries) {
        final t = e.titleController.text.trim();
        final paid = int.tryParse(e.amountPaidController.text.trim()) ?? 0;
        if (t.isNotEmpty || paid != 0 || e.remembered) {
          entries.add({
            'title': t,
            'amountPaid': paid,
            'remembered': e.remembered,
          });
        }
      }
      // Always save the category if the key is not empty
      labourData.add({'keyTitle': key, 'myValue': entries});
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('projects')
        .doc(widget.projectId)
        .collection('subprojects')
        .doc(widget.subprojectId)
        .collection('formData')
        .add({
          'fields': simpleFields,
          'milestones': milestones, // ✅ NEW
          'dualFields': dualData,
          'labourFields': labourData,
          'totalAmountPaid':
              double.tryParse(totalAmountPaidController.text.trim()) ?? 0,
          'date': Timestamp.fromDate(_selectedDate),
          'createdAt': FieldValue.serverTimestamp(),
        });

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Form Data Saved')));
    Navigator.pop(context);
  }

  bool _dialOpen = false;

  // --- Your controller lists here (unchanged) ---

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Details'),

        // actions: [
        //    IconButton(
        //     icon: const Icon(Icons.looks_4),
        //     onPressed: ()  {
        //       Navigator.push(
        //         context,
        //         MaterialPageRoute(
        //           builder: (_) =>  MygetDetailPage(projectId:  p.id,),
        //         ),
        //       );

        //     },
        //   ),
        // ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            // gradient: LinearGradient(
            //   colors: [Color(0xff6a11cb), Color(0xff2575fc)],
            //   begin: Alignment.topLeft,
            //   end: Alignment.bottomRight,
            // ),
          ),
        ),
        elevation: 4,
      ),

      // ✅ Floating Speed Dial instead of add-menu column
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        openCloseDial: ValueNotifier(_dialOpen),
        // backgroundColor: const Color(0xff6a11cb),
        // overlayColor: Colors.black,
        overlayOpacity: 0.4,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.post_add, color: Colors.white),
            backgroundColor: Colors.orange,
            label: 'Add Task Set',
            onTap: _addTaskSet,
          ),
          SpeedDialChild(
            child: const Icon(Icons.list_alt, color: Colors.white),
            backgroundColor: Colors.teal,
            label: 'Add Task',
            onTap: _addTask,
          ),
          SpeedDialChild(
            child: const Icon(Icons.playlist_add, color: Colors.white),
            backgroundColor: Colors.indigo,
            label: 'Add Detail',
            onTap: _addDetail,
          ),
          SpeedDialChild(
            child: const Icon(Icons.notes, color: Colors.white),
            backgroundColor: Colors.deepPurple,
            label: 'Add Field',
            onTap: _addField,
          ),
        ],
      ),

      body: Container(
        decoration: const BoxDecoration(
          // gradient: LinearGradient(
          //   colors: [Colors.white, Color(0xffeef1f5)],
          //   begin: Alignment.topCenter,
          //   end: Alignment.bottomCenter,
          // ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: ListView(
            children: [
              const SizedBox(height: 8),

              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  title: Text(
                    DateFormat('dd MMMM yyyy').format(_selectedDate),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: const Icon(Icons.calendar_month),
                  onTap: _pickDate,
                ),
              ),
              const SizedBox(height: 16),

              _buildSectionHeader('Add Field'),
              ...List.generate(milestoneTitleControllers.length, (i) {
                return MilestoneRow(
                  index: i,
                  titleController: milestoneTitleControllers[i],
                  amountController: milestoneAmountControllers[i],
                  isExpanded: _milestoneExpanded[i],
                  isDeleting: _milestoneDeleteIndex == i,
                  onToggleExpand: () {
                    setState(
                      () => _milestoneExpanded[i] = !_milestoneExpanded[i],
                    );
                  },
                  onAmountChanged: (_) => setState(_recalculateTotals),
                  onDelete: () {
                    setState(() {
                      milestoneTitleControllers.removeAt(i);
                      milestoneAmountControllers.removeAt(i);
                      _milestoneExpanded.removeAt(i);
                      _milestoneDeleteIndex = null;
                    });
                    _recalculateTotals();
                  },
                  inputDecoration: _input, // pass your existing function
                  onLongPress: () {
                    setState(() {
                      _milestoneDeleteIndex = i; // show delete mode
                    });
                  },
                  onCancelDelete: () {
                    setState(() {
                      _milestoneDeleteIndex = null; // hide delete mode
                    });
                  },
                );
              }),

              _buildSectionHeader('Add Detail'),
              ...List.generate(keyControllers.length, (i) {
                return SimpleRow(
                  index: i,
                  keyController: keyControllers[i],
                  valueController: valueControllers[i],
                  amountPaidController: amountPaidControllers[i],
                  isExpanded: _simpleExpanded[i],
                  isDeleting: _simpleDeleteIndex == i,
                  onToggleExpand: () {
                    setState(() => _simpleExpanded[i] = !_simpleExpanded[i]);
                  },
                  onDelete: () {
                    setState(() {
                      keyControllers.removeAt(i);
                      valueControllers.removeAt(i);
                      amountPaidControllers.removeAt(i);
                      _simpleExpanded.removeAt(i);
                      _simpleDeleteIndex = null;
                    });
                    _recalculateTotals();
                  },
                  onRecalculateTotals: () => setState(_recalculateTotals),
                  input: _input,
                  onLongPress: () {
                    setState(() {
                      _simpleDeleteIndex = i; // show delete mode
                    });
                  },
                  onCancelDelete: () {
                    setState(() {
                      _simpleDeleteIndex = null; // hide delete mode
                    });
                  },
                );
              }),

              _buildSectionHeader('Add Task'),
              ...labourFields.asMap().entries.map((entry) {
                final i = entry.key;
                final lf = entry.value;
                return LabourCard(
                  lf: lf,
                  index: i,
                  isExpanded: _labourExpanded[i],
                  isDeleting: _labourDeleteIndex == i,
                  onToggleExpand: () {
                    setState(() => _labourExpanded[i] = !_labourExpanded[i]);
                  },
                  onDelete: () {
                    setState(() {
                      labourFields.removeAt(i);
                      _labourExpanded.removeAt(i);
                      _labourDeleteIndex = null;
                    });
                    _recalculateTotals();
                  },
                  onAddEntry: () =>
                      setState(() => lf.entries.add(LabourEntryControllers())),
                  input: _input,
                  onLongPress: () {
                    setState(() {
                      _labourDeleteIndex = i; // show delete mode
                    });
                  },
                  onCancelDelete: () {
                    setState(() {
                      _labourDeleteIndex = null; // hide delete mode
                    });
                  },
                  recalculateTotals: _recalculateTotals,
                );
              }),

              _buildSectionHeader('Add Task Set'),
              ...dualFields.asMap().entries.map((entry) {
                final i = entry.key;
                final dual = entry.value;
                return DualCard(
                  dual: dual,
                  index: i,
                  isExpanded: _dualExpanded[i],
                  isDeleting: _dualDeleteIndex == i,
                  deletingEntryIndex: _dualEntryDelete[dual],
                  onToggleExpand: () {
                    setState(() => _dualExpanded[i] = !_dualExpanded[i]);
                  },
                  onDelete: () {
                    setState(() {
                      dualFields.removeAt(i);
                      _dualExpanded.removeAt(i);
                      _dualDeleteIndex = null;
                    });
                    _recalculateTotals();
                  },
                  onAddEntry: () =>
                      setState(() => dual.entries.add(DualEntryControllers())),
                  onDeleteEntry: (ei) {
                    setState(() {
                      dual.entries.removeAt(ei);
                      _dualEntryDelete[dual] = null;
                    });
                    _recalculateTotals();
                  },
                  recalculateTotals: _recalculateTotals,
                  input: _input,
                  onLongPress: () {
                    setState(() {
                      _dualDeleteIndex = i; // show delete mode
                    });
                  },
                  onCancelDelete: () {
                    setState(() {
                      _dualDeleteIndex = null; // hide delete mode
                    });
                  },
                  onChanged: () => setState(() {}),
                );
              }),

              const SizedBox(height: 16),
              const SizedBox(height: 20),
              _buildSectionHeader('Summary'),

              TextField(
                controller: totalAmountPaidController,
                readOnly: true,
                decoration: _input('Total Amount Paid'),
              ),
              const SizedBox(height: 8),

              const SizedBox(height: 20),

              ElevatedButton.icon(
                icon: const Icon(Icons.save_alt),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: theme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _submit,

                label: const Text(
                  'Submit All',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildSectionHeader(String title) =>
    Padding(padding: const EdgeInsets.symmetric(vertical: 12));

InputDecoration _input(String label) => InputDecoration(
  labelText: label,
  filled: true,
  // fillColor: Colors.white,
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide.none,
  ),
  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
);
