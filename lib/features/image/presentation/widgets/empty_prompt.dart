import 'package:aiflow/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class EmptyPrompt extends StatelessWidget {
  final VoidCallback onPick;
  const EmptyPrompt({super.key, required this.onPick});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Column(
      key: const ValueKey('empty'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.image_outlined, size: 48, color: AppTheme.primary),
        const SizedBox(height: 10),
        Text('No image selected', style: theme.titleMedium),
        const SizedBox(height: 6),
        Text(
          'Tap the camera button to choose from gallery or camera',
          style: theme.titleSmall!.copyWith(fontSize: 12),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppTheme.primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: onPick,
          icon: const Icon(Icons.add_a_photo, color: AppTheme.primary),
          label: const Text(
            'Pick image',
            style: TextStyle(color: AppTheme.primary),
          ),
        ),
      ],
    );
  }
}
