// lib/features/profile/presentation/widgets/app_drawer.dart
import 'dart:math' as math;
import 'package:aiflow/core/domain/entities/user.dart';
import 'package:aiflow/core/theme/app_theme.dart';
import 'package:aiflow/core/utils/utils.dart';
import 'package:aiflow/core/widgets/custom_text_form_field.dart';
import 'package:aiflow/features/auth/presentation/provider/auth_provider.dart';
import 'package:aiflow/features/auth/presentation/screens/login_screen.dart';
import 'package:aiflow/features/profile/presentation/provider/profile_provider.dart';
import 'package:aiflow/shared/provider/setting_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  String _initials(String? name) {
    if (name == null || name.trim().isEmpty) return '?';
    final p = name.trim().split(RegExp(r'\s+'));
    final a = p.first.isNotEmpty ? p.first[0] : '';
    final b = p.length > 1 && p.last.isNotEmpty ? p.last[0] : '';
    final r = (a + b).toUpperCase();
    return r.isEmpty ? '?' : r;
  }

  Future<void> _showRenameDialog(
    BuildContext context,
    String current,
    bool isDark,
    TextTheme textTheme,
  ) async {
    final formKey = GlobalKey<FormState>();
    final controller = TextEditingController(text: current);
    bool isLoading = false;

    await showDialog<bool>(
      context: context,
      barrierDismissible: !isLoading,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) => AlertDialog(
            backgroundColor: isDark
                ? AppTheme.backgroundDark
                : AppTheme.backgroundLight,
            title: Text('Rename user name', style: textTheme.titleMedium),
            content: AbsorbPointer(
              absorbing: isLoading,
              child: Form(
                key: formKey,
                child: CustomTextFormField(
                  controller: controller,
                  isDark: isDark,
                  label: 'New name',
                  validator: (v) {
                    final val = (v ?? '').trim();
                    if (val.isEmpty) return 'Enter a name';
                    if (val == current.trim()) return 'Choose a different name';
                    return null;
                  },
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.pop(ctx, false),
                child: const Text('Cancel', style: TextStyle(fontSize: 14)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: isLoading
                    ? null
                    : () async {
                        if (!formKey.currentState!.validate()) return;
                        setState(() => isLoading = true);

                        final newName = controller.text.trim();

                        try {
                          // Prefer the confirm flow if you added it; else fall back to rename().
                          bool ok = false;
                          final provider = context.read<ProfileProvider>();
                          // just a ref

                          // If you implemented renameAndConfirm(newName)
                          ok = await provider.renameAndConfirm(newName);

                          if (ok) {
                            Utils.showSuccessMessage('Name updated');
                            if (ctx.mounted) Navigator.pop(ctx, true);
                          } else {
                            final st = provider.state;
                            Utils.showErrorMessage(
                              st.message ?? 'Rename failed',
                            );
                            setState(() => isLoading = false);
                          }
                        } catch (e) {
                          Utils.showErrorMessage('Something went wrong');
                          setState(() => isLoading = false);
                        }
                      },
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.white,
                          ),
                        ),
                      )
                    : const Text(
                        'Save',
                        style: TextStyle(color: AppTheme.white, fontSize: 14),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showChangePasswordDialog(
    BuildContext context,
    bool isDark,
    TextTheme textTheme,
  ) async {
    final formKey = GlobalKey<FormState>();
    final oldC = TextEditingController();
    final newC = TextEditingController();
    final confirmC = TextEditingController();

    bool obscureOld = true;
    bool obscureNew = true;
    bool obscureConfirm = true;
    bool isLoading = false;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible:
          !isLoading, // user can still tap outside when not saving
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) => AlertDialog(
            backgroundColor: isDark
                ? AppTheme.backgroundDark
                : AppTheme.backgroundLight,
            title: const Text('Change password'),
            content: AbsorbPointer(
              // disable fields while loading
              absorbing: isLoading,
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomTextFormField(
                      controller: oldC,
                      isDark: isDark,
                      label: 'Old password',
                      isPassword: obscureOld,
                      onPressed: () => setState(() => obscureOld = !obscureOld),
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Enter old password'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    CustomTextFormField(
                      controller: newC,
                      isDark: isDark,
                      label: 'New password',
                      isPassword: obscureNew,
                      onPressed: () => setState(() => obscureNew = !obscureNew),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Enter new password';
                        if (v.length < 9) return 'Use at least 9 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    CustomTextFormField(
                      controller: confirmC,
                      isDark: isDark,
                      label: 'Confirm new password',
                      isPassword: obscureConfirm,
                      onPressed: () =>
                          setState(() => obscureConfirm = !obscureConfirm),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Confirm new password';
                        }
                        if (v != newC.text) return 'Passwords do not match';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.pop(ctx, false),
                child: const Text('Cancel', style: TextStyle(fontSize: 14)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: isLoading
                    ? null
                    : () async {
                        if (!formKey.currentState!.validate()) return;
                        setState(() => isLoading = true);
                        try {
                          final err = await context
                              .read<ProfileProvider>()
                              .changePassword(
                                oldPassword: oldC.text.trim(),
                                newPassword: newC.text.trim(),
                              );
                          if (err != null) {
                            Utils.showErrorMessage(err);
                            setState(() => isLoading = false);
                          } else {
                            Utils.showSuccessMessage('Password updated');
                            if (ctx.mounted) Navigator.pop(ctx, true);
                          }
                        } catch (e) {
                          Utils.showErrorMessage('Something went wrong');
                          setState(() => isLoading = false);
                        }
                      },
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.white,
                          ),
                        ),
                      )
                    : const Text(
                        'Update',
                        style: TextStyle(color: AppTheme.white, fontSize: 14),
                      ),
              ),
            ],
          ),
        );
      },
    );

    if (result == true && context.mounted) {
      // provider already notified; nothing else needed
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? profile = context.watch<ProfileProvider>().state.profile;
    final bool isDark = context.watch<SettingsProvider>().isDark;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String name = profile?.name ?? 'Guest';
    final String imageUrl = profile?.photoUrl ?? '';

    final w = MediaQuery.sizeOf(context).width;
    final drawerW = w < 480 ? w * 0.85 : math.min(380.0, w * 0.5);

    Future<void> logout() async {
      Utils.showSuccessMessage('Logged out');
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          LoginScreen.routeName,
          (r) => false,
        );
      }
      await context.read<AuthProvider>().logout();
    }

    return Drawer(
      backgroundColor: isDark
          ? AppTheme.backgroundDark
          : AppTheme.backgroundLight,
      width: drawerW,
      child: Column(
        children: [
          // header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 30, 16, 20),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: .5),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.white, width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 32,
                    backgroundColor: AppTheme.gray.withValues(alpha: .15),
                    backgroundImage: imageUrl.isNotEmpty
                        ? CachedNetworkImageProvider(imageUrl)
                        : null,
                    child: imageUrl.isEmpty
                        ? Text(_initials(name), style: textTheme.titleMedium)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleLarge,
                  ),
                ),
              ],
            ),
          ),

          // body
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ExpansionTile(
                  leading: const Icon(Icons.person, color: AppTheme.primary),
                  title: Text('Profile', style: textTheme.titleMedium),
                  childrenPadding: const EdgeInsets.only(
                    left: 72,
                    right: 12,
                    bottom: 8,
                  ),
                  children: [
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.drive_file_rename_outline,
                        color: AppTheme.primary,
                      ),
                      title: Text(
                        'Rename user name',
                        style: textTheme.titleSmall,
                      ),
                      onTap: () =>
                          _showRenameDialog(context, name, isDark, textTheme),
                    ),
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.password,
                        color: AppTheme.primary,
                      ),
                      title: Text(
                        'Change password',
                        style: textTheme.titleSmall,
                      ),

                      onTap: () =>
                          _showChangePasswordDialog(context, isDark, textTheme),
                    ),
                  ],
                ),

                // Theme toggle (drawer only)
                Builder(
                  builder: (ctx) {
                    final isDark = ctx.watch<SettingsProvider>().isDark;
                    return ListTile(
                      leading: const Icon(
                        Icons.settings,
                        color: AppTheme.primary,
                      ),
                      title: Text('Dark mode', style: textTheme.titleMedium),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isDark ? Icons.dark_mode : Icons.light_mode,
                            color: AppTheme.gray.withValues(alpha: .9),
                          ),
                          const SizedBox(width: 8),
                          Switch(
                            value: isDark,
                            activeThumbColor: AppTheme.primary,
                            onChanged: (_) =>
                                ctx.read<SettingsProvider>().toggleTheme(),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          // Google-only account (no password provider)

          // logout
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout, color: AppTheme.white),
                label: const Text(
                  'Logout',
                  style: TextStyle(color: AppTheme.white, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.red.withValues(alpha: .9),
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: logout,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
