import 'package:aiflow/core/app_theme.dart' show AppTheme;
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
                  style:
                      textStyle ??
                      TextTheme.of(context).titleLarge!.copyWith(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(width: 10),
                Text(
                  textElevatedButton,
                  style: textStyle ?? TextTheme.of(context).titleLarge,
                ),
              ],
            )
          : Text(
              textElevatedButton,
              style: textStyle ?? TextTheme.of(context).titleLarge,
            ),
    );
  }
}
