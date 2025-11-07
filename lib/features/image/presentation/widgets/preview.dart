import 'dart:io';

import 'package:aiflow/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class Preview extends StatelessWidget {
  final File file;
  const Preview({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      child: ClipRRect(
        key: ValueKey(file.path),
        borderRadius: BorderRadius.circular(16),
        child: Image.file(
          file,
          fit: BoxFit.contain,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.broken_image, size: 48, color: AppTheme.red),
        ),
      ),
    );
  }
}
