import 'package:flutter/material.dart';
import '../../core/utils/currency_formatter.dart';

class SafeLimitCard extends StatelessWidget {
  final double totalExpenses;
  final double monthlyBudget;
  final double safeLimit;

  const SafeLimitCard({
    super.key,
    required this.totalExpenses,
    required this.monthlyBudget,
    required this.safeLimit,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = monthlyBudget > 0
        ? (totalExpenses / monthlyBudget).clamp(0.0, 1.0)
        : 0.0;
    final isOverSafe = totalExpenses > safeLimit;
    final isOverBudget = totalExpenses > monthlyBudget;

    Color backgroundColor;
    Color textColor;
    String statusText;

    if (isOverBudget) {
      backgroundColor = Colors.red.shade100;
      textColor = Colors.red.shade700;
      statusText = 'تجاوزت الميزانية!';
    } else if (isOverSafe) {
      backgroundColor = Colors.orange.shade100;
      textColor = Colors.orange.shade700;
      statusText = 'اقتربت من الحد الآمن';
    } else {
      backgroundColor = Colors.green.shade100;
      textColor = Colors.green.shade700;
      statusText = 'ضمن الحدود الآمنة';
    }

    return Card(
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'الحد الآمن',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: textColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('المصروفات'),
                    Text(
                      CurrencyFormatter.format(totalExpenses),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('الحد الآمن'),
                    Text(
                      CurrencyFormatter.format(safeLimit),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: percentage,
                minHeight: 12,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isOverBudget
                      ? Colors.red
                      : isOverSafe
                      ? Colors.orange
                      : Colors.green,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(percentage * 100).toStringAsFixed(1)}% من الميزانية',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
