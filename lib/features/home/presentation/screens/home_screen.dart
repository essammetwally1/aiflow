// lib/features/home/presentation/screens/home_screen.dart
import 'dart:developer';

import 'package:aiflow/core/widgets/logo_widget.dart';
import 'package:aiflow/features/auth/data/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aiflow/features/auth/presentation/provider/auth_provider.dart';
import 'package:aiflow/core/widgets/custom_elevated_button.dart';
import 'package:aiflow/core/utils.dart';
import 'package:aiflow/features/auth/presentation/screens/login_screen.dart';

class HomeScreen extends StatelessWidget {
  static const String routeName = '/home';
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final UserModel? userModel = context.watch<AuthProvider>().user;
    log(userModel.toString());

    return Scaffold(
      appBar: AppBar(
        title: Text(userModel?.name ?? 'AiFlow'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              if (context.mounted) {
                Utils.showSuccessMessage('Logged out');
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  LoginScreen.routeName,
                  (route) => false,
                );
                await context.read<AuthProvider>().logout();
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Image.network(userModel!.photoUrl),
            LogoWidget(),
            Row(
              children: [
                Expanded(
                  child: CustomElevatedButton(
                    textElevatedButton: 'Analysis Image',
                    onPressed: () {},
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: CustomElevatedButton(
                    textElevatedButton: 'Resize Image',
                    onPressed: () {},
                  ),
                ),
              ],
            ),
            CustomElevatedButton(
              textElevatedButton: 'Ai chat happy',
              onPressed: () {},
            ),
            CustomElevatedButton(
              textElevatedButton: 'Ai chat sad',
              onPressed: () {},
            ),
            CustomElevatedButton(
              textElevatedButton: 'Ai chat iq',
              onPressed: () {},
            ),
            CustomElevatedButton(
              textElevatedButton: 'Ai chat public',
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
