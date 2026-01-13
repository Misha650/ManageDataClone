import 'package:flutter/material.dart';

class MilestoneRow extends StatelessWidget {
  final int index;
  final TextEditingController titleController;
  final TextEditingController amountController;
  final bool isExpanded;
  final bool isDeleting;
  final void Function() onToggleExpand;
  final void Function(String) onAmountChanged;
  final void Function() onDelete;
  final void Function() onLongPress; // <-- new
  final void Function() onCancelDelete; // <-- new

  final InputDecoration Function(String) inputDecoration;

  const MilestoneRow({
    super.key,
    required this.index,
    required this.titleController,
    required this.amountController,
    required this.isExpanded,
    required this.isDeleting,
    required this.onToggleExpand,
    required this.onAmountChanged,
    required this.onDelete,
    required this.onLongPress, // <-- use this
    required this.onCancelDelete,

    required this.inputDecoration,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress, 
      onTap: () {
        if (isDeleting) {
          onCancelDelete();
        }
      },
      child: Stack(
        children: [
          Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  // --- Title row with arrow ---
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: titleController,
                          decoration: inputDecoration('Title ${index + 1}'),
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

                  // --- Collapsible content ---
                  if (isExpanded) ...[
                    const SizedBox(height: 8),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: inputDecoration('Amount Paid'),
                      onChanged: onAmountChanged,
                    ),
                  ],
                ],
              ),
            ),
          ),

          // --- Delete icon overlay ---
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
