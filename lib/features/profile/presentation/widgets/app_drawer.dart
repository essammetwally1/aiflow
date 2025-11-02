import 'package:aiflow/core/app_theme.dart';
import 'package:aiflow/core/utils.dart';
import 'package:aiflow/features/auth/data/models/user_model.dart';
import 'package:aiflow/features/auth/presentation/provider/auth_provider.dart';
import 'package:aiflow/features/auth/presentation/screens/login_screen.dart';
import 'package:aiflow/shared/provider/setting_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});
  Future<void> _showRenameDialog(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final currentName = auth.user?.name ?? '';
    final controller = TextEditingController(text: currentName);

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Theme.of(ctx).brightness == Brightness.dark
              ? AppTheme.backgroundDark
              : AppTheme.white,
          title: const Text('Rename user name'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Full name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                final newName = controller.text.trim();
                if (newName.isEmpty) return;
                try {
                  // await auth.updateUserName(
                  //   newName,
                  // ); // implement in AuthProvider
                  if (context.mounted) {
                    Utils.showSuccessMessage('Name updated');
                    Navigator.pop(ctx);
                  }
                } catch (e) {
                  if (context.mounted) {
                    Utils.showErrorMessage('Failed to update name: $e');
                  }
                }
              },
              child: const Text(
                'Save',
                style: TextStyle(color: AppTheme.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleResetPassword(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final email = auth.user?.email;
    if (email == null || email.isEmpty) {
      Utils.showErrorMessage('No email linked to this account.');
      return;
    }
    try {
      // await auth.sendPasswordResetEmail(email); // implement in AuthProvider
      Utils.showSuccessMessage('Reset link sent to $email');
    } catch (e) {
      Utils.showErrorMessage('Failed to send reset email: $e');
    }
  }

  String _initials(String? name) {
    if (name == null || name.trim().isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    final first = parts.isNotEmpty ? parts.first.characters.first : '';
    final last = parts.length > 1 ? parts.last.characters.first : '';
    final res = (first + last).toUpperCase();
    return res.isEmpty ? '?' : res;
  }

  @override
  Widget build(BuildContext context) {
    final UserModel? user = context.watch<AuthProvider>().user;
    final TextTheme textTheme = Theme.of(context).textTheme;

    final name = user?.name ?? 'Guest';
    final imageUrl = user?.photoUrl ?? '';

    Future<void> logout() async {
      if (context.mounted) Utils.showSuccessMessage('Logged out');
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          LoginScreen.routeName,
          (route) => false,
        );
      }
      await context.read<AuthProvider>().logout();
    }

    return Drawer(
      backgroundColor: AppTheme.backgroundLight,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 30, 16, 20),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.08),
              border: Border(
                bottom: BorderSide(color: AppTheme.gray.withValues(alpha: 0.2)),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.primary.withValues(alpha: .9),
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 32,
                    backgroundColor: AppTheme.gray.withValues(alpha: .15),
                    backgroundImage: imageUrl.isNotEmpty
                        ? CachedNetworkImageProvider(imageUrl)
                        : null,
                    child: imageUrl.isEmpty
                        ? Text(
                            _initials(name),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: AppTheme.black,
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.black,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // ── Profile (expandable)
                Theme(
                  // shrink divider/ink to match your theme
                  data: Theme.of(
                    context,
                  ).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    leading: const Icon(Icons.person, color: AppTheme.primary),
                    title: Text('Profile', style: textTheme.titleMedium),
                    collapsedBackgroundColor: AppTheme.primary.withValues(
                      alpha: 0.04,
                    ),
                    backgroundColor: AppTheme.primary.withValues(alpha: 0.06),
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
                        title: const Text(
                          'Rename user name',
                          style: TextStyle(color: AppTheme.black),
                        ),
                        onTap: () => _showRenameDialog(context),
                      ),
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.lock_reset,
                          color: AppTheme.primary,
                        ),
                        title: const Text(
                          'Reset password',
                          style: TextStyle(color: AppTheme.black),
                        ),
                        onTap: () => _handleResetPassword(context),
                      ),
                    ],
                  ),
                ),

                // ── Settings + Theme switch
                Builder(
                  builder: (context) {
                    final isDark = context
                        .watch<SettingsProvider>()
                        .isDark; // adjust to your provider
                    return ListTile(
                      leading: const Icon(
                        Icons.settings,
                        color: AppTheme.primary,
                      ),
                      title: Text('Settings', style: textTheme.titleMedium),
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
                                context.read<SettingsProvider>().toggleTheme(),
                          ),
                        ],
                      ),
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Toggle theme using the switch →'),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

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
