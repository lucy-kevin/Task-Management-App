import 'package:flutter/material.dart';

class DataTableWidget extends StatelessWidget {
  final List<DataColumn> columns;
  final List<DataRow> rows;
  final String title;
  final VoidCallback? onAddPressed;

  const DataTableWidget({
    required this.columns,
    required this.rows,
    required this.title,
    this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),
                if (onAddPressed != null)
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: onAddPressed,
                    tooltip: 'Add new item',
                  ),
              ],
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: MediaQuery.of(context).size.width - 32,
                ),
                child: DataTable(
                  columns: columns,
                  rows: rows,
                  dividerThickness: 1,
                  showBottomBorder: true,
                  headingRowColor: MaterialStateProperty.resolveWith<Color>(
                    (states) => Colors.grey.shade100,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
