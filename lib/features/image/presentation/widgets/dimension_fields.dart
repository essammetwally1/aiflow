import 'package:flutter/material.dart';
import 'package:aiflow/core/theme/app_theme.dart';

class DimensionFields extends StatelessWidget {
  final TextEditingController widthC;
  final TextEditingController heightC;
  final VoidCallback onResize;
  final bool busy;

  const DimensionFields({
    super.key,
    required this.widthC,
    required this.heightC,
    required this.onResize,
    required this.busy,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    InputDecoration deco(String label, IconData icon) => InputDecoration(
      labelText: label,
      suffixIcon: Icon(icon, color: AppTheme.primary),
    );

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: widthC,
                cursorColor: AppTheme.primary,

                keyboardType: TextInputType.number,
                style: theme.titleMedium,

                decoration: deco('Width (px)', Icons.width_full_outlined),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: heightC,
                keyboardType: TextInputType.number,
                style: theme.titleMedium,
                cursorColor: AppTheme.primary,
                decoration: deco('Height (px)', Icons.height),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: busy ? null : onResize,
            icon: busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.white,
                    ),
                  )
                : const Icon(Icons.tune, color: AppTheme.white),
            label: Text(
              busy ? 'Resizing…' : 'Resize to exact dimensions',
              style: theme.titleMedium!.copyWith(color: AppTheme.white),
            ),
          ),
        ),
      ],
    );
  }
}
