import 'package:aiflow/features/image/presentation/screens/screens/resize_image_screen.dart';
import 'package:aiflow/features/profile/presentation/widgets/profile_drawer_provider.dart';
import 'package:aiflow/features/auth/presentation/provider/auth_provider.dart';
import 'package:aiflow/core/widgets/custom_elevated_button.dart';
import 'package:aiflow/shared/provider/setting_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  static const String routeName = '/home';
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final bool isDark = context.watch<SettingsProvider>().isDark;

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Image.asset(
              isDark ? 'assets/logodark.png' : 'assets/logolight.png',
            ),
          ),
        ),
        title: const Text('AiFlow'),
        actions: [
          Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.settings_suggest, size: 30),
              tooltip: 'Open settings',
              onPressed: () => Scaffold.of(ctx).openEndDrawer(),
            ),
          ),
        ],
      ),

      endDrawer: const ProfileDrawerProvider(),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 50),
        child: user == null
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

                          onPressed: () {
                            Navigator.of(
                              context,
                            ).pushNamed(ResizeImageScreen.routeName);
                          },
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
