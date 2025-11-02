import 'package:aiflow/core/theme/app_theme.dart';
import 'package:aiflow/core/utils/utils.dart';
import 'package:aiflow/core/widgets/custom_elevated_button.dart';
import 'package:aiflow/core/widgets/custom_text_form_field.dart';
import 'package:aiflow/core/widgets/logo_widget.dart';
import 'package:aiflow/features/auth/presentation/provider/auth_provider.dart';
import 'package:aiflow/shared/provider/setting_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  static const routeName = '/register';
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final globalKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    nameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!globalKey.currentState!.validate() || isLoading) return;

    setState(() => isLoading = true);
    try {
      final bool ok = await context.read<AuthProvider>().register(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!mounted) return;
      if (ok) {
        Utils.showSuccessMessage('Account created. Please log in.');
        Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
      } else {
        final msg = context.read<AuthProvider>().error ?? 'Registration failed';
        Utils.showErrorMessage(msg);
      }
    } catch (e) {
      Utils.showErrorMessage(e.toString());
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<SettingsProvider>().isDark;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Register',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            color: AppTheme.primary,
            shadows: [
              Shadow(
                color: AppTheme.black.withValues(alpha: 0.5),
                blurRadius: 1,
              ),
            ],
          ),
        ),
      ),
      body: AbsorbPointer(
        absorbing: isLoading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Form(
            key: globalKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                const LogoWidget(),
                const SizedBox(height: 50),

                CustomTextFormField(
                  isDark: isDark,
                  hintText: 'Name',
                  iconPathName: 'name',
                  controller: nameController,
                  validator: (value) {
                    final v = (value ?? '').trim();
                    if (v.isEmpty) return 'Enter Name';
                    if (v.length < 4) return 'Name must be 4 or more letters';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                CustomTextFormField(
                  isDark: isDark,
                  hintText: 'Mail',
                  iconPathName: 'mail',
                  controller: emailController,
                  validator: (value) {
                    final v = (value ?? '').trim();
                    if (v.isEmpty) return 'Enter Email';
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(v)) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                CustomTextFormField(
                  isDark: isDark,
                  hintText: 'Password',
                  iconPathName: 'password',
                  controller: passwordController,
                  isPassword: true,
                  validator: (value) {
                    final v = (value ?? '').trim();
                    if (v.isEmpty) return 'Enter password';
                    if (v.length < 9) {
                      return 'Enter valid password -more than 9 letters-';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 50),

                CustomElevatedButton(
                  isLoading: isLoading,
                  onPressed: _register,
                  textElevatedButton: 'Create Account',
                ),
                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already Have Account ?',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: isDark ? AppTheme.white : AppTheme.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(
                        context,
                      ).pushReplacementNamed(LoginScreen.routeName),
                      child: const Text('Login'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
