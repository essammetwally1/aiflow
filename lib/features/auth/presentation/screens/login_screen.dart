import 'package:aiflow/core/app_theme.dart';
import 'package:aiflow/core/utils.dart';
import 'package:aiflow/core/widgets/custom_text_form_field.dart';
import 'package:aiflow/core/widgets/logo_widget.dart';
import 'package:aiflow/features/auth/presentation/provider/auth_provider.dart';
import 'package:aiflow/features/home/presentation/screens/home_screen.dart';
import 'package:aiflow/shared/provider/setting_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/custom_elevated_button.dart';
import '../../../../core/services/storage/user_storage_service.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final globalKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool isGoogleLoading = false;
  bool rememberMe = false;

  @override
  void initState() {
    super.initState();
    _initRememberMe();
  }

  Future<void> _initRememberMe() async {
    final on = await UserStorageService.isRememberMeEnabled();
    if (!mounted) return;
    setState(() => rememberMe = on);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!globalKey.currentState!.validate() || isLoading) return;

    setState(() => isLoading = true);
    try {
      final ok = await context.read<AuthProvider>().login(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        rememberMe: rememberMe,
      );

      if (!mounted) return;
      if (ok) {
        Utils.showSuccessMessage('Login successful');
        if (rememberMe) {
          _initRememberMe();
        }

        Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
      } else {
        final msg = context.read<AuthProvider>().error ?? 'Login failed';
        Utils.showErrorMessage(msg);
      }
    } catch (e) {
      Utils.showErrorMessage('Unexpected error. Please try again.');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _googleLogin() async {
    if (isGoogleLoading) return;
    setState(() => isGoogleLoading = true);
    try {
      final ok = await context.read<AuthProvider>().googleSignIn();
      if (!mounted) return;
      if (ok) {
        Utils.showSuccessMessage('Signed in with Google');
        Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
      } else {
        final msg =
            context.read<AuthProvider>().error ?? 'Google sign-in failed';
        Utils.showErrorMessage(msg);
      }
    } finally {
      if (mounted) setState(() => isGoogleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<SettingsProvider>().isDark;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Login',
          style: Theme.of(
            context,
          ).textTheme.titleLarge!.copyWith(color: AppTheme.primary),
        ),
      ),
      body: AbsorbPointer(
        absorbing: isLoading || isGoogleLoading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Form(
            key: globalKey,
            child: Column(
              children: [
                const SizedBox(height: 16),
                const LogoWidget(),
                const SizedBox(height: 50),

                CustomTextFormField(
                  hintText: 'Email',
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
                  isDark: isDark,
                ),
                const SizedBox(height: 16),

                CustomTextFormField(
                  hintText: 'Password',
                  iconPathName: 'password',
                  controller: passwordController,
                  isPassword: true,
                  validator: (value) {
                    final v = (value ?? '').trim();
                    if (v.isEmpty) return 'Enter password';
                    if (v.length < 9) {
                      return 'Password should be -more than 9 letters-';
                    }
                    return null;
                  },
                  isDark: isDark,
                ),

                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: rememberMe,
                      onChanged: (val) =>
                          setState(() => rememberMe = val ?? false),
                      fillColor: WidgetStateProperty.all(AppTheme.primary),
                      checkColor: AppTheme.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      side: const BorderSide(color: AppTheme.primary, width: 2),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    Text(
                      'Remember me',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                CustomElevatedButton(
                  isLoading: isLoading,
                  onPressed: _login,
                  textElevatedButton: 'Login',
                ),
                const SizedBox(height: 50),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Don\'t Have Account?',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: isDark ? AppTheme.white : AppTheme.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextButton(
                      onPressed: isLoading
                          ? null
                          : () => Navigator.of(
                              context,
                            ).pushReplacementNamed(RegisterScreen.routeName),
                      child: const Text('Create Account'),
                    ),
                  ],
                ),

                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        thickness: 1,
                        indent: 30,
                        color: AppTheme.primary,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        'or',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        thickness: 1,
                        endIndent: 30,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                CustomElevatedButton(
                  isGoogle: true,
                  isLoading: isGoogleLoading,
                  textElevatedButton: 'Continue With Google',
                  onPressed: _googleLogin,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
