import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/utils/currency_formatter.dart';
import '../../models/category.dart';

/// A widget that displays a pie chart representing expenses grouped by category.
class ExpensePieChart extends StatelessWidget {
  /// A map where keys are category IDs and values are the total expenses for that category.
  final Map<int, double> expensesByCategory;

  /// The list of available [Category] objects to map IDs to names.
  final List<Category> categories;

  /// Creates an [ExpensePieChart].
  const ExpensePieChart({
    super.key,
    required this.expensesByCategory,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // If no data is available, show a placeholder message.
    if (expensesByCategory.isEmpty) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FBFA),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFE2EEEA)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F4F1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.pie_chart_outline_rounded,
                  color: Color(0xFF2A7C6C),
                  size: 30,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'لا توجد بيانات كافية لعرض الرسم',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF173B35),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'أضف بعض المصروفات لتظهر لك الفئات الأكثر استهلاكًا.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF677873),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final entries = expensesByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = entries.fold<double>(0.0, (sum, entry) => sum + entry.value);

    // Prepare segments for the pie chart.
    final sections = entries.map((entry) {
      final percentage = (entry.value / total) * 100;

      return PieChartSectionData(
        value: entry.value,
        title: percentage >= 8 ? '${percentage.toStringAsFixed(0)}%' : '',
        color: _getCategoryColor(entry.key),
        radius: 72,
        titlePositionPercentageOffset: 0.62,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      );
    }).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final useColumnLayout = constraints.maxWidth < 440;

        final chart = SizedBox(
          height: 250,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 64,
                  sectionsSpace: 4,
                  startDegreeOffset: -90,
                  borderData: FlBorderData(show: false),
                  pieTouchData: PieTouchData(enabled: false),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'الإجمالي',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF71807B),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    CurrencyFormatter.formatCompact(total),
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: const Color(0xFF133A33),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );

        final legend = Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: entries.take(4).map((entry) {
            final category = categories.firstWhere(
              (item) => item.id == entry.key,
              orElse: () => Category(name: 'أخرى'),
            );
            final percentage = total > 0 ? (entry.value / total) * 100 : 0.0;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FCFB),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE4EFEC)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: _getCategoryColor(entry.key),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.name,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF173A34),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            CurrencyFormatter.format(entry.value),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF6C7D78),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${percentage.toStringAsFixed(0)}%',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: const Color(0xFF2A7B6B),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );

        if (useColumnLayout) {
          return Column(
            children: [
              chart,
              const SizedBox(height: 18),
              legend,
            ],
          );
        }

        return Row(
          children: [
            Expanded(flex: 5, child: chart),
            const SizedBox(width: 20),
            Expanded(flex: 4, child: legend),
          ],
        );
      },
    );
  }

  /// Generates a consistent color for a given category ID.
  Color _getCategoryColor(int categoryId) {
    const colors = [
      Color(0xFF1F8A70),
      Color(0xFF0F766E),
      Color(0xFFE67E22),
      Color(0xFFCC5A71),
      Color(0xFF3A86FF),
      Color(0xFF7C5CFC),
      Color(0xFF16A34A),
      Color(0xFFDC2626),
    ];

    return colors[categoryId % colors.length];
  }
}