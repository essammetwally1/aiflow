import 'package:aiflow/features/profile/presentation/widgets/app_drawer.dart';
import 'package:aiflow/shared/provider/setting_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aiflow/features/auth/presentation/provider/auth_provider.dart';
import 'package:aiflow/core/widgets/custom_elevated_button.dart';

class HomeScreen extends StatelessWidget {
  static const String routeName = '/home';
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userModel = context.watch<AuthProvider>().user;
    final isDark = context.watch<SettingsProvider>().isDark;

    return Scaffold(
      appBar: AppBar(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: Image.asset(
            isDark ? 'assets/logodark.png' : 'assets/logolight.png',
            fit: BoxFit.contain,
            width: 30,
            height: 30,
          ),
        ),

        title: Text('AiFlow'),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.settings_suggest, size: 30),
              tooltip: 'Open settings',
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 50),
        child: userModel == null
            ? const Center(child: CircularProgressIndicator())
            : Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
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
