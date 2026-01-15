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

      List<Map<String, dynamic>> tempAllData = [];

      for (var subDoc in subprojectsSnap.docs) {
        final subprojectName = subDoc.data()['title'] ?? "Untitled";
        final formDataSnap = await subDoc.reference
            .collection("formData")
            .orderBy('date', descending: true)
            .get();
        for (var formDoc in formDataSnap.docs) {
          final data = formDoc.data();
          data['id'] = formDoc.id;
          data['subprojectName'] = subprojectName;
          data['subprojectId'] = subDoc.id;
          tempAllData.add(data);
        }
      }

      setState(() {
        allFormData = tempAllData;
        filteredData = tempAllData;
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
        filteredData = allFormData.where((data) {
          final date = (data['date'] as Timestamp?)?.toDate();
          final dateStr = date != null
              ? DateFormat('dd/MM/yy').format(date).toLowerCase()
              : "";
          final totalPaid = (data['totalAmountPaid'] ?? 0)
              .toString()
              .toLowerCase();
          final subName = (data['subprojectName'] ?? "")
              .toString()
              .toLowerCase();

          bool match =
              dateStr.contains(q) ||
              totalPaid.contains(q) ||
              subName.contains(q);
          if (match) return true;

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
          return false;
        }).toList();
      }
    });
  }

  Widget _buildTwoTierHeader(String top, String bottom) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (top.isNotEmpty)
          Text(
            top,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.blueGrey,
              fontWeight: FontWeight.w400,
            ),
          ),
        Text(
          bottom,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Collect all unique (Subproject, KeyTitle) combinations
    final Set<String> allCategoryKeys = {};
    for (var data in filteredData) {
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
                      child: DataTable(
                        showCheckboxColumn: false,
                        columnSpacing: 20,
                        headingRowHeight: 60,
                        headingRowColor: WidgetStateProperty.all(
                          Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.1),
                        ),
                        columns: [
                          DataColumn(
                            label: _buildTwoTierHeader(
                              "",
                              isSelectionMode ? "" : "Index",
                            ),
                          ),
                          DataColumn(label: _buildTwoTierHeader("", "Date")),
                          ...sortedPairs.map((pair) {
                            final parts = pair.split("|");
                            return DataColumn(
                              label: _buildTwoTierHeader(parts[0], parts[1]),
                            );
                          }),
                          DataColumn(
                            label: _buildTwoTierHeader("", "Total Paid"),
                          ),
                        ],
                        rows: List.generate(filteredData.length, (index) {
                          final data = filteredData[index];
                          final date = (data['date'] as Timestamp?)?.toDate();
                          final dateStr = date != null
                              ? DateFormat('dd/MM/yy').format(date)
                              : "N/A";
                          final isSelected = selectedDocIds.contains(
                            data['id'],
                          );
                          final rowSubproject =
                              data['subprojectName'] ?? "Untitled";

                          return DataRow(
                            selected: isSelected,
                            onLongPress: () {
                              if (!isSelectionMode) {
                                setState(() {
                                  isSelectionMode = true;
                                  selectedDocIds.add(data['id']);
                                });
                              }
                            },
                            onSelectChanged: isSelectionMode
                                ? (isSelected) {
                                    setState(() {
                                      if (isSelected == true) {
                                        selectedDocIds.add(data['id']);
                                      } else {
                                        selectedDocIds.remove(data['id']);
                                      }
                                      if (selectedDocIds.isEmpty)
                                        isSelectionMode = false;
                                    });
                                  }
                                : null,
                            cells: [
                              DataCell(
                                isSelectionMode
                                    ? Checkbox(
                                        value: isSelected,
                                        onChanged: (val) {
                                          setState(() {
                                            if (val == true) {
                                              selectedDocIds.add(data['id']);
                                            } else {
                                              selectedDocIds.remove(data['id']);
                                            }
                                            if (selectedDocIds.isEmpty)
                                              isSelectionMode = false;
                                          });
                                        },
                                      )
                                    : Text("${index + 1}"),
                              ),
                              DataCell(Text(dateStr)),
                              ...sortedPairs.map((pair) {
                                final parts = pair.split("|");
                                final colSubproject = parts[0];
                                final colKey = parts[1];

                                // Only show value if this row's subproject matches the column's subproject
                                String value = "";
                                if (rowSubproject == colSubproject) {
                                  for (var section in [
                                    'fields',
                                    'milestones',
                                    'dualFields',
                                    'labourFields',
                                  ]) {
                                    final list = data[section] as List? ?? [];
                                    for (var item in list) {
                                      if (item is Map &&
                                          item['keyTitle'] == colKey) {
                                        if (section == 'fields') {
                                          value =
                                              "${item['value'] ?? ''}, ${item['amountPaid'] ?? 0}";
                                        } else if (section == 'milestones') {
                                          value = "${item['amountPaid'] ?? 0}";
                                        } else if (section == 'dualFields') {
                                          final entries =
                                              item['myValue'] as List? ?? [];
                                          value = entries
                                              .map(
                                                (e) =>
                                                    "${e['title']}, ${e['amountPaid']}",
                                              )
                                              .join(", ");
                                        } else if (section == 'labourFields') {
                                          final entries =
                                              item['myValue'] as List? ?? [];
                                          value = entries
                                              .map(
                                                (e) =>
                                                    "${e['title']}, ${e['amountPaid']}",
                                              )
                                              .join(", ");
                                        }
                                      }
                                    }
                                  }
                                }
                                return DataCell(
                                  Text(value.isEmpty ? "-" : value),
                                );
                              }),
                              DataCell(
                                Text(
                                  "${data['totalAmountPaid'] ?? 0}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
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
}
