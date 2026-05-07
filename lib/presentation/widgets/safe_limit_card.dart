import 'package:flutter/material.dart';

import '../../core/utils/currency_formatter.dart';

/// A card widget that displays a "Safe Spend Limit" indicator, 
/// comparing total expenses against a budget and safe limit.
class SafeLimitCard extends StatelessWidget {
  /// The total amount spent so far in the current cycle.
  final double totalExpenses;

  /// The total budget allocated for the month/cycle.
  final double monthlyBudget;

  /// The calculated daily safe limit.
  final double safeLimit;

  /// Creates a [SafeLimitCard].
  const SafeLimitCard({
    super.key,
    required this.totalExpenses,
    required this.monthlyBudget,
    required this.safeLimit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percentage = monthlyBudget > 0
        ? (totalExpenses / monthlyBudget).clamp(0.0, 1.0)
        : 0.0;
    final isOverSafe = totalExpenses > safeLimit;
    final isOverBudget = totalExpenses > monthlyBudget;

    final palette = _resolvePalette(
      isOverSafe: isOverSafe,
      isOverBudget: isOverBudget,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            palette.tint,
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: palette.border,
          width: 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: palette.shadow,
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مؤشر الحد الآمن',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF153E37),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ملخص سريع يوضح موقف إنفاقك الحالي مقارنة بالميزانية والحد اليومي الآمن.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF62746F),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: palette.badgeBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  palette.icon,
                  color: palette.accent,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          // Metric Cards Grid
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _LimitMetricCard(
                label: 'إجمالي المصروفات',
                value: CurrencyFormatter.format(totalExpenses),
              ),
              _LimitMetricCard(
                label: 'الحد الآمن',
                value: CurrencyFormatter.format(safeLimit),
              ),
              _LimitMetricCard(
                label: 'الميزانية الكلية',
                value: CurrencyFormatter.format(monthlyBudget),
              ),
            ],
          ),
          const SizedBox(height: 22),
          // Progress Section
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.82),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: palette.border.withValues(alpha: 0.9),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: palette.badgeBackground,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        palette.statusText,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: palette.accent,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${(percentage * 100).toStringAsFixed(1)}%',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF173C36),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: percentage,
                    minHeight: 12,
                    backgroundColor: const Color(0xFFE6EFEC),
                    valueColor: AlwaysStoppedAnimation<Color>(palette.accent),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'نسبة الاستخدام الحالية من إجمالي ميزانية الدورة.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF667771),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Determines the visual style (colors, icon, text) based on spending status.
  _LimitPalette _resolvePalette({
    required bool isOverSafe,
    required bool isOverBudget,
  }) {
    if (isOverBudget) {
      return const _LimitPalette(
        accent: Color(0xFFC14343),
        tint: Color(0xFFFFF1F1),
        border: Color(0xFFF1D1D1),
        badgeBackground: Color(0xFFFFE0E0),
        shadow: Color(0x1AC14343),
        icon: Icons.warning_amber_rounded,
        statusText: 'تجاوزت الميزانية',
      );
    }

    if (isOverSafe) {
      return const _LimitPalette(
        accent: Color(0xFFC9821F),
        tint: Color(0xFFFFF7EC),
        border: Color(0xFFF4DFC0),
        badgeBackground: Color(0xFFFFEDCC),
        shadow: Color(0x1AC9821F),
        icon: Icons.trending_up_rounded,
        statusText: 'اقتربت من الحد الآمن',
      );
    }

    return const _LimitPalette(
      accent: Color(0xFF1D8C63),
      tint: Color(0xFFEFFBF5),
      border: Color(0xFFD3EDDE),
      badgeBackground: Color(0xFFDDF6E8),
      shadow: Color(0x1A1D8C63),
      icon: Icons.verified_rounded,
      statusText: 'ضمن الحدود الآمنة',
    );
  }
}

/// A private internal helper widget for individual metric labels and values.
class _LimitMetricCard extends StatelessWidget {
  const _LimitMetricCard({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      constraints: const BoxConstraints(minWidth: 120),
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE0ECE8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFF6A7B76),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              color: const Color(0xFF143B34),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

/// A data class containing the color palette and assets for a spending status.
class _LimitPalette {
  const _LimitPalette({
    required this.accent,
    required this.tint,
    required this.border,
    required this.badgeBackground,
    required this.shadow,
    required this.icon,
    required this.statusText,
  });

  final Color accent;
  final Color tint;
  final Color border;
  final Color badgeBackground;
  final Color shadow;
  final IconData icon;
  final String statusText;
}