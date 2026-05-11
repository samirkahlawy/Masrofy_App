import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/currency_formatter.dart';
import '../../logic/budget_provider.dart';
import '../../logic/expense_provider.dart';
import '../../models/category.dart';
import '../../models/expense.dart';
import '../widgets/expense_pie_chart.dart';
import '../widgets/safe_limit_card.dart';

/// The primary dashboard screen showing budget overview and recent expenses.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    // Build logic for displaying SafeLimitCard, ExpensePieChart, and recent history
    return Scaffold(/* ... */);
  }
}