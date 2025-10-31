import 'package:aiflow/app/app_auth_gate.dart';
import 'package:aiflow/features/auth/presentation/screens/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aiflow/core/app_theme.dart';
import 'package:aiflow/shared/provider/setting_provider.dart';
import 'package:aiflow/features/home/presentation/screens/home_screen.dart';
import 'package:aiflow/features/auth/presentation/screens/login_screen.dart';

class AiFlow extends StatelessWidget {
  const AiFlow({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<SettingsProvider>().isDark;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: const AppAuthGate(),
      routes: {
        LoginScreen.routeName: (_) => const LoginScreen(),
        RegisterScreen.routeName: (_) => const RegisterScreen(),
        HomeScreen.routeName: (_) => const HomeScreen(),
      },
    );
  }
}
