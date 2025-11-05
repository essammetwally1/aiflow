import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:aiflow/core/theme/app_theme.dart';
import 'package:aiflow/core/utils/utils.dart';
import 'package:aiflow/features/profile/presentation/provider/profile_provider.dart';
import 'package:aiflow/shared/provider/setting_provider.dart';
import '../controllers/profile_state.dart';

class AvatarPickerSheet {
  static Future<void> open(BuildContext context) async {
    final provider = context.read<ProfileProvider>();
    final isDark = context.read<SettingsProvider>().isDark;

    if (provider.state.status == ProfileStatus.loading) return;

    final source = await _showSourceSelection(context, isDark);
    if (source == null) return;

    HapticFeedback.selectionClick();

    void startIndicator() => _showProgressDialog(context, null);

    try {
      String? err;
      switch (source) {
        case ImageSource.camera:
          err = await provider.changeAvatarFromCamera(
            isDark: isDark,
            onStartedUpload: startIndicator, // <— here
          );
          break;
        case ImageSource.gallery:
          err = await provider.changeAvatarFromGallery(
            isDark: isDark,
            onStartedUpload: startIndicator, // <— here
          );
          break;
      }

      if (!context.mounted) return;

      // Close the dialog if we opened it
      final nav = Navigator.of(context, rootNavigator: true);
      if (nav.canPop()) nav.pop();

      if (err == null) {
        HapticFeedback.mediumImpact();
        Utils.showSuccessMessage('Profile image updated successfully!');
      } else {
        Utils.showErrorMessage(err);
      }
    } catch (e) {
      // Close dialog if open
      if (context.mounted) {
        final nav = Navigator.of(context, rootNavigator: true);
        if (nav.canPop()) nav.pop();
        Utils.showErrorMessage(e.toString());
      }
    }
  }

  static Future<ImageSource?> _showSourceSelection(
    BuildContext context,
    bool isDark,
  ) {
    final theme = Theme.of(context).textTheme;
    final imageUrl =
        context.read<ProfileProvider>().state.profile?.photoUrl ?? '';

    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: isDark
          ? AppTheme.backgroundDark
          : AppTheme.backgroundLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppTheme.primary),
              title: Text('Choose from Gallery', style: theme.titleMedium),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera, color: AppTheme.primary),
              title: Text('Take a Photo', style: theme.titleMedium),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            imageUrl.isNotEmpty
                ? ListTile(
                    leading: const Icon(Icons.delete, color: AppTheme.red),
                    title: Text(
                      'Delete Profile Image',
                      style: theme.titleMedium!.copyWith(color: AppTheme.red),
                    ),
                    onTap: () async {
                      Navigator.pop(ctx);
                      await _confirmDelete(context, isDark);
                    },
                  )
                : SizedBox(),
          ],
        ),
      ),
    );
  }

  static Future<void> _confirmDelete(BuildContext context, bool isDark) async {
    final theme = Theme.of(context).textTheme;

    await showDialog<void>(
      context: context,
      builder: (dCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: isDark
            ? AppTheme.backgroundDark
            : AppTheme.backgroundLight,
        title: Text(
          'Delete Profile Image',
          style: theme.titleLarge!.copyWith(color: AppTheme.red),
        ),
        content: Text(
          'Are you sure you want to delete your profile image?',
          style: theme.titleMedium!.copyWith(
            color: isDark ? AppTheme.white : AppTheme.black,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dCtx),
            child: Text(
              'Cancel',
              style: theme.titleMedium!.copyWith(color: AppTheme.primary),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dCtx);
              _showProgressDialog(context, 'Deleting…');
              try {
                final err = await context
                    .read<ProfileProvider>()
                    .deleteAvatar();
                if (err != null) throw StateError(err);
                HapticFeedback.mediumImpact();
                Utils.showSuccessMessage('Profile image deleted.');
              } catch (e) {
                Utils.showErrorMessage(e.toString());
              } finally {
                if (context.mounted) {
                  final nav = Navigator.of(context, rootNavigator: true);
                  if (nav.canPop()) nav.pop();
                }
              }
            },
            child: Text(
              'Delete',
              style: theme.titleMedium!.copyWith(color: AppTheme.red),
            ),
          ),
        ],
      ),
    );
  }

  static void _showProgressDialog(BuildContext context, String? label) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        // If .withValues isn't supported on your Flutter version, use .withOpacity(0.5)
        backgroundColor: AppTheme.primary.withOpacity(0.5),
        content: Row(
          children: [
            const CircularProgressIndicator(color: AppTheme.white),
            const SizedBox(width: 16),
            Text(
              label ?? 'Uploading…',
              style: theme.textTheme.titleMedium!.copyWith(
                color: AppTheme.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
