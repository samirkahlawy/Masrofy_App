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
      child: Scaffold(
        backgroundColor: const Color(0xFFF4FAF8),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: const Color(0xFF123B34),
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0,
          elevation: 0,
          centerTitle: false,
          titleSpacing: 24,
          toolbarHeight: 78,
          title: _HistoryAppBarTitle(
            isEmpty: expenseProvider.expenses.isEmpty,
            isLoading: expenseProvider.isLoading,
          ),
        ),
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF4FAF8), Color(0xFFEAF6F2), Color(0xFFF8FCFB)],
            ),
          ),
          child: expenseProvider.isLoading
              ? const _HistoryLoadingView()
              : expenseProvider.expenses.isEmpty
              ? const _HistoryEmptyView()
              : _HistoryLoadedView(
                  expenses: expenseProvider.expenses,
                  categories: mockCategories,
                  onDeleteExpense: expenseProvider.deleteExpense,
                ),
        ),
      ),
    );
  }
}

class _HistoryAppBarTitle extends StatelessWidget {
  const _HistoryAppBarTitle({required this.isEmpty, required this.isLoading});

  final bool isEmpty;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'سجل المصروفات',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleLarge?.copyWith(
            color: const Color(0xFF123B34),
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          isLoading
              ? 'جار تجهيز بيانات السجل'
              : isEmpty
              ? 'ابدأ التسجيل لتظهر العمليات هنا'
              : 'كل حركة مالية محفوظة بوضوح',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            color: const Color(0xFF667771),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _HistoryLoadedView extends StatelessWidget {
  const _HistoryLoadedView({
    required this.expenses,
    required this.categories,
    required this.onDeleteExpense,
  });

  final List<Expense> expenses;
  final List<Category> categories;
  final Future<void> Function(int id) onDeleteExpense;

  @override
  Widget build(BuildContext context) {
    final totalAmount = expenses.fold<double>(
      0,
      (sum, expense) => sum + expense.amount,
    );
    final averageAmount = totalAmount / expenses.length;
    final latestDate = _latestDate(expenses);
    final activeCategoryCount = expenses
        .map((expense) => expense.categoryId ?? -1)
        .toSet()
        .length;

    return SafeArea(
      top: false,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            sliver: SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _HistorySummaryCard(
                        totalAmount: totalAmount,
                        averageAmount: averageAmount,
                        expenseCount: expenses.length,
                        latestDate: latestDate,
                        activeCategoryCount: activeCategoryCount,
                      ),
                      const SizedBox(height: 20),
                      _HistorySectionHeader(expenseCount: expenses.length),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                if (index.isOdd) {
                  return const SizedBox(height: 12);
                }

                final expense = expenses[index ~/ 2];
                final category = categories.firstWhere(
                  (category) => category.id == expense.categoryId,
                  orElse: () => Category(name: 'أخرى', iconPath: null),
                );

                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: _ExpenseHistoryTile(
                      expense: expense,
                      category: category,
                      onDelete: expense.id == null
                          ? null
                          : () async {
                              await onDeleteExpense(expense.id!);
                            },
                    ),
                  ),
                );
              }, childCount: expenses.length * 2 - 1),
            ),
          ),
        ],
      ),
    );
  }

  DateTime _latestDate(List<Expense> expenses) {
    return expenses
        .map((expense) => expense.date)
        .reduce((latest, date) => date.isAfter(latest) ? date : latest);
  }
}

class _HistorySummaryCard extends StatelessWidget {
  const _HistorySummaryCard({
    required this.totalAmount,
    required this.averageAmount,
    required this.expenseCount,
    required this.latestDate,
    required this.activeCategoryCount,
  });

