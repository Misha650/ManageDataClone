import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  String searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchTotalData();
  }

  Future<void> _fetchTotalData() async {
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

          if (!groupedData.containsKey(dateStr)) {
            groupedData[dateStr] = {
              'id': dateStr,
              'date': data['date'],
              'totalAmountPaid': (data['totalAmountPaid'] as num? ?? 0)
                  .toDouble(),
              'docs': [
                {...data, 'subprojectName': subprojectName, 'id': formDoc.id},
              ],
            };
          } else {
            final entry = groupedData[dateStr]!;
            entry['totalAmountPaid'] += (data['totalAmountPaid'] as num? ?? 0)
                .toDouble();
            (entry['docs'] as List).add({
              ...data,
              'subprojectName': subprojectName,
              'id': formDoc.id,
            });
          }
        }
      }

      final List<Map<String, dynamic>> finalData = groupedData.values.toList();
      finalData.sort((a, b) {
        final dateA = (a['date'] as Timestamp?)?.toDate() ?? DateTime(0);
        final dateB = (b['date'] as Timestamp?)?.toDate() ?? DateTime(0);
        return dateB.compareTo(dateA);
      });

      setState(() {
        allFormData = finalData;
        filteredData = finalData;
        isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error fetching data: $e")));
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  void _filterData(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredData = allFormData;
      } else {
        final q = query.toLowerCase();
        filteredData = allFormData.where((groupedEntry) {
          final dateStr = (groupedEntry['id'] ?? "").toString().toLowerCase();
          final totalPaid = (groupedEntry['totalAmountPaid'] ?? 0)
              .toString()
              .toLowerCase();

          if (dateStr.contains(q) || totalPaid.contains(q)) return true;

          final docs = groupedEntry['docs'] as List? ?? [];
          for (var data in docs) {
            final subName = (data['subprojectName'] ?? "")
                .toString()
                .toLowerCase();
            if (subName.contains(q)) return true;

            for (var section in [
              'fields',
              'milestones',
              'dualFields',
              'labourFields',
            ]) {
              final list = data[section] as List? ?? [];
              for (var item in list) {
                if (item is Map) {
                  final kt = (item['keyTitle'] ?? "").toString().toLowerCase();
                  final val = (item['value'] ?? "").toString().toLowerCase();
                  if (kt.contains(q) || val.contains(q)) return true;
                  if (item.containsKey('myValue') && item['myValue'] is List) {
                    for (var subItem in (item['myValue'] as List)) {
                      if (subItem is Map) {
                        final title = (subItem['title'] ?? "")
                            .toString()
                            .toLowerCase();
                        if (title.contains(q)) return true;
                      }
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

  @override
  Widget build(BuildContext context) {
    // Collect all unique (Subproject, KeyTitle) combinations
    final Set<String> allCategoryKeys = {};
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
              allCategoryKeys.add("$subName|${item['keyTitle']}");
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
    if (selectedDocIds.isNotEmpty) {
      for (var data in allFormData) {
        if (selectedDocIds.contains(data['id'])) {
          displayTotal += (data['totalAmountPaid'] as num? ?? 0).toDouble();
        }
      }
    } else {
      for (var data in filteredData) {
        displayTotal += (data['totalAmountPaid'] as num? ?? 0).toDouble();
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
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: "Search...",
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
                          },
                          children: [
                            // --- Header Row 1: Categories (Yellow) ---
                            TableRow(
                              decoration: const BoxDecoration(
                                color: Colors.yellow,
                              ),
                              children: [
                                _buildHeaderCell("Index"),
                                _buildHeaderCell("Date"),
                                ...sortedPairs.map((pair) {
                                  final parts = pair.split("|");
                                  return _buildHeaderCell(parts[0]);
                                }),
                                _buildHeaderCell("Total Paid"),
                              ],
                            ),
                            // --- Header Row 2: KeyTitles (Pink) ---
                            TableRow(
                              decoration: const BoxDecoration(
                                color: Color.fromARGB(
                                  255,
                                  255,
                                  192,
                                  203,
                                ), // Pink
                              ),
                              children: [
                                _buildHeaderCell(""),
                                _buildHeaderCell(""),
                                ...sortedPairs.map((pair) {
                                  final parts = pair.split("|");
                                  return _buildHeaderCell(parts[1]);
                                }),
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

                              return TableRow(
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.blue.withOpacity(0.2)
                                      : null,
                                ),
                                children: [
                                  // Index / Checkbox Cell
                                  _buildDataCell(
                                    GestureDetector(
                                      onLongPress: () {
                                        if (!isSelectionMode) {
                                          setState(() {
                                            isSelectionMode = true;
                                            selectedDocIds.add(
                                              groupedEntry['id'],
                                            );
                                          });
                                        }
                                      },
                                      child: isSelectionMode
                                          ? Checkbox(
                                              value: isSelected,
                                              onChanged: (val) {
                                                setState(() {
                                                  if (val == true) {
                                                    selectedDocIds.add(
                                                      groupedEntry['id'],
                                                    );
                                                  } else {
                                                    selectedDocIds.remove(
                                                      groupedEntry['id'],
                                                    );
                                                  }
                                                  if (selectedDocIds.isEmpty)
                                                    isSelectionMode = false;
                                                });
                                              },
                                            )
                                          : Text("${index + 1}"),
                                    ),
                                  ),
                                  // Date Cell
                                  _buildDataCell(Text(dateStr)),
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
                                                      .map(
                                                        (e) =>
                                                            "${e['title']}, ${e['amountPaid']}",
                                                      )
                                                      .join(", "),
                                                );
                                              } else if (section ==
                                                  'labourFields') {
                                                final entries =
                                                    item['myValue'] as List? ??
                                                    [];
                                                values.add(
                                                  entries
                                                      .map(
                                                        (e) =>
                                                            "${e['title']}, ${e['amountPaid']}",
                                                      )
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
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    border: Border(
                      top: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "Total Amount: ",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      Text(
                        displayTotal.toStringAsFixed(2),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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

  Widget _buildDataCell(Widget child) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      constraints: const BoxConstraints(minHeight: 48),
      alignment: Alignment.centerLeft,
      child: child,
    );
  }
}
