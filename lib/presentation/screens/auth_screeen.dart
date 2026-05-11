import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../logic/auth_provider.dart';

/// The authentication screen where users enter their PIN to access the app.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _pinController = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  /// Attempts to authenticate the user with the provided PIN.
  Future<void> _onLogin() async {
    final pin = _pinController.text.trim();
    if (pin.isEmpty || pin.length < 4) {
      setState(() {
        _errorMessage = 'أدخل رمز PIN صالح من 4 أرقام';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isVerified = await authProvider.authenticate(pin);

    setState(() {
      _isLoading = false;
    });

    if (isVerified) {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/dashboard');
    } else {
      setState(() {
        _errorMessage = 'رمز PIN غير صحيح. حاول مرة أخرى.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // UI logic including background glows and input fields
    return Scaffold(/* ... */);
  }
}