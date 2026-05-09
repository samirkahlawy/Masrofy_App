import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../logic/budget_provider.dart';
import '../../logic/expense_provider.dart';
import '../../logic/auth_provider.dart';

/// A screen for managing application settings, including PIN changes and data resets.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  /// Displays a dialog to allow the user to change their access PIN.
  Future<void> _showChangePINDialog(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final oldPinController = TextEditingController();
    final newPinController = TextEditingController();
    final confirmPinController = TextEditingController();
    String? errorMessage;

    try {
      return await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: StatefulBuilder(
              builder: (context, setState) {
                final theme = Theme.of(context);

                return Dialog(
                  insetPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  backgroundColor: Colors.transparent,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: _DialogSurface(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _DialogIcon(
                                icon: Icons.lock_reset_rounded,
                                color: _AppColors.primary,
                                backgroundColor: _AppColors.primarySoft,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'تغيير رمز PIN',
                                      style: theme.textTheme.titleLarge
                                          ?.copyWith(
                                            color: _AppColors.ink,
                                            fontWeight: FontWeight.w900,
                                            height: 1.2,
                                          ),
                                    ),
                                    const SizedBox(height: 7),
                                    Text(
                                      'أدخل الرمز القديم ثم اختر رمزًا جديدًا لحماية حسابك.',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: _AppColors.muted,
                                            fontWeight: FontWeight.w600,
                                            height: 1.5,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          _PinField(
                            controller: oldPinController,
                            label: 'الرمز القديم',
                            icon: Icons.key_rounded,
                          ),
                          const SizedBox(height: 12),
                          _PinField(
                            controller: newPinController,
                            label: 'الرمز الجديد',
                            icon: Icons.password_rounded,
                          ),
                          const SizedBox(height: 12),
                          _PinField(
                            controller: confirmPinController,
                            label: 'تأكيد الرمز الجديد',
                            icon: Icons.verified_user_rounded,
                          ),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeInCubic,
                            child: errorMessage == null
                                ? const SizedBox(height: 22)
                                : Padding(
                                    key: ValueKey(errorMessage),
                                    padding: const EdgeInsets.only(top: 16),
                                    child: _InlineError(message: errorMessage!),
                                  ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () =>
                                      Navigator.of(dialogContext).pop(),
                                  style: _ButtonStyles.secondary,
                                  child: const Text('إلغاء'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    final oldPIN = oldPinController.text.trim();
                                    final newPIN = newPinController.text.trim();
                                    final confirmPIN = confirmPinController.text
                                        .trim();

                                    if (oldPIN.length < 4 ||
                                        newPIN.length < 4 ||
                                        confirmPIN.length < 4) {
                                      setState(() {
                                        errorMessage =
                                            'يجب إدخال 4 أرقام لكل حقل';
                                      });
                                      return;
                                    }

                                    if (newPIN != confirmPIN) {
                                      setState(() {
                                        errorMessage =
                                            'الرمز الجديد غير متطابق';
                                      });
                                      return;
                                    }

                                    final success = await authProvider
                                        .changePIN(oldPIN, newPIN);

                                    if (!dialogContext.mounted) return;

                                    if (success) {
                                      // Navigator.of(dialogContext).pop();
                                      
                                      ScaffoldMessenger.of(
                                        dialogContext,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('تم تغيير الرمز بنجاح'),
                                        ),
                                      );
                                      Navigator.of(dialogContext, rootNavigator: true).pop();
                                    } else {
                                      setState(() {
                                        errorMessage = 'الرمز القديم غير صحيح';
                                      });
                                    }
                                  },
                                  style: _ButtonStyles.primary,
                                  child: const Text('حفظ'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      );
    } finally {
      oldPinController.dispose();
      newPinController.dispose();
      confirmPinController.dispose();
    }
  }

  Future<void> _confirmReset(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);

        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            icon: const _DialogIcon(
              icon: Icons.warning_amber_rounded,
              color: _AppColors.danger,
              backgroundColor: _AppColors.dangerSoft,
            ),
            title: Text(
              'إعادة ضبط البيانات',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                color: const Color(0xFF321B18),
                fontWeight: FontWeight.w900,
              ),
            ),
            content: Text(
              'هل أنت متأكد أنك تريد حذف جميع البيانات؟',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: _AppColors.danger,
                fontWeight: FontWeight.w700,
                height: 1.5,
              ),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            actions: [
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: _ButtonStyles.secondary,
                child: const Text('لا'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: _ButtonStyles.danger,
                child: const Text('نعم'),
              ),
            ],
          ),
        );
      },
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);
    final expenseProvider = Provider.of<ExpenseProvider>(
      context,
      listen: false,
    );
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final navigator = Navigator.of(context);

    // Clear all data
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('expenses');
    await prefs.remove('budget_cycle');
    await prefs.remove('user');
    await prefs.setBool('isFirstTime', true);

    // Reset providers
    await budgetProvider.refresh();
    await expenseProvider.init();
    await authProvider.logout();

    if (!context.mounted) return;
    navigator.pushNamedAndRemoveUntil('/setup', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: _AppColors.canvas,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: _AppColors.canvas,
        foregroundColor: _AppColors.ink,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 20,
        elevation: 0,
        titleSpacing: 20,
        toolbarHeight: 65,
        title: Text(
          'الإعدادات',
          style: theme.textTheme.titleLarge?.copyWith(
            color: _AppColors.ink,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
            const Positioned.fill(child: _SettingsBackdrop()),
            SafeArea(
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
                        const _SecuritySummaryCard(),
                        const SizedBox(height: 16),
                        _SettingsSection(
                          title: 'إدارة الحساب',
                          subtitle:
                              'تحكم في الأمان والبيانات الأساسية من مكان واحد.',
                          children: [
                            _SettingsActionRow(
                              icon: Icons.lock_outline_rounded,
                              title: 'تغيير رمز PIN',
                              subtitle: 'تحديث رمز الدخول الحالي برمز جديد',
                              color: _AppColors.primary,
                              backgroundColor: _AppColors.primarySoft,
                              onTap: () => _showChangePINDialog(context),
                            ),
                            const _SettingsDivider(),
                            _SettingsActionRow(
                              icon: Icons.restart_alt_rounded,
                              title: 'إعادة ضبط البيانات',
                              subtitle: 'حذف المصروفات والدورات والبدء من جديد',
                              color: _AppColors.danger,
                              backgroundColor: _AppColors.dangerSoft,
                              onTap: () => _confirmReset(context),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const _TrustNoteCard(),
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

class _AppColors {
  const _AppColors._();

  static const canvas = Color(0xFFF6F8F6);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFF9FBFA);
  static const ink = Color(0xFF102E2A);
  static const muted = Color(0xFF65756F);
  static const faint = Color(0xFFE4ECE8);
  static const primary = Color(0xFF0D695C);
  static const primaryDark = Color(0xFF0F4039);
  static const primarySoft = Color(0xFFE7F4F1);
  static const amber = Color(0xFFB46B12);
  static const amberSoft = Color(0xFFFFF4DF);
  static const danger = Color(0xFFD23B35);
  static const dangerSoft = Color(0xFFFFEAE8);
}

class _ButtonStyles {
  const _ButtonStyles._();

  static final primary = ElevatedButton.styleFrom(
    backgroundColor: _AppColors.primary,
    foregroundColor: Colors.white,
    elevation: 0,
    padding: const EdgeInsets.symmetric(vertical: 15),
    textStyle: const TextStyle(fontWeight: FontWeight.w900),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
  );

  static final danger = ElevatedButton.styleFrom(
    backgroundColor: _AppColors.danger,
    foregroundColor: Colors.white,
    elevation: 0,
    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 13),
    textStyle: const TextStyle(fontWeight: FontWeight.w900),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
  );

  static final secondary = OutlinedButton.styleFrom(
    foregroundColor: const Color(0xFF52635E),
    side: const BorderSide(color: _AppColors.faint),
    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 13),
    textStyle: const TextStyle(fontWeight: FontWeight.w900),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
  );
}

class _SettingsBackdrop extends StatelessWidget {
  const _SettingsBackdrop();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEFF7F4), _AppColors.canvas, Color(0xFFFBFAF7)],
          ),
        ),
        child: CustomPaint(painter: _GridBackdropPainter()),
      ),
    );
  }
}

