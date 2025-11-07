import 'package:aiflow/core/theme/app_theme.dart';
import 'package:aiflow/features/image/presentation/widgets/glass_loading_overlay.dart';
import 'package:flutter/material.dart';

class PreviewCard extends StatelessWidget {
  final Widget child;
  final bool showOverlay;

  const PreviewCard({
    super.key,
    required this.child,
    required this.showOverlay,
  });

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).scaffoldBackgroundColor == AppTheme.backgroundDark;

    return Container(
      height: MediaQuery.sizeOf(context).height * .5,
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .1),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: AppTheme.primary.withValues(alpha: .15),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Center(child: child),
          if (showOverlay) GlassLoadingOverlay(),
        ],
      ),
    );
  }
}
