/// Main entry point for the Masrofy application.
///
/// This file is responsible for:
/// - Initializing Flutter bindings.
/// - Registering all global Providers.
/// - Configuring application theme.
/// - Defining application routes.
/// - Launching the root widget.
///
/// Architecture:
/// The application uses the Provider package for state management
/// and follows a layered structure:
/// - logic/        -> State management & business logic
/// - presentation/ -> UI screens and widgets
///
/// State Management:
/// - AuthProvider     -> Authentication state
/// - ExpenseProvider  -> Expense management state
/// - BudgetProvider   -> Budget and cycle management state
///
/// Navigation:
/// Flutter named routes are used for screen navigation.
///
/// Author: Your Name
/// Project: Masrofy Expense Tracker App

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Business logic providers
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

/// Application entry point.
///
/// Ensures Flutter bindings are initialized before running
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MasrofyApp());
}

/// Root widget of the Masrofy application.
///
/// Responsibilities:
/// - Provides global state using MultiProvider.
/// - Configures application-wide theme.
/// - Registers all named routes.
/// - Defines the initial route.
///
/// This widget remains stateless because all dynamic state
/// is managed externally using Providers.
class MasrofyApp extends StatelessWidget {
  /// Creates the root application widget.
  const MasrofyApp({super.key});

  @override
  Widget build(BuildContext context) {
    /// MultiProvider allows multiple ChangeNotifier providers
    /// to be accessible throughout the widget tree.
    return MultiProvider(
      providers: [
        /// Handles authentication and user session state.
        ///
        /// init() is called immediately to initialize
        /// persisted authentication data.
        ChangeNotifierProvider(create: (_) => AuthProvider()..init()),

        /// Handles expense operations such as:
        /// - Adding expenses
        /// - Removing expenses
        /// - Loading saved expenses
        ChangeNotifierProvider(create: (_) => ExpenseProvider()..init()),
        
        /// Handles budgeting and financial cycle setup.
        ChangeNotifierProvider(create: (_) => BudgetProvider()..init()),
      ],
      /// Root Material Application configuration.
      
      child: MaterialApp(

        /// Application title shown by the operating system.
        title: 'Masrofy',

        /// Removes the debug banner in development mode.
        debugShowCheckedModeBanner: false,

        /// Global application theme configuration.
        theme: ThemeData(

          /// Primary color swatch used across the app.
          primarySwatch: Colors.teal,

          /// Material 3 color system generated from seed color.
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.teal,
            brightness: Brightness.light,
          ),

          /// Enables Material Design 3.
          useMaterial3: true,

          /// Global font family used in the application.
          fontFamily: 'Cairo',
        ),

        /// First route loaded when the app starts.
        initialRoute: '/',

        /// Named routes configuration.
        ///
        /// Route Map:
        /// '/'              -> Splash Screen
        /// '/auth'          -> Authentication Screen
        /// '/setup'         -> Budget Cycle Setup Screen
        /// '/dashboard'     -> Main Dashboard Screen
        /// '/add-expense'   -> Add Expense Screen
        /// '/history'       -> Expense History Screen
        /// '/settings'      -> Settings Screen
        routes: {
          /// Initial splash/loading screen.
          '/': (context) => const SplashScreen(),

          /// User authentication screen.
          '/auth': (context) => const AuthScreen(),

          /// Budget cycle setup screen.
          '/setup': (context) => const SetupCycleScreen(),

          /// Main application dashboard.
          '/dashboard': (context) => const DashboardScreen(),

          /// Screen used to add a new expense.
          '/add-expense': (context) => const AddExpenseScreen(),

          /// Displays expense history records.
          '/history': (context) => const HistoryScreen(),

          /// Application settings screen.
          '/settings': (context) => const SettingsScreen(),
        },
      ),
    );
  }
}