class _GridBackdropPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0D695C).withValues(alpha: 0.035)
      ..strokeWidth = 1;

    const step = 34.0;
    for (var x = 0.0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SecuritySummaryCard extends StatelessWidget {
  const _SecuritySummaryCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: _AppColors.primaryDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: _AppColors.primary.withValues(alpha: 0.22),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Stack(
        children: [
          const PositionedDirectional(top: 0, end: 0, child: _HeroPattern()),
          Column(
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
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.16),
                      ),
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'مركز أمان مصروفي',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'إدارة دقيقة للخصوصية والبيانات مع إجراءات واضحة وآمنة.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.80),
                            fontWeight: FontWeight.w700,
                            height: 1.55,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 520;
                  final itemWidth = isWide
                      ? (constraints.maxWidth - 10) / 2
                      : constraints.maxWidth;

                  return Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      SizedBox(
                        width: itemWidth,
                        child: const _HeroInfoPill(
                          icon: Icons.shield_outlined,
                          label: 'حماية الدخول',
                          value: 'PIN مفعل',
                        ),
                      ),
                      SizedBox(
                        width: itemWidth,
                        child: const _HeroInfoPill(
                          icon: Icons.verified_user_outlined,
                          label: 'وضع البيانات',
                          value: 'محلي وآمن',
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroPattern extends StatelessWidget {
  const _HeroPattern();

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.22,
      child: SizedBox(
        width: 118,
        height: 94,
        child: CustomPaint(painter: _HeroPatternPainter()),
      ),
    );
  }
}

class _HeroPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    for (var i = 0; i < 5; i++) {
      final inset = i * 12.0;
      final rect = Rect.fromLTWH(
        inset,
        inset,
        size.width - inset * 1.4,
        size.height - inset * 1.6,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(8)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HeroInfoPill extends StatelessWidget {
  const _HeroInfoPill({
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.70),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: theme.textTheme.titleSmall?.copyWith(
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

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: _AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _AppColors.faint),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.settings_suggest_rounded,
                    color: _AppColors.primary,
                    size: 23,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: _AppColors.ink,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: _AppColors.muted,
                          fontWeight: FontWeight.w600,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          //const Divider(height: 1, color: _AppColors.faint),
          ...children,
        ],
      ),
    );
  }
}

class _SettingsActionRow extends StatelessWidget {
  const _SettingsActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.backgroundColor,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color backgroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: color == _AppColors.danger
                            ? const Color(0xFF89211D)
                            : _AppColors.ink,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _AppColors.muted,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _ActionChevron(color: color),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionChevron extends StatelessWidget {
  const _ActionChevron({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: _AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _AppColors.faint),
      ),
      child: Icon(Icons.arrow_forward_ios_rounded, color: color, size: 14),
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  const _SettingsDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsetsDirectional.only(start: 80),
      child: Divider(height: 1, color: _AppColors.faint),
    );
  }
}

class _TrustNoteCard extends StatelessWidget {
  const _TrustNoteCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF0E3C9)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _AppColors.amberSoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              color: _AppColors.amber,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تنبيه مهم',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: const Color(0xFF5B3B10),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'إعادة ضبط البيانات إجراء نهائي، لذلك تأكد من احتياجك له قبل التأكيد.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF7A643E),
                    fontWeight: FontWeight.w600,
                    height: 1.45,
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

class _DialogSurface extends StatelessWidget {
  const _DialogSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _AppColors.faint),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 34,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _PinField extends StatelessWidget {
  const _PinField({
    required this.controller,
    required this.label,
    required this.icon,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      obscureText: true,
      maxLength: 4,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: _AppColors.ink,
        fontWeight: FontWeight.w800,
        letterSpacing: 3,
      ),
      decoration: InputDecoration(
        labelText: label,
        counterText: '',
        prefixIcon: Padding(
          padding: const EdgeInsetsDirectional.only(start: 14, end: 10),
          child: Icon(icon, color: _AppColors.primary),
        ),
        filled: true,
        fillColor: _AppColors.surfaceAlt,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _AppColors.faint),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFD3D3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_rounded, color: Color(0xFFD93A3A), size: 20),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
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

class _DialogIcon extends StatelessWidget {
  const _DialogIcon({
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });

  final IconData icon;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: color, size: 28),
    );
  }
}