  final double totalAmount;
  final double averageAmount;
  final int expenseCount;
  final DateTime latestDate;
  final int activeCategoryCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF123B34), Color(0xFF11695C), Color(0xFF23A58F)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF11695C).withValues(alpha: 0.24),
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.16),
                  ),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'إجمالي المصروفات',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.78),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        CurrencyFormatter.format(totalAmount),
                        style: theme.textTheme.displaySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          height: 1,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 560;
              final metricWidth = isWide
                  ? (constraints.maxWidth - 12) / 2
                  : constraints.maxWidth;

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: metricWidth,
                    child: _SummaryMetric(
                      icon: Icons.stacked_bar_chart_rounded,
                      label: 'عدد العمليات',
                      value: '$expenseCount',
                    ),
                  ),
                  SizedBox(
                    width: metricWidth,
                    child: _SummaryMetric(
                      icon: Icons.speed_rounded,
                      label: 'متوسط العملية',
                      value: CurrencyFormatter.format(averageAmount),
                    ),
                  ),
                  SizedBox(
                    width: metricWidth,
                    child: _SummaryMetric(
                      icon: Icons.event_available_rounded,
                      label: 'آخر عملية',
                      value: _formatDate(latestDate),
                    ),
                  ),
                  SizedBox(
                    width: metricWidth,
                    child: _SummaryMetric(
                      icon: Icons.category_rounded,
                      label: 'الفئات النشطة',
                      value: _categoryCountLabel(activeCategoryCount),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  String _categoryCountLabel(int count) {
    if (count == 1) return 'فئة واحدة';
    if (count == 2) return 'فئتان';
    return '$count فئات';
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      constraints: const BoxConstraints(minHeight: 72),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.74),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
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

class _HistorySectionHeader extends StatelessWidget {
  const _HistorySectionHeader({required this.expenseCount});

  final int expenseCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE1EEEA)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F4F1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.format_list_bulleted_rounded,
              color: Color(0xFF11695C),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'كل العمليات',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF143A34),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'مرتبة بنفس ترتيب السجل الحالي',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF6B7B76),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F4F1),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '$expenseCount',
              style: theme.textTheme.labelLarge?.copyWith(
                color: const Color(0xFF11695C),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpenseHistoryTile extends StatelessWidget {
  const _ExpenseHistoryTile({
    required this.expense,
    required this.category,
    required this.onDelete,
  });

  final Expense expense;
  final Category category;
  final Future<void> Function()? onDelete;

  @override
  Widget build(BuildContext context) {
    final style = _categoryStyle(expense.categoryId);
    final note = expense.note?.trim();
    final title = note == null || note.isEmpty ? 'بدون ملاحظة' : note;
    final amount = CurrencyFormatter.format(expense.amount);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFE1EEEA)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 520;

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    _CategoryAvatar(style: style),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ExpenseTileText(
                        title: title,
                        categoryName: category.name,
                        date: _formatDate(expense.date),
                        style: style,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(height: 1, color: Color(0xFFE6F0ED)),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _AmountPill(amount: amount),
                    const Spacer(),
                    _DeleteExpenseButton(onPressed: onDelete),
                  ],
                ),
              ],
            );
          }

          return Row(
            children: [
              _CategoryAvatar(style: style),
              const SizedBox(width: 14),
              Expanded(
                child: _ExpenseTileText(
                  title: title,
                  categoryName: category.name,
                  date: _formatDate(expense.date),
                  style: style,
                ),
              ),
              const SizedBox(width: 16),
              _AmountPill(amount: amount),
              const SizedBox(width: 8),
              _DeleteExpenseButton(onPressed: onDelete),
            ],
          );
        },
      ),
    );
  }
}

class _CategoryAvatar extends StatelessWidget {
  const _CategoryAvatar({required this.style});

  final _CategoryVisualStyle style;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: style.gradient,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: style.foreground.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(style.icon, color: Colors.white, size: 26),
    );
  }
}

class _ExpenseTileText extends StatelessWidget {
  const _ExpenseTileText({
    required this.title,
    required this.categoryName,
    required this.date,
    required this.style,
  });

  final String title;
  final String categoryName;
  final String date;
  final _CategoryVisualStyle style;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium?.copyWith(
            color: const Color(0xFF143A34),
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _ExpenseMetaChip(
              icon: Icons.local_offer_outlined,
              label: categoryName,
              iconColor: style.foreground,
              backgroundColor: style.background,
            ),
            _ExpenseMetaChip(
              icon: Icons.calendar_today_outlined,
              label: date,
              iconColor: const Color(0xFF6D7C77),
              backgroundColor: const Color(0xFFF5FAF8),
            ),
          ],
        ),
      ],
    );
  }
}

class _AmountPill extends StatelessWidget {
  const _AmountPill({required this.amount});

