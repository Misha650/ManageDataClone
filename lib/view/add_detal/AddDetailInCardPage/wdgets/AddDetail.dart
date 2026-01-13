import 'package:flutter/material.dart';

class SimpleRow extends StatelessWidget {
  final int index;
  final TextEditingController keyController;
  final TextEditingController valueController;
  final TextEditingController amountPaidController;
  final bool isExpanded;
  final bool isDeleting;
  final VoidCallback onToggleExpand;

  final VoidCallback onRecalculateTotals;
  final InputDecoration Function(String) input;
  final void Function() onDelete;
  final void Function() onLongPress; // <-- new
  final void Function() onCancelDelete; // <-- new

  const SimpleRow({
    super.key,
    required this.index,
    required this.keyController,
    required this.valueController,
    required this.amountPaidController,
    required this.isExpanded,
    required this.isDeleting,
    required this.onToggleExpand,
    required this.onDelete,
    required this.onLongPress, // <-- use this
    required this.onCancelDelete,

    required this.onRecalculateTotals,
    required this.input,
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
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: keyController,
                          decoration: input('Title ${index + 1}'),
                          minLines: 1,
                          maxLines: null,
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
                    TextField(
                      controller: valueController,
                      decoration: input('Value'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: amountPaidController,
                      keyboardType: TextInputType.number,
                      decoration: input('Amount Paid'),
                      onChanged: (_) => onRecalculateTotals(),
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
