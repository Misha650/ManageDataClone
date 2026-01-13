import 'package:flutter/material.dart';
import '../../../../controller/MyprojectDetail_controller.dart';

class LabourCard extends StatelessWidget {
  final LabourFieldControllers lf;
  final int index;
  final bool isExpanded;
  final bool isDeleting;
  final VoidCallback onToggleExpand;
  final void Function() onDelete;
  final void Function() onLongPress; // <-- new
  final void Function() onCancelDelete;
  final VoidCallback onAddEntry;
  final InputDecoration Function(String) input;
  final void Function() recalculateTotals;
  

  const LabourCard({
    super.key,
    required this.lf,
    required this.index,
    required this.isExpanded,
    required this.isDeleting,
    required this.onToggleExpand,
    required this.onDelete,
    required this.onLongPress, // <-- use this
    required this.onCancelDelete,
    required this.onAddEntry,
    required this.input,
    required this.recalculateTotals,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress, // sirf delete mode on
      onTap: () {
        // 👇 agar delete mode already ON hai, toh cancel kar do
        if (isDeleting) {
          onCancelDelete();
        }
      },
      child: Stack(
        children: [
          Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Title row ---
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: lf.mainKeyController,
                          decoration: input('Labour Key Title'),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                        ),
                        onPressed: onToggleExpand,
                      ),
                    ],
                  ),

                  if (isExpanded) ...[
                    const SizedBox(height: 8),
                    ...lf.entries.map(
                      (e) => _LabourEntry(
                        entry: e,
                        input: input,
                        recalculateTotals: recalculateTotals,
                            onToggleRemember: () => (context as Element).markNeedsBuild(), // 👈 force rebuild

                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        icon: const Icon(Icons.add_circle_outline),
                        label: const Text('Add Entry'),
                        onPressed: onAddEntry,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (isDeleting)
            Positioned(
              top: 10,
              right: 4,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.cancel,
                      color: Colors.grey,
                      size: 30,
                    ),
                    onPressed: onCancelDelete, // 👈 ye sirf hide karega
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red, size: 30),
                    onPressed: onDelete,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _LabourEntry extends StatelessWidget {
  final LabourEntryControllers entry;
  final InputDecoration Function(String) input;
  final VoidCallback recalculateTotals;
    final VoidCallback onToggleRemember; // 👈 add this


  const _LabourEntry({
    required this.entry,
    required this.input,
    required this.recalculateTotals,
        required this.onToggleRemember, // 👈 add this

  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: entry.titleController,
                decoration: input('Title'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: entry.amountPaidController,
                keyboardType: TextInputType.number,
                decoration: input('Amount Paid'),
                onChanged: (_) => recalculateTotals(),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.bookmark,
                color: entry.remembered ? Colors.orange : Colors.grey,
              ),
              onPressed: () {
                entry.remembered = !entry.remembered;
                onToggleRemember(); // 👈 trigger UI update
              },

            ),
          ],
        ),
      ),
    );
  }
}