  final String amount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 108, maxWidth: 154),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FAF7),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFD8EDE7)),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            amount,
            maxLines: 1,
            style: theme.textTheme.titleSmall?.copyWith(
              color: const Color(0xFF0F6A5D),
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
        ),
      ),
    );
  }
}

class _DeleteExpenseButton extends StatelessWidget {
  const _DeleteExpenseButton({required this.onPressed});

  final Future<void> Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'حذف المصروف',
      child: SizedBox(
        width: 44,
        height: 44,
        child: IconButton(
          onPressed: onPressed == null
              ? null
              : () async {
                  await onPressed!();
                },
          icon: const Icon(Icons.delete_outline_rounded, size: 22),
          style: IconButton.styleFrom(
            backgroundColor: const Color(0xFFFFF2F0),
            disabledBackgroundColor: const Color(0xFFF4F4F4),
            foregroundColor: const Color(0xFFD84A3A),
            disabledForegroundColor: const Color(0xFFB7C3BF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}

class _ExpenseMetaChip extends StatelessWidget {
  const _ExpenseMetaChip({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.backgroundColor,
  });

  final IconData icon;
  final String label;
  final Color iconColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE3EFEC)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFF5F716C),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryLoadingView extends StatelessWidget {
  const _HistoryLoadingView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: _StatePanel(
          icon: Icons.hourglass_top_rounded,
          iconColor: const Color(0xFF11695C),
          title: 'جار تحميل السجل',
          message: 'لحظات قليلة ويتم عرض مصروفاتك المسجلة.',
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: const Color(0xFF11695C),
                backgroundColor: const Color(0xFFE2EEEA),
                semanticsLabel: 'تحميل',
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HistoryEmptyView extends StatelessWidget {
  const _HistoryEmptyView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: _StatePanel(
          icon: Icons.inbox_outlined,
          iconColor: Color(0xFF11695C),
          title: 'لا توجد مصروفات حتى الآن',
          message: 'بعد إضافة أول مصروف سيظهر هنا سجل مرتب وواضح لكل عملياتك.',
        ),
      ),
    );
  }
}

class _StatePanel extends StatelessWidget {
  const _StatePanel({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
    this.child,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Container(
        padding: const EdgeInsets.all(26),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFFE1EEEA)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 22,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(icon, color: iconColor, size: 34),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                color: const Color(0xFF143A34),
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF667771),
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
            ?child,
          ],
        ),
      ),
    );
  }
}

class _CategoryVisualStyle {
  const _CategoryVisualStyle({
    required this.icon,
    required this.gradient,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final List<Color> gradient;
  final Color background;
  final Color foreground;
}

_CategoryVisualStyle _categoryStyle(int? categoryId) {
  switch (categoryId) {
    case 1:
      return const _CategoryVisualStyle(
        icon: Icons.restaurant_rounded,
        gradient: [Color(0xFFFF7A59), Color(0xFFFFB59F)],
        background: Color(0xFFFFF2EE),
        foreground: Color(0xFFD65A3D),
      );
    case 2:
      return const _CategoryVisualStyle(
        icon: Icons.directions_bus_rounded,
        gradient: [Color(0xFF2878E3), Color(0xFF7AB6FF)],
        background: Color(0xFFEFF6FF),
        foreground: Color(0xFF246BC7),
      );
    case 3:
      return const _CategoryVisualStyle(
        icon: Icons.movie_filter_rounded,
        gradient: [Color(0xFF8E58E8), Color(0xFFBF9BFF)],
        background: Color(0xFFF5F0FF),
        foreground: Color(0xFF7443CC),
      );
    case 4:
      return const _CategoryVisualStyle(
        icon: Icons.shopping_bag_rounded,
        gradient: [Color(0xFFD9931E), Color(0xFFFFC75F)],
        background: Color(0xFFFFF7E7),
        foreground: Color(0xFFB87313),
      );
    default:
      return const _CategoryVisualStyle(
        icon: Icons.auto_awesome_rounded,
        gradient: [Color(0xFF11695C), Color(0xFF51A596)],
        background: Color(0xFFEAF7F4),
        foreground: Color(0xFF11695C),
      );
  }
}

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}
