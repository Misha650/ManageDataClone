import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ShowTitleProjectTablePage extends StatefulWidget {
  final String projectId;
  final String subprojectId;
  final String subprojectName;
  final String searchedTitle;
  final List<DocumentSnapshot> allDocs;

  const ShowTitleProjectTablePage({
    super.key,
    required this.projectId,
    required this.subprojectId,
    required this.subprojectName,
    required this.searchedTitle,
    required this.allDocs,
  });

  @override
  State<ShowTitleProjectTablePage> createState() =>
      _ShowTitleProjectTablePageState();
}

class _ShowTitleProjectTablePageState extends State<ShowTitleProjectTablePage> {
  Set<int> selectedIndices = {};
  bool isSelectionMode = false;
  bool isSearching = false;
  String searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Collect data for the specific title
    final List<Map<String, dynamic>> allTitleData = [];

    final queryLC = widget.searchedTitle.toLowerCase();
    for (var doc in widget.allDocs) {
      final data = doc.data() as Map<String, dynamic>;
      final date = (data['date'] as Timestamp?)?.toDate();
      final dateStr = date != null
          ? DateFormat('dd/MM/yy').format(date)
          : "N/A";

      for (var section in ['dualFields', 'labourFields']) {
        final list = data[section] as List? ?? [];
        for (var item in list) {
          if (item is Map) {
            final keyTitleLC = (item['keyTitle'] ?? "")
                .toString()
                .toLowerCase();
            final myValue = item['myValue'] as List? ?? [];

            // If the category (keyTitle) itself matches, add ALL sub-items
            if (keyTitleLC == queryLC) {
              for (var subItem in myValue) {
                if (subItem is Map) {
                  allTitleData.add({'date': dateStr, 'details': subItem});
                }
              }
            } else {
              // Otherwise, check if specific sub-item titles match
              for (var subItem in myValue) {
                if (subItem is Map &&
                    (subItem['title'] ?? "").toString().toLowerCase() ==
                        queryLC) {
                  allTitleData.add({'date': dateStr, 'details': subItem});
                }
              }
            }
          }
        }
      }
    }

    // Filter data based on local search query
    final List<Map<String, dynamic>> titleData = allTitleData.where((item) {
      if (searchQuery.isEmpty) return true;
      final q = searchQuery.toLowerCase();
      final date = (item['date'] ?? "").toString().toLowerCase();
      final details = item['details'] as Map<String, dynamic>;
      final title = (details['title'] ?? "").toString().toLowerCase();
      final desc = (details['description'] ?? "").toString().toLowerCase();
      final paid = (details['amountPaid'] ?? "").toString().toLowerCase();
      final bal = (details['balance'] ?? "").toString().toLowerCase();

      return date.contains(q) ||
          title.contains(q) ||
          desc.contains(q) ||
          paid.contains(q) ||
          bal.contains(q);
    }).toList();

    // Calculate total amount paid (either selected or grand total)
    double totalAmountPaid = 0;
    if (selectedIndices.isNotEmpty) {
      for (var index in selectedIndices) {
        if (index < titleData.length) {
          final details = titleData[index]['details'] as Map<String, dynamic>;
          totalAmountPaid +=
              double.tryParse((details['amountPaid'] ?? 0).toString()) ?? 0;
        }
      }
    } else {
      for (var data in titleData) {
        final details = data['details'] as Map<String, dynamic>;
        totalAmountPaid +=
            double.tryParse((details['amountPaid'] ?? 0).toString()) ?? 0;
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
                    selectedIndices.clear();
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
                onChanged: (val) {
                  setState(() {
                    searchQuery = val;
                  });
                },
              )
            : Text(
                isSelectionMode
                    ? "${selectedIndices.length} Selected"
                    : "${widget.searchedTitle} Details",
              ),
        actions: [
          if (isSelectionMode)
            IconButton(
              icon: const Icon(Icons.select_all_rounded),
              onPressed: () {
                setState(() {
                  if (selectedIndices.length == titleData.length) {
                    selectedIndices.clear();
                  } else {
                    selectedIndices.addAll(
                      List.generate(titleData.length, (index) => index),
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
                    searchQuery = "";
                    _searchController.clear();
                  }
                });
              },
            ),
        ],
      ),
      body: titleData.isEmpty
          ? const Center(child: Text("No data found for this title"))
          : SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  showCheckboxColumn: false,
                  headingRowColor: WidgetStateProperty.all(
                    Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  ),
                  columns: const [
                    DataColumn(
                      label: Text(
                        "Index",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "Date",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "Title",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "Description",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "Amount Paid",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "Balance",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                  rows: List.generate(titleData.length, (index) {
                    final data = titleData[index];
                    final details = data['details'] as Map<String, dynamic>;
                    final isSelected = selectedIndices.contains(index);

                    return DataRow(
                      selected: isSelected,
                      onLongPress: () {
                        if (!isSelectionMode) {
                          setState(() {
                            isSelectionMode = true;
                            selectedIndices.add(index);
                          });
                        }
                      },
                      onSelectChanged: isSelectionMode
                          ? (value) {
                              setState(() {
                                if (value == true) {
                                  selectedIndices.add(index);
                                } else {
                                  selectedIndices.remove(index);
                                }
                                if (selectedIndices.isEmpty) {
                                  isSelectionMode = false;
                                }
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
                                        selectedIndices.add(index);
                                      } else {
                                        selectedIndices.remove(index);
                                      }
                                      if (selectedIndices.isEmpty) {
                                        isSelectionMode = false;
                                      }
                                    });
                                  },
                                )
                              : Text("${index + 1}"),
                        ),
                        DataCell(Text(data['date'])),
                        DataCell(Text(details['title'] ?? "-")),
                        DataCell(Text(details['description'] ?? "-")),
                        DataCell(Text("${details['amountPaid'] ?? 0}")),
                        DataCell(Text("${details['balance'] ?? 0}")),
                      ],
                    );
                  }),
                ),
              ),
            ),
      bottomNavigationBar: titleData.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedIndices.isNotEmpty
                        ? "Selected Total:"
                        : "Total Amount Paid:",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    totalAmountPaid.toStringAsFixed(2),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
