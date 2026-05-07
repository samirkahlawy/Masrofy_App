import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'logic/auth_provider.dart';
import 'logic/expense_provider.dart';
import 'logic/budget_provider.dart';
import 'presentation/screens/add_expense_screen.dart';
import 'presentation/screens/auth_screeen.dart';
import 'presentation/screens/dashboard_screen.dart';
import 'presentation/screens/history_screen.dart';
import 'presentation/screens/settings_screen.dart';
import 'presentation/screens/setup_cycle_screen.dart';
import 'presentation/screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MasrofyApp());
}

class MasrofyApp extends StatelessWidget {
  const MasrofyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..init()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()..init()),
        ChangeNotifierProvider(create: (_) => BudgetProvider()..init()),
      ],
      child: MaterialApp(
        title: 'Masrofy',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.teal,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.teal,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: 'Cairo',
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/auth': (context) => const AuthScreen(),
          '/setup': (context) => const SetupCycleScreen(),
          '/dashboard': (context) => const DashboardScreen(),
          '/add-expense': (context) => const AddExpenseScreen(),
          '/history': (context) => const HistoryScreen(),
          '/settings': (context) => const SettingsScreen(),
        },
      ),
    );
  }
}
