import 'dart:developer' as developer;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../logic/auth_provider.dart';
import '../../logic/budget_provider.dart';

class SetupCycleScreen extends StatefulWidget {
  const SetupCycleScreen({super.key});

  @override
  State<SetupCycleScreen> createState() => _SetupCycleScreenState();
}

class _SetupCycleScreenState extends State<SetupCycleScreen> {
  final TextEditingController _amountController = TextEditingController();
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  bool _isLoading = false;
  String? _errorMessage;

  int get _cycleDays => _endDate.difference(_startDate).inDays + 1;

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      helpText: 'اختر تاريخ البدء',
      cancelText: 'إلغاء',
      confirmText: 'تأكيد',
      builder: _buildDatePickerTheme,
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
        // If end date is before start date, update it
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate.add(const Duration(days: 30));
        }
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime(2030),
      helpText: 'اختر تاريخ الانتهاء',
      cancelText: 'إلغاء',
      confirmText: 'تأكيد',
      builder: _buildDatePickerTheme,
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Widget _buildDatePickerTheme(BuildContext context, Widget? child) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Theme(
        data: theme.copyWith(
          colorScheme: theme.colorScheme.copyWith(
            primary: const Color(0xFF11695C),
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: const Color(0xFF173B35),
          ),
          datePickerTheme: const DatePickerThemeData(
            backgroundColor: Colors.white,
            headerBackgroundColor: Color(0xFF11695C),
            headerForegroundColor: Colors.white,
          ),
        ),
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  Future<void> _onConfirmSetup() async {
    developer.log(
      'SetupCycleScreen: _onConfirmSetup started',
      name: 'SetupCycle',
    );

    final amount =
        double.tryParse(_amountController.text.replaceAll(',', '.')) ?? 0;
    if (amount <= 0) {
      setState(() {
        _errorMessage = 'أدخل مبلغ ميزانية صالحًا.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final navigator = Navigator.of(context);
    final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();

    developer.log(
      'SetupCycleScreen: Setting isFirstTime to false',
      name: 'SetupCycle',
    );
    await prefs.setBool('isFirstTime', false);

    // Set up PIN for user
    developer.log('SetupCycleScreen: Calling setPIN', name: 'SetupCycle');
    await authProvider.setPIN('1234');
    developer.log('SetupCycleScreen: setPIN completed', name: 'SetupCycle');

    // Start new budget cycle with selected dates
    developer.log('SetupCycleScreen: Starting new cycle', name: 'SetupCycle');
    await budgetProvider.startNewCycle(amount, _startDate, _endDate);

    developer.log(
      'SetupCycleScreen: All setup completed, navigating to dashboard',
      name: 'SetupCycle',
    );
    if (!mounted) return;
    navigator.pushReplacementNamed('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'إعداد دورة المصروفات',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF123B34),
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'جهز ميزانيتك الأولى بصورة مرتبة وواضحة',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF667771),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _SetupHeroCard(
                      cycleDays: _cycleDays,
                      startDate: _formatDate(_startDate),
                      endDate: _formatDate(_endDate),
                    ),
                    const SizedBox(height: 18),
                    _SetupFormPanel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _PanelHeader(
                            icon: Icons.tune_rounded,
                            title: 'تفاصيل الدورة',
                            subtitle:
                                'حدد قيمة الميزانية وفترة المتابعة قبل الانتقال للوحة التحكم.',
                          ),
                          const SizedBox(height: 22),
                          _AmountField(controller: _amountController),
                          const SizedBox(height: 20),
                          _DateRangeSelector(
                            startDate: _formatDate(_startDate),
                            endDate: _formatDate(_endDate),
                            cycleDays: _cycleDays,
                            onStartTap: () => _selectStartDate(context),
                            onEndTap: () => _selectEndDate(context),
                          ),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            child: _errorMessage == null
                                ? const SizedBox(height: 24)
                                : Padding(
                                    key: ValueKey(_errorMessage),
                                    padding: const EdgeInsets.only(
                                      top: 20,
                                      bottom: 16,
                                    ),
                                    child: _ErrorBanner(
                                      message: _errorMessage!,
                                    ),
                                  ),
                          ),
                          _SetupButton(
                            isLoading: _isLoading,
                            onPressed: _isLoading ? null : _onConfirmSetup,
                          ),
                          const SizedBox(height: 16),
                          const _PinInfo(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SetupHeroCard extends StatelessWidget {
  const _SetupHeroCard({
    required this.cycleDays,
    required this.startDate,
    required this.endDate,
  });

  final int cycleDays;
  final String startDate;
  final String endDate;

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
          colors: [Color(0xFF123B34), Color(0xFF11695C), Color(0xFF1FA48E)],
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
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.18),
                  ),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ابدأ دورة مالية واضحة',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'كل شيء يبدأ من رقم مضبوط وفترة محددة بعناية.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.82),
                        fontWeight: FontWeight.w600,
                        height: 1.55,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _HeroMetricChip(
                icon: Icons.calendar_today_rounded,
                label: 'تبدأ',
                value: startDate,
              ),
              _HeroMetricChip(
                icon: Icons.flag_rounded,
                label: 'تنتهي',
                value: endDate,
              ),
              _HeroMetricChip(
                icon: Icons.timelapse_rounded,
                label: 'المدة',
                value: '$cycleDays يوم',
                isAccent: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroMetricChip extends StatelessWidget {
  const _HeroMetricChip({
    required this.icon,
    required this.label,
    required this.value,
    this.isAccent = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isAccent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = isAccent
        ? const Color(0xFFFFC857).withValues(alpha: 0.18)
        : Colors.white.withValues(alpha: 0.12);
    final borderColor = isAccent
        ? const Color(0xFFFFC857).withValues(alpha: 0.32)
        : Colors.white.withValues(alpha: 0.16);

    return Container(
      constraints: const BoxConstraints(minWidth: 132),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isAccent ? const Color(0xFFFFD56F) : Colors.white,
            size: 18,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.72),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: theme.textTheme.labelLarge?.copyWith(
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

class _SetupFormPanel extends StatelessWidget {
  const _SetupFormPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFE1EEEA)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 26,
            offset: const Offset(0, 16),
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
            color: const Color(0xFFE8F4F1),
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

class _AmountField extends StatelessWidget {
  const _AmountField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: theme.textTheme.titleMedium?.copyWith(
        color: const Color(0xFF163A34),
        fontWeight: FontWeight.w900,
      ),
      decoration: InputDecoration(
        labelText: 'المبلغ الإجمالي',
        hintText: 'مثال: 15000',
        prefixText: '£ ',
        prefixStyle: theme.textTheme.titleMedium?.copyWith(
          color: const Color(0xFF11695C),
          fontWeight: FontWeight.w900,
        ),
        prefixIcon: const Padding(
          padding: EdgeInsetsDirectional.only(start: 14, end: 10),
          child: Icon(Icons.payments_rounded, color: Color(0xFF11695C)),
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
      ),
    );
  }
}

class _DateRangeSelector extends StatelessWidget {
  const _DateRangeSelector({
    required this.startDate,
    required this.endDate,
    required this.cycleDays,
    required this.onStartTap,
    required this.onEndTap,
  });

  final String startDate;
  final String endDate;
  final int cycleDays;
  final VoidCallback onStartTap;
  final VoidCallback onEndTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFA),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2EEEA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F4F1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.date_range_rounded,
                  color: Color(0xFF11695C),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'فترة الميزانية',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF173B35),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _CycleBadge(days: cycleDays),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 500;

              if (isNarrow) {
                return Column(
                  children: [
                    _DateChoice(
                      label: 'من',
                      value: startDate,
                      icon: Icons.play_circle_outline_rounded,
                      onTap: onStartTap,
                    ),
                    const SizedBox(height: 10),
                    const _DateConnector(isVertical: true),
                    const SizedBox(height: 10),
                    _DateChoice(
                      label: 'إلى',
                      value: endDate,
                      icon: Icons.flag_outlined,
                      onTap: onEndTap,
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: _DateChoice(
                      label: 'من',
                      value: startDate,
                      icon: Icons.play_circle_outline_rounded,
                      onTap: onStartTap,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const _DateConnector(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DateChoice(
                      label: 'إلى',
                      value: endDate,
                      icon: Icons.flag_outlined,
                      onTap: onEndTap,
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
}

class _CycleBadge extends StatelessWidget {
  const _CycleBadge({required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6DD),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFFFE4A0)),
      ),
      child: Text(
        '$days يوم',
        style: theme.textTheme.labelMedium?.copyWith(
          color: const Color(0xFF9A6600),
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _DateChoice extends StatelessWidget {
  const _DateChoice({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE1EEEA)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F4F1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: const Color(0xFF11695C), size: 21),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF6C7D77),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    value,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF173B35),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.edit_calendar_rounded,
              color: Color(0xFF78908A),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _DateConnector extends StatelessWidget {
  const _DateConnector({this.isVertical = false});

  final bool isVertical;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isVertical ? 44 : 42,
      height: isVertical ? 34 : 42,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F4F1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD5E8E3)),
      ),
      child: Icon(
        isVertical
            ? Icons.keyboard_arrow_down_rounded
            : Icons.arrow_back_rounded,
        color: const Color(0xFF11695C),
        size: 22,
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

class _SetupButton extends StatelessWidget {
  const _SetupButton({required this.isLoading, required this.onPressed});

  final bool isLoading;
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
          child: isLoading
              ? const SizedBox(
                  key: ValueKey('loading'),
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: Colors.white,
                  ),
                )
              : Row(
                  key: const ValueKey('confirm'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_rounded, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'تأكيد الإعداد',
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

class _PinInfo extends StatelessWidget {
  const _PinInfo();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FBFA),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2EEEA)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F4F1),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.lock_outline_rounded,
              color: Color(0xFF11695C),
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'سيتم استخدام PIN افتراضي 1234 لتسجيل الدخول لاحقًا.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: const Color(0xFF667771),
                fontWeight: FontWeight.w700,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
