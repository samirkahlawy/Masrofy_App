import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'logic/finance_provider.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/dashboard_screen.dart';

void main() {
  runApp(const MasrofyApp());
}

class MasrofyApp extends StatelessWidget {
  const MasrofyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FinanceProvider(),
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
          '/dashboard': (context) =>  DashboardScreen(),
        },
      ),
    );
  }
}

