import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/currency_formatter.dart';
import '../../logic/expense_provider.dart';
import '../../models/category.dart';
import '../../models/expense.dart';

/// A screen that displays a detailed chronological list of all recorded expenses.
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);

    /// Local mock categories for visualization mapping.
    final mockCategories = [
      Category(id: 1, name: 'طعام'),
      Category(id: 2, name: 'مواصلات'),
      Category(id: 3, name: 'ترفيه'),
      Category(id: 4, name: 'تسوق'),
      Category(id: 5, name: 'أخرى'),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(/* list items and state handling */),
    );
  }
}