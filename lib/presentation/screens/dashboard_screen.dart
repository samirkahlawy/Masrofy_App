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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF4FAF8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        titleSpacing: 24,
        toolbarHeight: 75,
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: _TopActionButton(
              icon: Icons.history_rounded,
              tooltip: 'السجل',
              onPressed: () => Navigator.of(context).pushNamed('/history'),
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: _TopActionButton(
              icon: Icons.settings_outlined,
              tooltip: 'الإعدادات',
              onPressed: () => Navigator.of(context).pushNamed('/settings'),
            ),
          ),
        ],
        title: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'لوحة التحكم',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF123B34),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'متابعة يومية واضحة لحركة مصروفاتك',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF667771),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
            Positioned(
              top: -110,
              right: -40,
              child: _BackgroundGlow(
                size: 260,
                colors: [
                  colorScheme.primary.withValues(alpha: 0.18),
                  colorScheme.primary.withValues(alpha: 0.02),
                ],
              ),
            ),
            Positioned(
              bottom: -150,
              left: -60,
              child: _BackgroundGlow(
                size: 320,
                colors: [
                  colorScheme.tertiary.withValues(alpha: 0.14),
                  colorScheme.tertiary.withValues(alpha: 0.01),
                ],
              ),
            ),
            Consumer2<BudgetProvider, ExpenseProvider>(
              builder: (context, budgetProvider, expenseProvider, _) {
                if (budgetProvider.currentBudgetCycle == null) {
                  return _buildEmptyState(theme);
                }

                final cycle = budgetProvider.currentBudgetCycle!;
                final dailyLimit = cycle.calculateDailyLimit();
                final totalExpenses = expenseProvider.expenses.fold(
                  0.0,
                  (sum, expense) => sum + expense.amount,
                );
                final todayExpenses = expenseProvider.expenses.where((expense) {
                  final now = DateTime.now();
                  return expense.date.year == now.year &&
                      expense.date.month == now.month &&
                      expense.date.day == now.day;
                }).toList();
                final safeLimit = budgetProvider.calculateSafeDailyLimit(
                  todayExpenses,
                );

                final mockCategories = [
                  Category(id: 1, name: 'طعام'),
                  Category(id: 2, name: 'مواصلات'),
                  Category(id: 3, name: 'ترفيه'),
                  Category(id: 4, name: 'أخرى'),
                ];

                final expensesByCategory = <int, double>{};
                for (final expense in expenseProvider.expenses) {
                  if (expense.categoryId != null) {
                    expensesByCategory[expense.categoryId!] =
                        (expensesByCategory[expense.categoryId!] ?? 0) +
                        expense.amount;
                  }
                }

                final categoryNames = <int, String>{
                  for (final category in mockCategories)
                    if (category.id != null) category.id!: category.name,
                };
                final todayTotal = todayExpenses.fold<double>(
                  0.0,
                  (sum, expense) => sum + expense.amount,
                );
                final spendingProgress = cycle.totalAllowance > 0
                    ? (totalExpenses / cycle.totalAllowance).clamp(0.0, 1.0)
                    : 0.0;
                final recentExpenses = expenseProvider.expenses
                    .take(4)
                    .toList();

                return RefreshIndicator(
                  color: const Color(0xFF11695C),
                  backgroundColor: Colors.white,
                  onRefresh: () async {
                    await budgetProvider.refresh();
                    await expenseProvider.init();
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 920),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildHeroCard(
                              theme: theme,
                              remainingBudget: budgetProvider.remainingBudget,
                              dailyLimit: dailyLimit,
                              todayTotal: todayTotal,
                              expenseCount: expenseProvider.expenses.length,
                            ),
                            const SizedBox(height: 22),
                            SafeLimitCard(
                              totalExpenses: totalExpenses,
                              monthlyBudget: cycle.totalAllowance,
                              safeLimit: safeLimit,
                            ),
                            const SizedBox(height: 22),
                            _SectionCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const _SectionHeader(
                                    icon: Icons.calendar_month_rounded,
                                    title: 'تفاصيل الدورة',
                                    subtitle:
                                        'نظرة مركزة على فترة الميزانية الحالية وحالة الإنفاق.',
                                  ),
                                  const SizedBox(height: 20),
                                  Container(
                                    padding: const EdgeInsets.all(18),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF7FBFA),
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                        color: const Color(0xFFE2EEEA),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              'نسبة استخدام الميزانية',
                                              style: theme.textTheme.titleMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w800,
                                                    color: const Color(
                                                      0xFF173B35,
                                                    ),
                                                  ),
                                            ),
                                            const Spacer(),
                                            Text(
                                              '${(spendingProgress * 100).toStringAsFixed(1)}%',
                                              style: theme.textTheme.titleMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w900,
                                                    color: const Color(
                                                      0xFF11695C,
                                                    ),
                                                  ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 14),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                          child: LinearProgressIndicator(
                                            value: spendingProgress,
                                            minHeight: 10,
                                            backgroundColor: const Color(
                                              0xFFE3EFEB,
                                            ),
                                            valueColor:
                                                const AlwaysStoppedAnimation(
                                                  Color(0xFF11695C),
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      final isWide = constraints.maxWidth > 560;
                                      final itemWidth = isWide
                                          ? (constraints.maxWidth - 12) / 2
                                          : constraints.maxWidth;

                                      return Wrap(
                                        spacing: 12,
                                        runSpacing: 12,
                                        children: [
                                          SizedBox(
                                            width: itemWidth,
                                            child: _DetailMetricTile(
                                              icon: Icons.play_circle_outline,
                                              label: 'بداية الدورة',
                                              value: _formatDate(
                                                cycle.startDate,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: itemWidth,
                                            child: _DetailMetricTile(
                                              icon: Icons.flag_outlined,
                                              label: 'نهاية الدورة',
                                              value: _formatDate(cycle.endDate),
                                            ),
                                          ),
                                          SizedBox(
                                            width: itemWidth,
                                            child: _DetailMetricTile(
                                              icon: Icons.today_outlined,
                                              label: 'الحد اليومي',
                                              value: CurrencyFormatter.format(
                                                dailyLimit,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: itemWidth,
                                            child: _DetailMetricTile(
                                              icon: Icons
                                                  .account_balance_wallet_outlined,
                                              label: 'المتبقي',
                                              value: CurrencyFormatter.format(
                                                budgetProvider.remainingBudget,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 22),
                            _SectionCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const _SectionHeader(
                                    icon: Icons.pie_chart_rounded,
                                    title: 'مصروفات حسب الفئة',
                                    subtitle:
                                        'تعرف على أكثر الفئات استهلاكًا من خلال توزيع بصري واضح.',
                                  ),
                                  const SizedBox(height: 18),
                                  ExpensePieChart(
                                    expensesByCategory: expensesByCategory,
                                    categories: mockCategories,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 22),
                            _SectionCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const _SectionHeader(
                                    icon: Icons.receipt_long_rounded,
                                    title: 'أحدث المصروفات',
                                    subtitle:
                                        'آخر الحركات المسجلة لتبقى الصورة الكاملة أمامك دائمًا.',
                                  ),
                                  const SizedBox(height: 18),
                                  if (recentExpenses.isEmpty)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 28,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8FBFA),
                                        borderRadius: BorderRadius.circular(18),
                                        border: Border.all(
                                          color: const Color(0xFFE3EFEB),
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Container(
                                            width: 62,
                                            height: 62,
                                            decoration: const BoxDecoration(
                                              color: Color(0xFFE7F3F0),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.inbox_outlined,
                                              color: Color(0xFF2A7C6C),
                                              size: 30,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'لا توجد مصروفات حتى الآن',
                                            textAlign: TextAlign.center,
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w800,
                                                  color: const Color(
                                                    0xFF173A34,
                                                  ),
                                                ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'ابدأ بإضافة أول مصروف لتظهر الحركة المالية هنا بشكل منظم.',
                                            textAlign: TextAlign.center,
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                                  color: const Color(
                                                    0xFF687873,
                                                  ),
                                                  height: 1.5,
                                                ),
                                          ),
                                        ],
                                      ),
                                    )
                                  else
                                    Column(
                                      children: [
                                        for (
                                          var i = 0;
                                          i < recentExpenses.length;
                                          i++
                                        ) ...[
                                          _buildExpenseTile(
                                            context,
                                            recentExpenses[i],
                                            categoryName:
                                                categoryNames[recentExpenses[i]
                                                    .categoryId] ??
                                                'أخرى',
                                          ),
                                          if (i != recentExpenses.length - 1)
                                            const SizedBox(height: 12),
                                        ],
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).pushNamed('/add-expense'),
        backgroundColor: const Color(0xFF11695C),
        foregroundColor: Colors.white,
        elevation: 10,
        extendedPadding: const EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        icon: const Icon(Icons.add_rounded),
        label: Text(
          'إضافة مصروف',
          style: theme.textTheme.titleSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard({
    required ThemeData theme,
    required double remainingBudget,
    required double dailyLimit,
    required double todayTotal,
    required int expenseCount,
  }) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF0E5A4D), Color(0xFF17806F)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF11695C).withValues(alpha: 0.24),
            blurRadius: 30,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'رؤية أوضح لمصروفاتك',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'تابع ما أنفقته اليوم، وما تبقى من ميزانيتك، واتخذ قراراتك المالية بثقة.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.90),
                        height: 1.55,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.18),
                  ),
                ),
                child: const Icon(
                  Icons.insights_sharp,
                  color: Colors.white,
                  size: 34,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _HeroStatChip(
                label: 'المتبقي',
                value: CurrencyFormatter.format(remainingBudget),
                icon: Icons.account_balance_wallet_outlined,
              ),
              _HeroStatChip(
                label: 'الحد اليومي',
                value: CurrencyFormatter.format(dailyLimit),
                icon: Icons.calendar_today_outlined,
              ),
              _HeroStatChip(
                label: 'مصروف اليوم',
                value: CurrencyFormatter.format(todayTotal),
                icon: Icons.payments_outlined,
              ),
              _HeroStatChip(
                label: 'عدد العمليات',
                value: '$expenseCount',
                icon: Icons.receipt_long_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE1EEEA)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 78,
                  height: 78,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [Color(0xFF11695C), Color(0xFF51A596)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.calendar_month_rounded,
                    color: Colors.white,
                    size: 38,
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  'لم يتم إعداد دورة بعد',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF133A33),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'الرجاء العودة إلى شاشة الإعداد لإنشاء دورة مالية حتى تبدأ لوحة التحكم في عرض بياناتك.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF647570),
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpenseTile(
    BuildContext context,
    Expense expense, {
    required String categoryName,
  }) {
    final theme = Theme.of(context);
    final note = expense.note?.trim();
    final expenseTitle = note == null || note.isEmpty ? 'بدون ملاحظة' : note;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFA),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2EEEA)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFE6F3F0),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              _categoryIcon(expense.categoryId),
              color: const Color(0xFF11695C),
              size: 26,
            ),
          ),
          const SizedBox(width: 14), 
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expenseTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF153B35),
                    fontWeight: FontWeight.w800,
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
                    ),
                    _ExpenseMetaChip(
                      icon: Icons.calendar_today_outlined,
                      label: _formatDate(expense.date),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 5), // SizeBox should be 5 not 12 to fix Over Flow 
          Text(
            CurrencyFormatter.format(expense.amount),
            style: theme.textTheme.titleMedium?.copyWith(
              color: const Color(0xFF0F6A5D),
              fontWeight: FontWeight.w900,
            ),
            textAlign: TextAlign.end,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  IconData _categoryIcon(int? categoryId) {
    switch (categoryId) {
      case 1:
        return Icons.restaurant_outlined;
      case 2:
        return Icons.directions_bus_outlined;
      case 3:
        return Icons.movie_outlined;
      default:
        return Icons.category_outlined;
    }
  }
}

class _TopActionButton extends StatelessWidget {
  const _TopActionButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE1EEEA)),
      ),
      child: IconButton(
        onPressed: onPressed,
        tooltip: tooltip,
        icon: Icon(icon, color: const Color(0xFF145147)),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE1EEEA)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
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
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F4F1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: const Color(0xFF11695C)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF143A34),
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF667771),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailMetricTile extends StatelessWidget {
  const _DetailMetricTile({
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FCFB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE4EFEC)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F4F1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: const Color(0xFF11695C), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF6C7D78),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF163B35),
                    fontWeight: FontWeight.w800,
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

class _HeroStatChip extends StatelessWidget {
  const _HeroStatChip({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      constraints: const BoxConstraints(minWidth: 100),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.82),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExpenseMetaChip extends StatelessWidget {
  const _ExpenseMetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE2EEEA)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF6A7B76)),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFF5F716C),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _BackgroundGlow extends StatelessWidget {
  const _BackgroundGlow({required this.size, required this.colors});

  final double size;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: colors),
        ),
      ),
    );
  }
}
