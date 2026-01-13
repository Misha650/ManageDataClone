import 'package:flutter/material.dart';
import '../../../../controller/MyprojectDetail_controller.dart';

class DualCard extends StatelessWidget {
  final DualFieldControllers dual;
  final int index;
  final bool isExpanded;
  final bool isDeleting;
  final int? deletingEntryIndex;
  final void Function() onToggleExpand;

  final void Function() onAddEntry;
  final void Function(int entryIndex) onDeleteEntry;
  final void Function() recalculateTotals;
  final InputDecoration Function(String) input;
  final void Function() onChanged;

  final void Function() onDelete;
  final void Function() onLongPress; // <-- new
  final void Function() onCancelDelete;

  const DualCard({
    super.key,
    required this.dual,
    required this.index,
    required this.isExpanded,
    required this.isDeleting,
    required this.deletingEntryIndex,
    required this.onToggleExpand,
    required this.onDelete,
    required this.onLongPress, // <-- use this
    required this.onCancelDelete,
    required this.onAddEntry,
    required this.onDeleteEntry,
    required this.recalculateTotals,
    required this.input,
    required this.onChanged,
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
                  // Main key row
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: dual.mainKeyController,
                          decoration: input('Main Key Title'),
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
                    ...dual.entries.asMap().entries.map((entry) {
                      final ei = entry.key;
                      final e = entry.value;
                      return _DualEntry(
                        entry: e,
                        isDeleting: deletingEntryIndex == ei,
                        onDelete: () => onDeleteEntry(ei),
                        recalculateTotals: recalculateTotals,
                        input: input,
                        onChanged: onChanged,
                      );
                    }),
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

class _DualEntry extends StatelessWidget {
  final DualEntryControllers entry;
  final bool isDeleting;
  final VoidCallback onDelete;
  final VoidCallback recalculateTotals;
  final InputDecoration Function(String) input;
  final VoidCallback onChanged;

  const _DualEntry({
    required this.entry,
    required this.isDeleting,
    required this.onDelete,
    required this.recalculateTotals,
    required this.input,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onDelete,
      child: Stack(
        children: [
          Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: entry.titleController,
                          decoration: input('Title'),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.bookmark,
                          color: entry.remembered ? Colors.orange : Colors.grey,
                        ),
                        onPressed: () {
                          entry.remembered = !entry.remembered;
                          onChanged();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: entry.descriptionController,
                    decoration: input('Description'),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: entry.amountPaidController,
                          keyboardType: TextInputType.number,
                          decoration: input('Amount Paid'),
                          onChanged: (_) => recalculateTotals(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: entry.balanceController,
                          keyboardType: TextInputType.number,
                          decoration: input('Pending Amount'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          if (isDeleting)
            Positioned(
              top: 4,
              right: 4,
              child: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: onDelete,
              ),
            ),
        ],
      ),
    );
  }
}
