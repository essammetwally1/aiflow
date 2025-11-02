import 'package:aiflow/core/theme/app_theme.dart' show AppTheme;
import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  final String textElevatedButton;
  final VoidCallback onPressed;
  final bool isLoading;
  final Color color;
  final TextStyle? textStyle;
  final bool isGoogle;
  const CustomElevatedButton({
    super.key,
    required this.textElevatedButton,
    required this.onPressed,
    this.isLoading = false,
    this.color = AppTheme.primary,
    this.textStyle,
    this.isGoogle = false,
  });

  @override
  Widget build(BuildContext context) {
    final TextStyle style =
        textStyle ??
        TextTheme.of(context).titleLarge!.copyWith(color: AppTheme.white);
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        fixedSize: Size(MediaQuery.sizeOf(context).width, 56),
      ),
      onPressed: onPressed,
      child: isLoading
          ? Center(child: CircularProgressIndicator(color: AppTheme.white))
          : isGoogle
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'G',
                  style: style.copyWith(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.white,
                  ),
                ),
                SizedBox(width: 10),
                Text(textElevatedButton, style: style),
              ],
            )
          : Text(textElevatedButton, style: style),
    );
  }
}
