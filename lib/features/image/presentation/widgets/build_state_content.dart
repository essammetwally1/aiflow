import 'package:aiflow/core/theme/app_theme.dart';
import 'package:aiflow/features/image/presentation/provider/home_resize_provider.dart';
import 'package:aiflow/features/image/presentation/widgets/empty_prompt.dart';
import 'package:aiflow/features/image/presentation/widgets/preview.dart';
import 'package:flutter/material.dart';

class BuildStateContent extends StatelessWidget {
  final HomeResizeProvider p;
  final TextTheme theme;
  final void Function() onPick;
  const BuildStateContent({
    super.key,
    required this.p,
    required this.theme,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final picked = p.picked;
    final out = p.output;

    switch (p.status) {
      case HomeResizeStatus.idle:
      case HomeResizeStatus.picking:
        return EmptyPrompt(onPick: onPick);
      case HomeResizeStatus.readyToResize:
      case HomeResizeStatus.resizing:
        return Preview(file: picked!);
      case HomeResizeStatus.done:
        return Preview(file: out!.result);
      case HomeResizeStatus.error:
        return Padding(
          key: const ValueKey('error'),
          padding: const EdgeInsets.all(16),
          child: Text(
            p.message ?? 'Something went wrong',
            style: theme.titleMedium!.copyWith(color: AppTheme.red),
            textAlign: TextAlign.center,
          ),
        );
    }
  }
}
