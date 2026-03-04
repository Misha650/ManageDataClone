import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:manage_data/controller/project_cache_controller.dart';
import '../../../../utils/number_to_words.dart';
import '../../../add_detal/AddDetailInCardPage/AddDetailInCardPage.dart';
import 'package:manage_data/view/detail_info_page/detail_info.dart';

//misha
class ShowTotalProjectTablePage extends StatefulWidget {
  final String projectId;
  final String projectName;

  const ShowTotalProjectTablePage({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  @override
  State<ShowTotalProjectTablePage> createState() =>
      _ShowTotalProjectTablePageState();
}

class _ShowTotalProjectTablePageState extends State<ShowTotalProjectTablePage> {
  final String uid = FirebaseAuth.instance.currentUser!.uid;
  bool isLoading = true;
  List<Map<String, dynamic>> allFormData = [];
  List<Map<String, dynamic>> filteredData = [];
  Set<String> selectedDocIds = {};
  bool isSelectionMode = false;
  bool isSearching = false;
  bool isSummaryVisible = true;
  String searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  final ProjectCacheController _cache = ProjectCacheController();

  @override
  void initState() {
    super.initState();
    // Load from cache first
    final cachedData = _cache.getData(widget.projectId);
    if (cachedData != null) {
      allFormData = cachedData;
      filteredData = cachedData;
      isLoading = false;
    }
    _fetchTotalData();
  }

  Future<void> _fetchTotalData() async {
    // Only show loading if we don't have cached data
    if (allFormData.isEmpty) {
      setState(() => isLoading = true);
    }

    try {
      final subprojectsSnap = await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("projects")
          .doc(widget.projectId)
          .collection("subprojects")
          .get();

      Map<String, Map<String, dynamic>> groupedData = {};
      for (var subDoc in subprojectsSnap.docs) {
        final subprojectName = subDoc.data()['title'] ?? "Untitled";
        final formDataSnap = await subDoc.reference
            .collection("formData")
            .orderBy('date', descending: true)
            .get();
        for (var formDoc in formDataSnap.docs) {
          final data = formDoc.data();
          final date = (data['date'] as Timestamp?)?.toDate();
          final dateStr = date != null
              ? DateFormat('dd/MM/yy').format(date)
              : "N/A";

          final entryData = {
            ...data,
            'subprojectName': subprojectName,
            'subprojectId': subDoc.id,
            'id': formDoc.id,
          };

          if (!groupedData.containsKey(dateStr)) {
            groupedData[dateStr] = {
              'id': dateStr,
              'date': data['date'],
              'totalAmountPaid': (data['totalAmountPaid'] as num? ?? 0)
                  .toDouble(),
              'docs': [entryData],
            };
          } else {
            final entry = groupedData[dateStr]!;
            entry['totalAmountPaid'] += (data['totalAmountPaid'] as num? ?? 0)
                .toDouble();
            (entry['docs'] as List).add(entryData);
          }
        }
      }

      // --- Fetch Owner Details ---
      final ownerSnap = await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("projects")
          .doc(widget.projectId)
          .collection("addOwnerDetail")
          .get();

      for (var ownerDoc in ownerSnap.docs) {
        final data = ownerDoc.data();
        final date = (data['date'] as Timestamp?)?.toDate();
        final dateStr = date != null
            ? DateFormat('dd/MM/yy').format(date)
            : "N/A";
        final amount = (data['amount'] as num? ?? 0).toDouble();
        final description = data['description'] ?? "";

        // Create a structure compatible with the existing rendering logic
        final ownerEntry = {
          ...data,
          'subprojectName': 'Owner',
          'id': ownerDoc.id,
          'totalAmountPaid': amount,
          'fields': [
            {
              'keyTitle': 'Owner Details',
              'value': description,
              'amountPaid': amount,
            },
          ],
        };

        if (!groupedData.containsKey(dateStr)) {
          groupedData[dateStr] = {
            'id': dateStr,
            'date': data['date'],
            'totalAmountPaid': amount,
            'docs': [ownerEntry],
          };
        } else {
          final entry = groupedData[dateStr]!;
          entry['totalAmountPaid'] += amount;
          (entry['docs'] as List).add(ownerEntry);
        }
      }

      final List<Map<String, dynamic>> finalData = groupedData.values.toList();
      finalData.sort((a, b) {
        final dateA = (a['date'] as Timestamp?)?.toDate() ?? DateTime(0);
        final dateB = (b['date'] as Timestamp?)?.toDate() ?? DateTime(0);
        return dateB.compareTo(dateA);
      });

      // Update cache
      _cache.setData(widget.projectId, finalData);

      if (mounted) {
        setState(() {
          allFormData = finalData;
          filteredData = finalData;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error fetching data: $e")));
      }
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _navigateToDetail(Map<String, dynamic> data) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => DetailInfoPage(data: data)));
  }

  Future<void> _confirmDeleteGroup(List docs, String dateStr) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: Text(
          "Are you sure you want to delete all ${docs.length} records for $dateStr?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete All"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        for (var doc in docs) {
          final docId = doc['id'];
          final subName = doc['subprojectName'];
          final subId = doc['subprojectId'];

          if (subName == 'Owner') {
            await FirebaseFirestore.instance
                .collection("users")
                .doc(uid)
                .collection("projects")
                .doc(widget.projectId)
                .collection("addOwnerDetail")
                .doc(docId)
                .delete();
          } else {
            await FirebaseFirestore.instance
                .collection("users")
                .doc(uid)
                .collection("projects")
                .doc(widget.projectId)
                .collection("subprojects")
                .doc(subId)
                .collection("formData")
                .doc(docId)
                .delete();
          }
        }
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Records deleted")));
        }
        _fetchTotalData(); // Refresh list
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Error deleting: $e")));
        }
      }
    }
  }

  Future<void> _showUpdateDocsDialog(List docs) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Update Records"),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: docs.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final doc = docs[index];
                final subName = doc['subprojectName'];
                final amount = (doc['totalAmountPaid'] ?? doc['amount'] ?? 0);

                return ListTile(
                  title: Text(subName),
                  subtitle: Text("Amount: $amount"),
                  trailing: const Icon(Icons.edit, color: Colors.blue),
                  onTap: () async {
                    Navigator.pop(context);
                    if (subName == 'Owner') {
                      _showOwnerUpdateDialog(doc['id'], doc);
                    } else {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddDetailInCardPage(
                            projectId: widget.projectId,
                            subprojectId: doc['subprojectId'],
                            docId: doc['id'],
                          ),
                        ),
                      );
                      _fetchTotalData();
                    }
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showOwnerUpdateDialog(
    String docId,
    Map<String, dynamic> data,
  ) async {
    final amountController = TextEditingController(
      text: (data['amount'] ?? data['totalAmountPaid'] ?? 0).toString(),
    );
    final descriptionController = TextEditingController(
      text:
          data['description'] ??
          (data['fields'] != null ? data['fields'][0]['value'] : ""),
    );
    DateTime selectedDate = (data['date'] as Timestamp).toDate();

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Update Owner Detail"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: Text(
                        "Date: ${DateFormat('dd/MM/yyyy').format(selectedDate)}",
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (picked != null) {
                          setDialogState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                    ),
                    TextField(
                      controller: amountController,
                      decoration: const InputDecoration(labelText: "Amount"),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: "Description",
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (amountController.text.isEmpty) return;
                    try {
                      await FirebaseFirestore.instance
                          .collection("users")
                          .doc(uid)
                          .collection("projects")
                          .doc(widget.projectId)
                          .collection("addOwnerDetail")
                          .doc(docId)
                          .update({
                            'amount':
                                double.tryParse(amountController.text) ?? 0,
                            'description': descriptionController.text,
                            'date': Timestamp.fromDate(selectedDate),
                          });
                      if (context.mounted) Navigator.pop(context);
                      _fetchTotalData();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Record updated")),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Update failed: $e")),
                        );
                      }
                    }
                  },
                  child: const Text("Update"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _filterData(String query) {
    setState(() {
      searchQuery = query;
      if (query.trim().isEmpty) {
        filteredData = allFormData;
      } else {
        final q = query.trim().toLowerCase();
        filteredData = allFormData.where((groupedEntry) {
          final dateStr = (groupedEntry['id'] ?? "").toString().toLowerCase();
          final totalPaid = (groupedEntry['totalAmountPaid'] ?? 0)
              .toString()
              .toLowerCase();

          if (dateStr.contains(q) || totalPaid.contains(q)) return true;

          final docs = groupedEntry['docs'] as List? ?? [];
          for (var data in docs) {
            // Check subproject name
            final subName = (data['subprojectName'] ?? "")
                .toString()
                .toLowerCase();
            if (subName.contains(q)) return true;

            // Check total amount paid of this specific doc
            final docTotal = (data['totalAmountPaid'] ?? 0)
                .toString()
                .toLowerCase();
            if (docTotal.contains(q)) return true;

            // Check sections
            for (var section in [
              'fields',
              'milestones',
              'dualFields',
              'labourFields',
            ]) {
              final list = data[section] as List? ?? [];
              for (var item in list) {
                if (item is Map) {
                  // Helper to check all values in a map
                  bool checkMap(Map m) {
                    for (var key in [
                      'keyTitle',
                      'value',
                      'amountPaid',
                      'balance',
                      'description',
                      'title',
                    ]) {
                      if (m.containsKey(key)) {
                        final val = m[key].toString().toLowerCase();
                        if (val.contains(q)) return true;
                      }
                    }
                    return false;
                  }

                  if (checkMap(item)) return true;

                  // Check nested myValue if present
                  if (item.containsKey('myValue') && item['myValue'] is List) {
                    for (var subItem in (item['myValue'] as List)) {
                      if (subItem is Map && checkMap(subItem)) return true;
                    }
                  }
                }
              }
            }
          }
          return false;
        }).toList();
      }
    });
  }

  bool _shouldIncludeColumn(Map item, String subName, String q) {
    if (q.isEmpty) return true;

    // Check Subproject Name
    if (subName.toLowerCase().contains(q)) return true;

    // Check KeyTitle
    if ((item['keyTitle']?.toString().toLowerCase() ?? "").contains(q))
      return true;

    // Helper to check map values
    bool checkMap(Map m) {
      for (var key in [
        'value',
        'amountPaid',
        'balance',
        'description',
        'title',
      ]) {
        if (m.containsKey(key)) {
          final val = m[key].toString().toLowerCase();
          if (val.contains(q)) return true;
        }
      }
      return false;
    }

    if (checkMap(item)) return true;

    // Check nested myValue if present
    if (item.containsKey('myValue') && item['myValue'] is List) {
      for (var subItem in (item['myValue'] as List)) {
        if (subItem is Map && checkMap(subItem)) return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Collect all unique (Subproject, KeyTitle) combinations
    final Set<String> allCategoryKeys = {};
    final q = searchQuery.trim().toLowerCase();

    for (var groupedEntry in filteredData) {
      final docs = groupedEntry['docs'] as List? ?? [];
      for (var data in docs) {
        final subName = data['subprojectName'] ?? "Untitled";
        for (var section in [
          'fields',
          'milestones',
          'dualFields',
          'labourFields',
        ]) {
          final list = data[section] as List? ?? [];
          for (var item in list) {
            if (item is Map && item.containsKey('keyTitle')) {
              if (_shouldIncludeColumn(item, subName, q)) {
                allCategoryKeys.add("$subName|${item['keyTitle']}");
              }
            }
          }
        }
      }
    }

    final List<String> sortedPairs = allCategoryKeys.toList()
      ..sort((a, b) {
        final splitA = a.split("|");
        final splitB = b.split("|");
        if (splitA[0] != splitB[0]) return splitA[0].compareTo(splitB[0]);
        return splitA[1].compareTo(splitB[1]);
      });

    double displayTotal = 0;
    double ownerTotal = 0;
    final entriesToSum = selectedDocIds.isNotEmpty
        ? allFormData.where((e) => selectedDocIds.contains(e['id']))
        : filteredData;

    for (var groupedEntry in entriesToSum) {
      final docs = groupedEntry['docs'] as List? ?? [];
      for (var doc in docs) {
        final amount = (doc['totalAmountPaid'] as num? ?? 0).toDouble();
        if (doc['subprojectName'] != 'Owner') {
          displayTotal += amount;
        } else {
          ownerTotal += amount;
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        leading: isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    isSelectionMode = false;
                    selectedDocIds.clear();
                  });
                },
              )
            : null,
        title: isSearching
            ? TextField(
                key: const ValueKey('search_text_field'),
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.black),
                cursorColor: Colors.black,
                decoration: const InputDecoration(
                  hintText: "Search...",
                  hintStyle: TextStyle(color: Colors.black54),
                  border: InputBorder.none,
                ),
                onChanged: _filterData,
              )
            : Text(
                isSelectionMode
                    ? "${selectedDocIds.length} Selected"
                    : "${widget.projectName} Total Data",
              ),
        actions: [
          if (isSelectionMode)
            IconButton(
              icon: const Icon(Icons.select_all_rounded),
              onPressed: () {
                setState(() {
                  if (selectedDocIds.length == filteredData.length) {
                    selectedDocIds.clear();
                  } else {
                    selectedDocIds.addAll(
                      filteredData.map((e) => e['id'] as String),
                    );
                  }
                });
              },
            ),
          if (!isSelectionMode)
            IconButton(
              icon: Icon(isSearching ? Icons.close : Icons.search),
              onPressed: () {
                setState(() {
                  isSearching = !isSearching;
                  if (!isSearching) {
                    _filterData("");
                    _searchController.clear();
                  }
                });
              },
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : filteredData.isEmpty
          ? const Center(child: Text("No data found"))
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Table(
                          defaultVerticalAlignment:
                              TableCellVerticalAlignment.middle,
                          columnWidths: {
                            0: const IntrinsicColumnWidth(), // Index
                            1: const FixedColumnWidth(100), // Date
                            for (int i = 0; i < sortedPairs.length; i++)
                              i + 2: const FixedColumnWidth(150),
                            sortedPairs.length + 2: const FixedColumnWidth(
                              100,
                            ), // Total Paid
                            sortedPairs.length + 3: const FixedColumnWidth(
                              120,
                            ), // Actions
                          },
                          children: [
                            // --- Header Row 1: Categories (Yellow) ---
                            TableRow(
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withOpacity(
                                  0.1,
                                ),
                              ),
                              children: [
                                _buildHeaderCell(""),
                                _buildHeaderCell(""),
                                ...sortedPairs.map((pair) {
                                  final parts = pair.split("|");
                                  return _buildHeaderCell(parts[0]);
                                }),
                                _buildHeaderCell("Total Paid"),
                                _buildHeaderCell("Actions"),
                              ],
                            ),
                            // --- Header Row 2: KeyTitles (Pink) ---
                            TableRow(
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondary.withOpacity(
                                  0.1,
                                ),
                              ),
                              children: [
                                _buildHeaderCell(""),
                                _buildHeaderCell("Date"),
                                ...sortedPairs.map((pair) {
                                  final parts = pair.split("|");
                                  return _buildHeaderCell(parts[1]);
                                }),
                                _buildHeaderCell(""),
                                _buildHeaderCell(""),
                              ],
                            ),
                            // --- Data Rows ---
                            ...List.generate(filteredData.length, (index) {
                              final groupedEntry = filteredData[index];
                              final date = (groupedEntry['date'] as Timestamp?)
                                  ?.toDate();
                              final dateStr = date != null
                                  ? DateFormat('dd/MM/yy').format(date)
                                  : "N/A";
                              final isSelected = selectedDocIds.contains(
                                groupedEntry['id'],
                              );
                              final docs = groupedEntry['docs'] as List? ?? [];

                              final onRowTap = () {
                                if (isSelectionMode) {
                                  setState(() {
                                    if (isSelected) {
                                      selectedDocIds.remove(groupedEntry['id']);
                                    } else {
                                      selectedDocIds.add(groupedEntry['id']);
                                    }
                                    if (selectedDocIds.isEmpty) {
                                      isSelectionMode = false;
                                    }
                                  });
                                } else if (docs.isNotEmpty) {
                                  // Aggregate data into source groups for hierarchical display
                                  double totalPaidAmount = 0;
                                  double totalOwnerAmount = 0;

                                  List<Map<String, dynamic>> sourceGroups = [];
                                  Set<String> subNames = {};
                                  List<String> combinedDescriptions = [];
                                  List<String> ownerDescriptions = [];

                                  for (var doc in docs) {
                                    final subName =
                                        doc['subprojectName'] ?? "Untitled";
                                    subNames.add(subName);

                                    final amt =
                                        (doc['totalAmountPaid'] as num? ?? 0)
                                            .toDouble();
                                    if (subName == 'Owner') {
                                      totalOwnerAmount += amt;
                                      final ownerDesc =
                                          doc['description'] ?? "";
                                      if (ownerDesc.toString().isNotEmpty) {
                                        ownerDescriptions.add(ownerDesc);
                                      }
                                    } else {
                                      totalPaidAmount += amt;
                                    }

                                    final groupDescription =
                                        doc['description'] ?? "";
                                    if (groupDescription
                                        .toString()
                                        .isNotEmpty) {
                                      combinedDescriptions.add(
                                        "$subName: $groupDescription",
                                      );
                                    }

                                    sourceGroups.add({
                                      'sourceName': subName,
                                      'description': groupDescription,
                                      'fields': doc['fields'] as List? ?? [],
                                      'milestones':
                                          doc['milestones'] as List? ?? [],
                                      'dualFields':
                                          doc['dualFields'] as List? ?? [],
                                      'labourFields':
                                          doc['labourFields'] as List? ?? [],
                                    });
                                  }

                                  // Sort sourceGroups so 'Owner' is always first
                                  sourceGroups.sort((a, b) {
                                    if (a['sourceName'] == 'Owner') return -1;
                                    if (b['sourceName'] == 'Owner') return 1;
                                    return 0;
                                  });

                                  _navigateToDetail({
                                    'date': groupedEntry['date'],
                                    'totalAmountPaid':
                                        totalPaidAmount + totalOwnerAmount,
                                    'totalOwnerAmount': totalOwnerAmount,
                                    'totalOwnerDescription': ownerDescriptions
                                        .join(", "),
                                    'totalSubprojectAmount': totalPaidAmount,
                                    'subprojectName': subNames.join(", "),
                                    'description': combinedDescriptions.join(
                                      "\n",
                                    ),
                                    'sourceGroups': sourceGroups,
                                    // Keep flat fields for summary if needed, or rely on groups
                                    'fields': [
                                      if (totalOwnerAmount > 0)
                                        {
                                          'keyTitle': 'Summary (Owner)',
                                          'value':
                                              '₹${totalOwnerAmount.toStringAsFixed(2)}',
                                          'amountPaid': totalOwnerAmount,
                                        },
                                      if (totalPaidAmount > 0)
                                        {
                                          'keyTitle': 'Summary (Subprojects)',
                                          'value':
                                              '₹${totalPaidAmount.toStringAsFixed(2)}',
                                          'amountPaid': totalPaidAmount,
                                        },
                                    ],
                                  });
                                }
                              };

                              final onRowLongPress = () {
                                if (!isSelectionMode) {
                                  setState(() {
                                    isSelectionMode = true;
                                    selectedDocIds.add(groupedEntry['id']);
                                    // Hide search and reset filter when selecting
                                    isSearching = false;
                                    _searchController.clear();
                                    _filterData("");
                                  });
                                }
                              };

                              return TableRow(
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.blue.withOpacity(0.1)
                                      : null,
                                ),
                                children: [
                                  // Index / Checkbox Cell
                                  _buildDataCell(
                                    isSelectionMode
                                        ? Checkbox(
                                            value: isSelected,
                                            onChanged: (val) {
                                              onRowTap();
                                            },
                                          )
                                        : Text(
                                            "${index + 1}",
                                            style: TextStyle(
                                              color: Theme.of(
                                                context,
                                              ).primaryColor,
                                              fontWeight: FontWeight.bold,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                    onTap: onRowTap,
                                    onLongPress: onRowLongPress,
                                  ),
                                  // Date Cell
                                  _buildDataCell(
                                    Text(dateStr),
                                    onTap: onRowTap,
                                    onLongPress: onRowLongPress,
                                  ),
                                  // Dynamic Key Value Cells
                                  ...sortedPairs.map((pair) {
                                    final parts = pair.split("|");
                                    final colSubproject = parts[0];
                                    final colKey = parts[1];

                                    // Find all docs in this grouped row that match the column's subproject
                                    List<String> values = [];
                                    for (var data in docs) {
                                      final rowSubproject =
                                          data['subprojectName'] ?? "Untitled";
                                      if (rowSubproject == colSubproject) {
                                        for (var section in [
                                          'fields',
                                          'milestones',
                                          'dualFields',
                                          'labourFields',
                                        ]) {
                                          final list =
                                              data[section] as List? ?? [];
                                          for (var item in list) {
                                            if (item is Map &&
                                                item['keyTitle'] == colKey) {
                                              if (section == 'fields') {
                                                values.add(
                                                  "${item['value'] ?? ''}, ${item['amountPaid'] ?? 0}",
                                                );
                                              } else if (section ==
                                                  'milestones') {
                                                values.add(
                                                  "${item['amountPaid'] ?? 0}",
                                                );
                                              } else if (section ==
                                                  'dualFields') {
                                                final entries =
                                                    item['myValue'] as List? ??
                                                    [];
                                                values.add(
                                                  entries
                                                      .map((e) {
                                                        final title =
                                                            e['title'] ?? '';
                                                        final desc =
                                                            e['description'] ??
                                                            '';
                                                        final paid =
                                                            e['amountPaid'] ??
                                                            0;
                                                        return "$title${desc.isNotEmpty ? ', $desc' : ''}, $paid";
                                                      })
                                                      .join(", "),
                                                );
                                              } else if (section ==
                                                  'labourFields') {
                                                final entries =
                                                    item['myValue'] as List? ??
                                                    [];
                                                values.add(
                                                  entries
                                                      .map((e) {
                                                        final title =
                                                            e['title'] ?? '';
                                                        final desc =
                                                            e['description'] ??
                                                            '';
                                                        final paid =
                                                            e['amountPaid'] ??
                                                            0;
                                                        return "$title${desc.isNotEmpty ? ', $desc' : ''}, $paid";
                                                      })
                                                      .join(", "),
                                                );
                                              }
                                            }
                                          }
                                        }
                                      }
                                    }
                                    final displayValue = values.join(" | ");
                                    return _buildDataCell(
                                      Text(
                                        displayValue.isEmpty
                                            ? "-"
                                            : displayValue,
                                        textAlign: TextAlign.start,
                                      ),
                                      onTap: onRowTap,
                                      onLongPress: onRowLongPress,
                                    );
                                  }),
                                  // Total Paid Cell
                                  _buildDataCell(
                                    Text(
                                      "${groupedEntry['totalAmountPaid'] ?? 0}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    onTap: onRowTap,
                                    onLongPress: onRowLongPress,
                                  ),
                                  // Actions Cell
                                  _buildDataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit,
                                            color: Colors.blue,
                                            size: 20,
                                          ),
                                          onPressed: () =>
                                              _showUpdateDocsDialog(docs),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                            size: 20,
                                          ),
                                          onPressed: () => _confirmDeleteGroup(
                                            docs,
                                            dateStr,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (isSummaryVisible)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(32),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildSummaryRow(
                          context,
                          title: "Owner Amount",
                          amount: ownerTotal,
                        ),
                        const SizedBox(height: 12),
                        _buildSummaryRow(
                          context,
                          title: "Paid Amount",
                          amount: displayTotal,
                        ),
                        const Divider(height: 24),
                        _buildSummaryRow(
                          context,
                          title: "Balance Amount",
                          amount: ownerTotal - displayTotal,
                          isTotal: true,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context, {
    required String title,
    required double amount,
    bool isTotal = false,
  }) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "$title: ",
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        Tooltip(
          message: NumberToWords.convert(amount),
          child: Text(
            NumberToWords.formatAmount(amount),
            style: TextStyle(
              fontSize: isTotal ? 20 : 16,
              fontWeight: FontWeight.bold,
              color: isTotal
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderCell(String text) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildDataCell(
    Widget child, {
    VoidCallback? onTap,
    VoidCallback? onLongPress,
  }) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        constraints: const BoxConstraints(minHeight: 48),
        alignment: Alignment.centerLeft,
        child: child,
      ),
    );
  }
}
