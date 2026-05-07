import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../logic/expense_provider.dart';
import '../../logic/budget_provider.dart';
import '../../models/expense.dart';

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

  // Mock categories - in a real app these would come from a categories provider
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
      'colors': const [Color(0xFFD9931E), Color(0xFFFFE3A5)],
    },
    {
      'id': 5,
      'name': 'أخرى',
      'icon': Icons.auto_awesome_rounded,
      'colors': const [Color(0xFF11695C), Color(0xFFBCE8DF)],
    },
  ];

  Future<void> _onSave() async {
    final amount =
        double.tryParse(_amountController.text.replaceAll(',', '.')) ?? 0;
    final note = _noteController.text.trim();

    if (amount <= 0) {
      setState(() {
        _errorMessage = 'أدخل مبلغًا صالحًا.';
      });
      return;
    }

    if (_selectedCategoryId == null) {
      setState(() {
        _errorMessage = 'اختر فئة للمصروف.';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final expense = Expense(
      amount: amount,
      note: note,
      date: DateTime.now(),
      categoryId: _selectedCategoryId,
      userId: 1,
    );
    final expenseProvider = Provider.of<ExpenseProvider>(
      context,
      listen: false,
    );
    final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);
    final navigator = Navigator.of(context);

    await expenseProvider.addExpense(expense);

    // Update budget remaining
    final newRemaining = budgetProvider.remainingBudget - amount;
    await budgetProvider.updateRemainingBudget(newRemaining);

    if (!mounted) return;
    navigator.pop();
  }

  Map<String, dynamic>? get _selectedCategory {
    for (final category in _mockCategories) {
      if (category['id'] == _selectedCategoryId) return category;
    }
    return null;
  }

  String get _amountPreview {
    final amount =
        double.tryParse(_amountController.text.replaceAll(',', '.')) ?? 0;
    if (amount <= 0) return '0';
    final value = amount == amount.roundToDouble()
        ? amount.toStringAsFixed(0)
        : amount.toStringAsFixed(2);
    return value;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedCategory = _selectedCategory;

    return Scaffold(
      backgroundColor: const Color(0xFFF4FAF8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF123B34),
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 24,
        toolbarHeight: 74,
        title: Directionality(
          textDirection: TextDirection.rtl,
          child: Text(
            'إضافة مصروف جديد',
            style: theme.textTheme.titleLarge?.copyWith(
              color: const Color(0xFF123B34),
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
            const Positioned(
              top: -130,
              right: -70,
              child: _BackgroundOrb(
                size: 310,
                colors: [Color(0x3311695C), Color(0x0011695C)],
              ),
            ),
            const Positioned(
              bottom: -170,
              left: -90,
              child: _BackgroundOrb(
                size: 360,
                colors: [Color(0x24D9931E), Color(0x00D9931E)],
              ),
            ),
            SafeArea(
              top: false,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _ExpenseHeroCard(
                          amountPreview: _amountPreview,
                          selectedCategory: selectedCategory,
                        ),
                        const SizedBox(height: 18),
                        _FormPanel(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _PanelHeader(
                                icon: Icons.edit_note_rounded,
                                title: 'تفاصيل المصروف',
                                subtitle:
                                    'سجل الحركة بسرعة، واختر الفئة المناسبة لتبقى ميزانيتك واضحة.',
                              ),
                              const SizedBox(height: 22),
                              _PremiumTextField(
                                controller: _amountController,
                                label: 'المبلغ',
                                hint: 'مثال: 125.50',
                                icon: Icons.payments_rounded,
                                prefixText: '£ ',
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                onChanged: (_) => setState(() {}),
                              ),
                              const SizedBox(height: 16),
                              _PremiumTextField(
                                controller: _noteController,
                                label: 'ملاحظة',
                                hint: 'مثال: قهوة مع الأصدقاء',
                                icon: Icons.notes_rounded,
                                maxLines: 3,
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'الفئة',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: const Color(0xFF173B35),
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: _mockCategories.map((category) {
                                  final isSelected =
                                      _selectedCategoryId == category['id'];
                                  return _CategoryChoiceChip(
                                    category: category,
                                    isSelected: isSelected,
                                    onTap: () {
                                      setState(() {
                                        _selectedCategoryId =
                                            category['id'] as int;
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 220),
                                child: _errorMessage == null
                                    ? const SizedBox(height: 26)
                                    : Padding(
                                        key: ValueKey(_errorMessage),
                                        padding: const EdgeInsets.only(
                                          top: 22,
                                          bottom: 18,
                                        ),
                                        child: _ErrorBanner(
                                          message: _errorMessage!,
                                        ),
                                      ),
                              ),
                              _SaveButton(
                                isSaving: _isSaving,
                                onPressed: _isSaving ? null : _onSave,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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

class _ExpenseHeroCard extends StatelessWidget {
  const _ExpenseHeroCard({
    required this.amountPreview,
    required this.selectedCategory,
  });

  final String amountPreview;
  final Map<String, dynamic>? selectedCategory;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedColors =
        selectedCategory?['colors'] as List<Color>? ??
        const [Color(0xFF11695C), Color(0xFFBCE8DF)];
    final selectedIcon =
        selectedCategory?['icon'] as IconData? ?? Icons.receipt_long_rounded;
    final selectedName = selectedCategory?['name'] as String? ?? 'اختر الفئة';

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF123B34), Color(0xFF11695C), Color(0xFF1FA48E)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF11695C).withValues(alpha: 0.26),
            blurRadius: 32,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -40,
            left: -34,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.10),
              ),
            ),
          ),
          Positioned(
            bottom: -54,
            right: -26,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.14),
                  width: 18,
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: selectedColors,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: selectedColors.first.withValues(alpha: 0.26),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(selectedIcon, color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'مصروف جديد',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          selectedName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.72),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Text(
                'المبلغ',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.70),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  '£ $amountPreview',
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FormPanel extends StatelessWidget {
  const _FormPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.92)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 28,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _PanelHeader extends StatelessWidget {
  const _PanelHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: const Color(0xFF11695C).withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: const Color(0xFF11695C)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF173B35),
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF6C7D77),
                  fontWeight: FontWeight.w600,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PremiumTextField extends StatelessWidget {
  const _PremiumTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.prefixText,
    this.maxLines = 1,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? prefixText;
  final int maxLines;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: onChanged,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: const Color(0xFF163A34),
        fontWeight: FontWeight.w800,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixText: prefixText,
        prefixIcon: Padding(
          padding: const EdgeInsetsDirectional.only(start: 14, end: 10),
          child: Icon(icon, color: const Color(0xFF11695C)),
        ),
        filled: true,
        fillColor: const Color(0xFFF7FBFA),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: Color(0xFFE2EEEA)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: Color(0xFF11695C), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: Color(0xFFE15353)),
        ),
      ),
    );
  }
}

class _CategoryChoiceChip extends StatelessWidget {
  const _CategoryChoiceChip({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  final Map<String, dynamic> category;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = category['colors'] as List<Color>;
    final icon = category['icon'] as IconData;
    final name = category['name'] as String;

    return AnimatedScale(
      duration: const Duration(milliseconds: 180),
      scale: isSelected ? 1.03 : 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? colors.first.withValues(alpha: 0.12)
                : const Color(0xFFF7FBFA),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isSelected ? colors.first : const Color(0xFFE2EEEA),
              width: isSelected ? 1.4 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: colors.first.withValues(alpha: 0.14),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: colors,
                  ),
                ),
                child: Icon(icon, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 9),
              Text(
                name,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: const Color(0xFF173B35),
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 8),
                const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF11695C),
                  size: 18,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFD3D3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_rounded, color: Color(0xFFD93A3A), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFFAF2626),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.isSaving, required this.onPressed});

  final bool isSaving;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: const Color(0xFF11695C),
          disabledBackgroundColor: const Color(0xFF93B7B0),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: isSaving
              ? const SizedBox(
                  key: ValueKey('saving'),
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: Colors.white,
                  ),
                )
              : Row(
                  key: const ValueKey('save'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_rounded, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'حفظ المصروف',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _BackgroundOrb extends StatelessWidget {
  const _BackgroundOrb({required this.size, required this.colors});

  final double size;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: colors),
      ),
    );
  }
}
