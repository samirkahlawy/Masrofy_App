import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../logic/expense_provider.dart';
import '../../logic/budget_provider.dart';
import '../../models/expense.dart';

/// A screen that allows users to record a new expense.
/// 
/// It provides input fields for the amount, note, and category selection.
class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  int? _selectedCategoryId;
  bool _isSaving = false;
  String? _errorMessage;

  /// Mock categories used for selection.
  final List<Map<String, dynamic>> _mockCategories = [
    {
      'id': 1,
      'name': 'طعام',
      'icon': Icons.restaurant_rounded,
      'colors': const [Color(0xFFFF7A59), Color(0xFFFFD0BF)],
    },
    {
      'id': 2,
      'name': 'مواصلات',
      'icon': Icons.directions_bus_rounded,
      'colors': const [Color(0xFF2878E3), Color(0xFFBCD9FF)],
    },
    {
      'id': 3,
      'name': 'ترفيه',
      'icon': Icons.movie_filter_rounded,
      'colors': const [Color(0xFF8E58E8), Color(0xFFE0CEFF)],
    },
    {
      'id': 4,
      'name': 'تسوق',
      'icon': Icons.shopping_bag_rounded,
      'colors': const [Color(0xFFD9931E), Color(0xFFFFC75F)],
    },
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  /// Validates input and saves the expense to the repository.
  Future<void> _saveExpense() async {
    final amountStr = _amountController.text.trim();
    final amount = double.tryParse(amountStr);

    if (amount == null || amount <= 0) {
      setState(() => _errorMessage = 'يرجى إدخال مبلغ صحيح');
      return;
    }

    if (_selectedCategoryId == null) {
      setState(() => _errorMessage = 'يرجى اختيار فئة للمصروف');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final expense = Expense(
        amount: amount,
        note: _noteController.text.trim(),
        categoryId: _selectedCategoryId,
        date: DateTime.now(),
      );

      await Provider.of<ExpenseProvider>(context, listen: false).addExpense(expense);
      await Provider.of<BudgetProvider>(context, listen: false).refresh();

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _isSaving = false;
        _errorMessage = 'حدث خطأ أثناء الحفظ. حاول مرة أخرى.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // UI code omitted for brevity as per the provided source content
    return Scaffold(/* ... */);
  }
}