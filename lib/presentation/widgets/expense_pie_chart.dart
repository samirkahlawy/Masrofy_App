import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/category.dart';

class ExpensePieChart extends StatelessWidget {
  final Map<int, double> expensesByCategory;
  final List<Category> categories;

  const ExpensePieChart({
    super.key,
    required this.expensesByCategory,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    if (expensesByCategory.isEmpty) {
      return const Center(child: Text('لا توجد بيانات'));
    }

    final total = expensesByCategory.values.fold(0.0, (a, b) => a + b);
    final sections = <PieChartSectionData>[];
    final categoryNames = <String>[];

    expensesByCategory.forEach((categoryId, amount) {
      final category = categories.firstWhere(
        (c) => c.id == categoryId,
        orElse: () => Category(name: 'أخرى'),
      );
      final percentage = (amount / total) * 100;

      sections.add(
        PieChartSectionData(
          value: amount,
          title: '${percentage.toStringAsFixed(0)}%',
          color: _getCategoryColor(categoryId),
          radius: 60,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      categoryNames.add(category.name);
    });

    return Row(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 40,
              sectionsSpace: 2,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(
            expensesByCategory.length > 4 ? 4 : expensesByCategory.length,
            (index) {
              final entry = expensesByCategory.entries.elementAt(index);
              final category = categories.firstWhere(
                (c) => c.id == entry.key,
                orElse: () => Category(name: 'أخرى'),
              );
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      color: _getCategoryColor(entry.key),
                    ),
                    const SizedBox(width: 8),
                    Text(category.name, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(int categoryId) {
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.amber,
    ];
    return colors[categoryId % colors.length];
  }
}
