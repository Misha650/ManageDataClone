import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ShowTitleProjectTablePage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    // Collect data for the specific title
    final List<Map<String, dynamic>> titleData = [];

    for (var doc in allDocs) {
      final data = doc.data() as Map<String, dynamic>;
      final date = (data['date'] as Timestamp?)?.toDate();
      final dateStr = date != null
          ? DateFormat('dd/MM/yy').format(date)
          : "N/A";

      for (var section in ['dualFields', 'labourFields']) {
        final list = data[section] as List? ?? [];
        for (var item in list) {
          if (item is Map && item.containsKey('myValue')) {
            final myValue = item['myValue'] as List? ?? [];
            for (var subItem in myValue) {
              if (subItem is Map &&
                  (subItem['title'] ?? "").toString().toLowerCase() ==
                      searchedTitle.toLowerCase()) {
                titleData.add({'date': dateStr, 'details': subItem});
              }
            }
          }
        }
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text("$searchedTitle Details")),
      body: titleData.isEmpty
          ? const Center(child: Text("No data found for this title"))
          : SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(
                    Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  ),
                  columns: const [
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
                  rows: titleData.map((data) {
                    final details = data['details'] as Map<String, dynamic>;
                    return DataRow(
                      cells: [
                        DataCell(Text(data['date'])),
                        DataCell(Text(details['title'] ?? "-")),
                        DataCell(Text(details['description'] ?? "-")),
                        DataCell(Text("${details['amountPaid'] ?? 0}")),
                        DataCell(Text("${details['balance'] ?? 0}")),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
    );
  }
}
