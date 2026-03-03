import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailInfoPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const DetailInfoPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // Extract basic data
    final details = data['details'] as Map<String, dynamic>?;
    final displayAmount =
        (details?['amountPaid'] ??
                data['totalAmountPaid'] ??
                data['amount'] ??
                0.0)
            .toDouble();
    final description = details?['description'] ?? data['description'] ?? "";
    final title = details?['title'] ?? data['subprojectName'] ?? "";

    final DateTime? date = data['date'] != null
        ? (data['date'] is DateTime
              ? data['date']
              : (data['date'] is String ? null : data['date'].toDate()))
        : null;
    final dateStr = (data['date'] is String)
        ? data['date']
        : (date != null
              ? DateFormat('EEEE, dd MMMM yyyy').format(date)
              : "N/A");

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          title.isNotEmpty ? title : "Detail Information",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header Icon
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_rounded,
                size: 50,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 25),

          // Primary Info Section
          if (displayAmount > 0)
            _buildPremiumCard(
              context,
              title: "Total Amount",
              content: "₹ ${displayAmount.toStringAsFixed(2)}",
              icon: Icons.currency_rupee_rounded,
              color: Colors.green[700]!,
              isAmount: true,
            ),
          if (displayAmount > 0) const SizedBox(height: 15),

          _buildPremiumCard(
            context,
            title: "Date",
            content: dateStr,
            icon: Icons.calendar_month_rounded,
            color: Colors.blue[700]!,
          ),
          const SizedBox(height: 15),

          if (description.isNotEmpty)
            _buildPremiumCard(
              context,
              title: "Description",
              content: description,
              icon: Icons.description_rounded,
              color: Colors.orange[800]!,
              isDescription: true,
            ),
          if (description.isNotEmpty) const SizedBox(height: 15),

          // Dynamic Sections
          ..._buildDynamicSections(context),

          const SizedBox(height: 30),

          ElevatedButton.icon(
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
        ],
      ),
    );
  }

  List<Widget> _buildDynamicSections(BuildContext context) {
    List<Widget> widgets = [];

    // Sections to check
    final sections = {
      'fields': 'Fields',
      'milestones': 'Milestones',
      'dualFields': 'Extra Details',
      'labourFields': 'Labour Details',
    };

    sections.forEach((key, label) {
      if (data.containsKey(key) &&
          data[key] is List &&
          (data[key] as List).isNotEmpty) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        );

        for (var item in (data[key] as List)) {
          if (item is Map) {
            final title = item['keyTitle'] ?? "Item";
            String subContent = "";

            if (key == 'fields') {
              subContent =
                  "Value: ${item['value'] ?? '-'}\nPaid: ₹${item['amountPaid'] ?? 0}";
            } else if (key == 'milestones') {
              subContent = "Paid: ₹${item['amountPaid'] ?? 0}";
            } else if (key == 'dualFields' || key == 'labourFields') {
              final myValue = item['myValue'] as List? ?? [];
              subContent = myValue
                  .map((e) {
                    if (e is Map) {
                      final t = e['title'] ?? "";
                      final p = e['amountPaid'] ?? 0;
                      final b = e['balance'] ?? 0;
                      return "• $t: ₹$p ${b != 0 ? '(Bal: ₹$b)' : ''}";
                    }
                    return "";
                  })
                  .join("\n");
            }

            widgets.add(
              _buildPremiumCard(
                context,
                title: title,
                content: subContent,
                icon: _getIconForSection(key),
                color: _getColorForSection(key),
                isDescription: true,
              ),
            );
            widgets.add(const SizedBox(height: 10));
          }
        }
      }
    });

    // Handle 'details' sub-map balance if present
    if (data['details'] != null && data['details']['balance'] != null) {
      widgets.add(
        _buildPremiumCard(
          context,
          title: "Balance Balance",
          content: "₹ ${data['details']['balance']}",
          icon: Icons.account_balance_wallet_rounded,
          color: Colors.red[700]!,
        ),
      );
    }

    return widgets;
  }

  IconData _getIconForSection(String key) {
    switch (key) {
      case 'fields':
        return Icons.list_alt_rounded;
      case 'milestones':
        return Icons.flag_rounded;
      case 'dualFields':
        return Icons.more_horiz_rounded;
      case 'labourFields':
        return Icons.engineering_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  Color _getColorForSection(String key) {
    switch (key) {
      case 'fields':
        return Colors.purple;
      case 'milestones':
        return Colors.teal;
      case 'dualFields':
        return Colors.indigo;
      case 'labourFields':
        return Colors.brown;
      default:
        return Colors.grey;
    }
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
