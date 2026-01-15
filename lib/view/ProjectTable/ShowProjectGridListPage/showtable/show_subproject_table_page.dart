import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'show_title_project_table_page.dart';

class ShowSubProjectTablePage extends StatefulWidget {
  final String projectId;
  final String subprojectId;
  final String subprojectName;

  ShowSubProjectTablePage({
    super.key,
    required this.projectId,
    required this.subprojectId,
    required this.subprojectName,
  });

  @override
  State<ShowSubProjectTablePage> createState() =>
      _ShowSubProjectTablePageState();
}

class _ShowSubProjectTablePageState extends State<ShowSubProjectTablePage> {
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  Set<String> selectedDocIds = {};
  bool isSelectionMode = false;
  bool isSearching = false;
  String searchQuery = "";
  final TextEditingController _searchController = TextEditingController();
  late Stream<QuerySnapshot> _stream;

  @override
  void initState() {
    super.initState();
    _stream = FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("projects")
        .doc(widget.projectId)
        .collection("subprojects")
        .doc(widget.subprojectId)
        .collection("formData")
        .orderBy('date', descending: true)
        .snapshots();
  }

  // 👈 ye hi apka selected row index hoga
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: isSearching
                  ? TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: "Search...",
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(color: Colors.white),
                      onChanged: (val) {
                        setState(() {
                          searchQuery = val;
                        });
                      },
                    )
                  : Text("${widget.subprojectName} Detail"),
              actions: [
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
            body: const Center(child: Text("No data found")),
          );
        }

        final allDocs = snapshot.data!.docs;

        // Filtering logic
        final filteredDocs = allDocs.where((doc) {
          if (searchQuery.isEmpty) return true;
          final data = doc.data() as Map<String, dynamic>;
          final date = (data['date'] as Timestamp?)?.toDate();
          final dateStr = date != null
              ? DateFormat('dd/MM/yy').format(date).toLowerCase()
              : "";
          final totalPaid = (data['totalAmountPaid'] ?? 0)
              .toString()
              .toLowerCase();

          bool match =
              dateStr.contains(searchQuery.toLowerCase()) ||
              totalPaid.contains(searchQuery.toLowerCase());

          if (match) return true;

          // Check dynamic fields
          for (var section in [
            'fields',
            'milestones',
            'dualFields',
            'labourFields',
          ]) {
            final list = data[section] as List? ?? [];
            for (var item in list) {
              if (item is Map) {
                final keyTitle = (item['keyTitle'] ?? "")
                    .toString()
                    .toLowerCase();
                final value = (item['value'] ?? "").toString().toLowerCase();
                if (keyTitle.contains(searchQuery.toLowerCase()) ||
                    value.contains(searchQuery.toLowerCase())) {
                  return true;
                }
                // Deep search in dualFields/labourFields
                if (item.containsKey('myValue') && item['myValue'] is List) {
                  for (var subItem in (item['myValue'] as List)) {
                    if (subItem is Map) {
                      final title = (subItem['title'] ?? "")
                          .toString()
                          .toLowerCase();
                      if (title.contains(searchQuery.toLowerCase()))
                        return true;
                    }
                  }
                }
              }
            }
          }
          return false;
        }).toList();

        final docDataList = filteredDocs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
        final docIds = filteredDocs.map((doc) => doc.id).toList();

        // 1. Collect all unique keyTitles for columns
        final Set<String> allKeys = {};
        for (var data in docDataList) {
          for (var section in [
            'fields',
            'milestones',
            'dualFields',
            'labourFields',
          ]) {
            final list = data[section] as List? ?? [];
            for (var item in list) {
              if (item is Map && item.containsKey('keyTitle')) {
                allKeys.add(item['keyTitle']);
              }
            }
          }
        }

        final List<String> sortedKeys = allKeys.toList()..sort();

        // 2. Filter keys based on search query (if matches exist)
        final List<String> displayedKeys;
        if (searchQuery.isNotEmpty) {
          final matchingKeys = sortedKeys
              .where(
                (key) => key.toLowerCase().contains(searchQuery.toLowerCase()),
              )
              .toList();
          if (matchingKeys.isNotEmpty) {
            displayedKeys = matchingKeys;
          } else {
            displayedKeys = sortedKeys;
          }
        } else {
          displayedKeys = sortedKeys;
        }

        // Calculate total (either selected or grand total of filtered)
        double displayTotal = 0;
        if (selectedDocIds.isNotEmpty) {
          for (var doc in allDocs) {
            if (selectedDocIds.contains(doc.id)) {
              displayTotal +=
                  (doc.data() as Map<String, dynamic>)['totalAmountPaid']
                      as num? ??
                  0;
            }
          }
        } else {
          for (var data in docDataList) {
            displayTotal += (data['totalAmountPaid'] as num?)?.toDouble() ?? 0;
          }
        }

        // Check if searchQuery matches any title or keyTitle exactly
        bool isSearchMatched = false;
        if (searchQuery.isNotEmpty) {
          final queryLC = searchQuery.toLowerCase();
          for (var data in docDataList) {
            for (var section in [
              'fields',
              'milestones',
              'dualFields',
              'labourFields',
            ]) {
              final list = data[section] as List? ?? [];
              for (var item in list) {
                if (item is Map) {
                  // Check keyTitle match
                  final kt = (item['keyTitle'] ?? "").toString().toLowerCase();
                  if (kt == queryLC) {
                    isSearchMatched = true;
                    break;
                  }

                  // Check title match (in myValue lists)
                  if (item.containsKey('myValue') && item['myValue'] is List) {
                    final myValue = item['myValue'] as List? ?? [];
                    for (var subItem in myValue) {
                      if (subItem is Map &&
                          (subItem['title'] ?? "").toString().toLowerCase() ==
                              queryLC) {
                        isSearchMatched = true;
                        break;
                      }
                    }
                  }
                }
                if (isSearchMatched) break;
              }
              if (isSearchMatched) break;
            }
            if (isSearchMatched) break;
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
            title: isSelectionMode
                ? Text("${selectedDocIds.length} Selected")
                : isSearching
                ? TextField(
                    controller: _searchController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: "Search...",
                      border: InputBorder.none,
                    ),
                    // style: const TextStyle(color: Colors.white),
                    onChanged: (val) {
                      setState(() {
                        searchQuery = val;
                      });
                    },
                  )
                : Text("${widget.subprojectName} Detail"),
            actions: [
              if (isSelectionMode)
                IconButton(
                  icon: const Icon(Icons.select_all_rounded),
                  onPressed: () {
                    setState(() {
                      if (selectedDocIds.length == docIds.length) {
                        selectedDocIds.clear();
                      } else {
                        selectedDocIds.addAll(docIds);
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
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      showCheckboxColumn: false,
                      columnSpacing: 20,
                      headingRowColor: WidgetStateProperty.all(
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      ),
                      columns: [
                        DataColumn(
                          label: Text(
                            isSelectionMode ? "" : "Index",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const DataColumn(
                          label: Text(
                            "Date",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        ...displayedKeys.map(
                          (key) => DataColumn(
                            label: Text(
                              key,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const DataColumn(
                          label: Text(
                            "Total Paid",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                      rows: List.generate(docDataList.length, (index) {
                        final data = docDataList[index];
                        final date = (data['date'] as Timestamp?)?.toDate();
                        final dateStr = date != null
                            ? DateFormat('dd/MM/yy').format(date)
                            : "N/A";

                        return DataRow(
                          selected: selectedDocIds.contains(docIds[index]),
                          onLongPress: () {
                            if (!isSelectionMode) {
                              setState(() {
                                isSelectionMode = true;
                                selectedDocIds.add(docIds[index]);
                              });
                            }
                          },
                          onSelectChanged: isSelectionMode
                              ? (isSelected) {
                                  setState(() {
                                    if (isSelected == true) {
                                      selectedDocIds.add(docIds[index]);
                                    } else {
                                      selectedDocIds.remove(docIds[index]);
                                    }
                                    if (selectedDocIds.isEmpty) {
                                      isSelectionMode = false;
                                    }
                                  });
                                }
                              : null,
                          cells: [
                            DataCell(
                              isSelectionMode
                                  ? Checkbox(
                                      value: selectedDocIds.contains(
                                        docIds[index],
                                      ),
                                      onChanged: (val) {
                                        setState(() {
                                          if (val == true) {
                                            selectedDocIds.add(docIds[index]);
                                          } else {
                                            selectedDocIds.remove(
                                              docIds[index],
                                            );
                                          }
                                          if (selectedDocIds.isEmpty) {
                                            isSelectionMode = false;
                                          }
                                        });
                                      },
                                    )
                                  : Text("${index + 1}"),
                            ),
                            DataCell(Text(dateStr)),
                            ...displayedKeys.map((key) {
                              // Extract value for this key across all sections
                              String value = "";
                              for (var section in [
                                'fields',
                                'milestones',
                                'dualFields',
                                'labourFields',
                              ]) {
                                final list = data[section] as List? ?? [];
                                for (var item in list) {
                                  if (item is Map && item['keyTitle'] == key) {
                                    if (section == 'fields') {
                                      value =
                                          "${item['value'] ?? ''}, ${item['amountPaid'] ?? 0}";
                                    } else if (section == 'milestones') {
                                      value = "${item['amountPaid'] ?? 0}";
                                    } else if (section == 'dualFields') {
                                      final entries =
                                          item['myValue'] as List? ?? [];
                                      final details = entries
                                          .map((e) {
                                            final title = e['title'] ?? '';
                                            final desc = e['description'] ?? '';
                                            final paid = e['amountPaid'] ?? 0;
                                            final bal = e['balance'] ?? 0;
                                            return "$title${desc.isNotEmpty ? ', $desc' : ''}, $paid Reminder, $bal";
                                          })
                                          .join(", ");
                                      value = details;
                                    } else if (section == 'labourFields') {
                                      final entries =
                                          item['myValue'] as List? ?? [];
                                      final details = entries
                                          .map(
                                            (e) =>
                                                "${e['title']}, ${e['amountPaid']}",
                                          )
                                          .join(", ");
                                      value = details;
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSearchMatched)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.onPrimary,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ShowTitleProjectTablePage(
                                  projectId: widget.projectId,
                                  subprojectId: widget.subprojectId,
                                  subprojectName: widget.subprojectName,
                                  searchedTitle: searchQuery,
                                  allDocs: allDocs,
                                ),
                              ),
                            );
                          },
                          child: const Text(
                            "mybutton",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    Row(
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
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
