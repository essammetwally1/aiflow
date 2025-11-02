import 'package:aiflow/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
  const LogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);

    return Container(
      width: size.width * .4,
      height: size.height * .15,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.primary, width: 3),
        borderRadius: BorderRadius.circular(16),
        color: AppTheme.primary.withValues(alpha: .1),
      ),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          border: BoxBorder.all(
            color: AppTheme.primary.withValues(alpha: .5),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppTheme.blue.withValues(alpha: .2),
              blurRadius: 5,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset('assets/aiflow_logo.png', fit: BoxFit.cover),
        ),
      ),
    );
  }
}
