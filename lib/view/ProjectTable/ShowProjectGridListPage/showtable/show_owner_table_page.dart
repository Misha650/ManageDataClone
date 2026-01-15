import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ShowOwnerTablePage extends StatefulWidget {
  final String projectId;
  const ShowOwnerTablePage({super.key, required this.projectId});

  @override
  State<ShowOwnerTablePage> createState() => _ShowOwnerTablePageState();
}

class _ShowOwnerTablePageState extends State<ShowOwnerTablePage> {
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
        .collection("addOwnerDetail")
        .orderBy('date', descending: true)
        .snapshots();
  }

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
                      onChanged: (val) {
                        setState(() {
                          searchQuery = val;
                        });
                      },
                    )
                  : const Text("Owner Details"),
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
            body: const Center(child: Text("No owner details found")),
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
          final description = (data['description'] ?? "")
              .toString()
              .toLowerCase();
          final amount = (data['amount'] ?? 0).toString().toLowerCase();

          return dateStr.contains(searchQuery.toLowerCase()) ||
              description.contains(searchQuery.toLowerCase()) ||
              amount.contains(searchQuery.toLowerCase());
        }).toList();

        final docIds = filteredDocs.map((doc) => doc.id).toList();

        // Calculate total
        double totalAmount = 0;
        if (selectedDocIds.isNotEmpty) {
          for (var doc in allDocs) {
            if (selectedDocIds.contains(doc.id)) {
              totalAmount +=
                  (doc.data() as Map<String, dynamic>)['amount'] as num? ?? 0;
            }
          }
        } else {
          for (var doc in filteredDocs) {
            totalAmount +=
                (doc.data() as Map<String, dynamic>)['amount'] as num? ?? 0;
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
                    onChanged: (val) {
                      setState(() {
                        searchQuery = val;
                      });
                    },
                  )
                : const Text("Owner Details"),
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
                        const DataColumn(
                          label: Text(
                            "Description",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const DataColumn(
                          label: Text(
                            "Amount",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                      rows: List.generate(filteredDocs.length, (index) {
                        final data =
                            filteredDocs[index].data() as Map<String, dynamic>;
                        final date = (data['date'] as Timestamp?)?.toDate();
                        final dateStr = date != null
                            ? DateFormat('dd/MM/yy').format(date)
                            : "N/A";
                        final docId = filteredDocs[index].id;
                        final isSelected = selectedDocIds.contains(docId);

                        return DataRow(
                          selected: isSelected,
                          onLongPress: () {
                            if (!isSelectionMode) {
                              setState(() {
                                isSelectionMode = true;
                                selectedDocIds.add(docId);
                              });
                            }
                          },
                          onSelectChanged: isSelectionMode
                              ? (value) {
                                  setState(() {
                                    if (value == true) {
                                      selectedDocIds.add(docId);
                                    } else {
                                      selectedDocIds.remove(docId);
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
                                      value: isSelected,
                                      onChanged: (val) {
                                        setState(() {
                                          if (val == true) {
                                            selectedDocIds.add(docId);
                                          } else {
                                            selectedDocIds.remove(docId);
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
                            DataCell(Text(data['description'] ?? "-")),
                            DataCell(
                              Text(
                                "${data['amount'] ?? 0}",
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
                      selectedDocIds.isNotEmpty
                          ? "Selected Total: "
                          : "Grand Total: ",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    Text(
                      totalAmount.toStringAsFixed(2),
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
      },
    );
  }
}
