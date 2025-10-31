import 'package:aiflow/core/constants.dart';
import 'package:aiflow/core/widgets/custom_elevated_button.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  static const String routeName = '/home';
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Image.asset(Constants.logoImage),
            Row(
              children: [
                Expanded(
                  child: CustomElevatedButton(
                    textElevatedButton: 'Analysis Image',
                    onPressed: () {},
                  ),
                ),
                SizedBox(width: 20),
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
