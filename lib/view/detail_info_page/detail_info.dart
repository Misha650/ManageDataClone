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
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          title.isNotEmpty ? title : "Detail Information",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF2C2C3E)
            : Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black87,
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
              title: "Date",
              content: dateStr,
              icon: Icons.calendar_month_rounded,
              color: Colors.blue[700]!,
            ),
          const SizedBox(height: 15),
          _buildPremiumCard(
            context,
            title: "Total Paid Amount",
            content: " ${displayAmount.toStringAsFixed(2)}",
            icon: Icons.currency_rupee_rounded,
            color: Colors.green[700]!,
            isAmount: true,
          ),
          if (displayAmount > 0) const SizedBox(height: 15),

          // Owner Summary (NEW) - Show when coming from Total Project Table
          if (data.containsKey('totalOwnerAmount') &&
              (data['totalOwnerAmount'] ?? 0) > 0)
            _buildPremiumCard(
              context,
              title: "Owner Total Amount",
              content:
                  " ${(data['totalOwnerAmount'] as num).toStringAsFixed(2)}",
              icon: Icons.person_rounded,
              color: Colors.blue[800]!,
              isAmount: true,
            ),
          const SizedBox(height: 15),

          if (data['totalOwnerDescription'] != null &&
              data['totalOwnerDescription'].toString().isNotEmpty)
            _buildPremiumCard(
              context,
              title: "Owner Description",
              content: data['totalOwnerDescription'].toString(),
              icon: Icons.person_pin_rounded,
              color: Colors.blue[800]!,
              isDescription: true,
            ),
          if (data.containsKey('totalOwnerAmount') &&
              (data['totalOwnerAmount'] ?? 0) > 0)
            const SizedBox(height: 15),

          if (description.isNotEmpty && !data.containsKey('sourceGroups'))
            _buildPremiumCard(
              context,
              title: "Description",
              content: description,
              icon: Icons.description_rounded,
              color: Colors.orange[800]!,
              isDescription: true,
            ),
          if (description.isNotEmpty && !data.containsKey('sourceGroups'))
            const SizedBox(height: 15),

          // Grouped Source Sections (NEW)
          if (data.containsKey('sourceGroups')) ..._buildSourceGroups(context),

          // Dynamic Sections (Fallback/Legacy)
          if (!data.containsKey('sourceGroups'))
            ..._buildDynamicSections(context),

          const SizedBox(height: 30),

          // ElevatedButton.icon(
          //   onPressed: () => Navigator.pop(context),
          //   icon: const Icon(Icons.arrow_back),
          //   label: const Text("Back to Table"),
          //   style: ElevatedButton.styleFrom(
          //     padding: const EdgeInsets.symmetric(vertical: 15),
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(15),
          //     ),
          //   ),
          // ),
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
        for (var item in (data[key] as List)) {
          if (item is Map) {
            final title = item['keyTitle'] ?? "Item";

            if (key == 'dualFields' || key == 'labourFields') {
              widgets.add(
                _buildPremiumCard(
                  context,
                  title: title,
                  contentWidget: _buildDetailContent(
                    context,
                    item,
                    color: _getColorForSection(key),
                  ),
                  icon: _getIconForSection(key),
                  color: _getColorForSection(key),
                  isDescription: true,
                ),
              );
            } else {
              String subContent = "";
              if (key == 'fields') {
                subContent =
                    "D: ${item['value'] ?? '-'}\nPaid: ${item['amountPaid'] ?? 0}";
              } else if (key == 'milestones') {
                subContent = "Paid: ${item['amountPaid'] ?? 0}";
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
            }
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
          content: " ${data['details']['balance']}",
          icon: Icons.account_balance_wallet_rounded,
          color: Colors.red[700]!,
        ),
      );
    }

    return widgets;
  }

  List<Widget> _buildSourceGroups(BuildContext context) {
    List<Widget> widgets = [];
    final List groups = data['sourceGroups'] as List? ?? [];

    for (var group in groups) {
      if (group is Map) {
        final sourceName = group['sourceName'] ?? "Untitled Source";
        if (sourceName == 'Owner') continue;
        // final groupDesc = group['description'] ?? "";

        // Source Header

        widgets.add(
          Container(
            margin: const EdgeInsets.only(top: 20, bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              sourceName,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
        );

        // Render sections for this group
        final sections = {
          'fields': 'Fields',
          'milestones': 'Milestones',
          'dualFields': 'Extra Details',
          'labourFields': 'Labour Details',
        };

        sections.forEach((key, label) {
          if (group.containsKey(key) &&
              group[key] is List &&
              (group[key] as List).isNotEmpty) {
            for (var item in (group[key] as List)) {
              if (item is Map) {
                widgets.add(_buildItemWidget(context, key, item));
                widgets.add(const SizedBox(height: 10));
              }
            }
          }
        });
      }
    }
    return widgets;
  }

  Widget _buildItemWidget(BuildContext context, String key, Map item) {
    final title = item['keyTitle'] ?? "Item";
    String subContent = "";

    if (key == 'dualFields' || key == 'labourFields') {
      return _buildPremiumCard(
        context,
        title: title,
        contentWidget: _buildDetailContent(
          context,
          item,
          color: _getColorForSection(key),
        ),
        icon: _getIconForSection(key),
        color: _getColorForSection(key),
        isDescription: true,
      );
    }

    if (key == 'fields') {
      subContent =
          "Value: ${item['value'] ?? '-'}\nPaid: ${item['amountPaid'] ?? 0}";
    } else if (key == 'milestones') {
      subContent = "Paid: ${item['amountPaid'] ?? 0}";
    }

    return _buildPremiumCard(
      context,
      title: title,
      content: subContent,
      icon: _getIconForSection(key),
      color: _getColorForSection(key),
      isDescription: true,
    );
  }

  Widget _buildDetailContent(
    BuildContext context,
    Map item, {
    required Color color,
  }) {
    final List myValue = item['myValue'] as List? ?? [];
    final String itemDescription = item['description'] ?? "";
    List<Widget> contentWidgets = [];

    if (itemDescription.isNotEmpty) {
      contentWidgets.add(
        Text(
          itemDescription,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      );
      contentWidgets.add(const SizedBox(height: 10));
    }

    for (int i = 0; i < myValue.length; i++) {
      final e = myValue[i];
      if (e is Map) {
        final t = e['title'] ?? "";
        final p = e['amountPaid'] ?? 0;
        final b = e['balance'] ?? 0;
        final desc = e['description'] ?? "";

        contentWidgets.add(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Title : $t",
                style: const TextStyle(
                  fontSize: 15,
                  fontStyle: FontStyle.italic,
                ),
              ),
              Text(
                "Paid : $p",
                style: const TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
              if (b != 0)
                Text(
                  "reminder : $b",
                  style: const TextStyle(fontSize: 14, color: Colors.red),
                ),
              if (desc.isNotEmpty)
                Text(
                  "Description : $desc",
                  style: const TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
        );

        // Add divider if not the last item
        if (i < myValue.length - 1) {
          contentWidgets.add(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Divider(color: color.withOpacity(0.3), thickness: 1),
            ),
          );
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: contentWidgets,
    );
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
    String? content,
    Widget? contentWidget,
    required IconData icon,
    required Color color,
    bool isAmount = false,
    bool isDescription = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
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
                    fontSize: 16,
                    color: Theme.of(context).textTheme.titleMedium?.color,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.normal,
                  ),
                ),
                const SizedBox(height: 10),
                if (contentWidget != null)
                  contentWidget
                else if (content != null)
                  Text(
                    content,
                    style: TextStyle(
                      fontStyle: isDescription ? FontStyle.italic : null,
                      fontSize: 14,
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
