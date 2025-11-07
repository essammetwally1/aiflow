import 'package:aiflow/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageSourceSnack {
  static Future<ImageSource?> pickSource(BuildContext context) {
    final isDark =
        Theme.of(context).scaffoldBackgroundColor == AppTheme.backgroundDark;

    return showGeneralDialog<ImageSource>(
      context: context,
      barrierLabel: 'Image source',
      barrierDismissible: true,
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (ctx, anim, __, ___) {
        final curved = CurvedAnimation(
          parent: anim,
          curve: Curves.easeOutCubic,
        );
        return Center(
          child: FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: .95, end: 1).animate(curved),
              child: Material(
                color: isDark
                    ? AppTheme.backgroundDark
                    : AppTheme.backgroundLight,
                elevation: 10,
                borderRadius: BorderRadius.circular(20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 340),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.image,
                          color: AppTheme.primary,
                          size: 34,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Choose image source',
                          style: Theme.of(ctx).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.photo_library,
                                  color: AppTheme.white,
                                ),
                                label: const Text(
                                  'Gallery',
                                  style: TextStyle(color: AppTheme.white),
                                ),
                                onPressed: () =>
                                    Navigator.pop(ctx, ImageSource.gallery),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.photo_camera,
                                  color: AppTheme.white,
                                ),
                                label: const Text(
                                  'Camera',
                                  style: TextStyle(color: AppTheme.white),
                                ),
                                onPressed: () =>
                                    Navigator.pop(ctx, ImageSource.camera),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
