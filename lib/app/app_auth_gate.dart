import 'package:aiflow/features/auth/presentation/provider/auth_provider.dart';
import 'package:aiflow/features/auth/presentation/screens/login_screen.dart';
import 'package:aiflow/features/home/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppAuthGate extends StatelessWidget {
  const AppAuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthProvider auth = context.watch<AuthProvider>();
    if (auth.initializing) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return auth.user != null ? const HomeScreen() : const LoginScreen();
  }
}
