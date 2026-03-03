import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailInfoPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const DetailInfoPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // Extract data with fallbacks
    final amount = (data['amount'] ?? 0.0).toDouble();
    final description = data['description'] ?? "No description provided";
    final DateTime? date = data['date'] != null
        ? (data['date'] is DateTime ? data['date'] : data['date'].toDate())
        : null;
    final dateStr = date != null
        ? DateFormat('EEEE, dd MMMM yyyy').format(date)
        : "N/A";

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Detail Information",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Image or Icon Placeholder
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.receipt_long_rounded,
                  size: 60,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Amount Card
            _buildPremiumCard(
              context,
              title: "Transaction Amount",
              content: "₹ ${amount.toStringAsFixed(2)}",
              icon: Icons.currency_rupee_rounded,
              color: Colors.green[700]!,
              isAmount: true,
            ),
            const SizedBox(height: 20),

            // Date Card
            _buildPremiumCard(
              context,
              title: "Transaction Date",
              content: dateStr,
              icon: Icons.calendar_month_rounded,
              color: Colors.blue[700]!,
            ),
            const SizedBox(height: 20),

            // Description Card
            _buildPremiumCard(
              context,
              title: "Description",
              content: description,
              icon: Icons.description_rounded,
              color: Colors.orange[800]!,
              isDescription: true,
            ),

            const SizedBox(height: 40),

            // Actions Row (Optional)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text("Back to Table"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumCard(
    BuildContext context, {
    required String title,
    required String content,
    required IconData icon,
    required Color color,
    bool isAmount = false,
    bool isDescription = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: isDescription
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: isAmount ? 24 : 16,
                    fontWeight: isAmount ? FontWeight.bold : FontWeight.w600,
                    color: isAmount ? color : Colors.black87,
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
