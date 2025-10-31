import 'package:aiflow/core/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CustomTextFormField extends StatefulWidget {
  final String? hintText;
  final String? iconPathName;
  final String? label;
  final TextEditingController? controller;
  final void Function(String)? onChange;
  final void Function()? onTap;
  final VoidCallback? onPressed;
  final int? maxLines;
  final String? Function(String?)? validator;
  final bool isPassword;
  final bool isDark;
  final FocusNode? focusNode;

  const CustomTextFormField({
    super.key,
    this.hintText,
    this.iconPathName,
    this.controller,
    this.onChange,
    this.maxLines = 1,
    this.validator,
    this.onPressed,
    this.isPassword = false,
    required this.isDark,
    this.label,
    this.focusNode,
    this.onTap,
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  bool showPassword = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: widget.validator,
      maxLines: widget.maxLines,
      controller: widget.controller,
      obscureText: widget.isPassword ? showPassword : false,

      onChanged: widget.onChange,
      focusNode: widget.focusNode,
      onTap: widget.onTap,
      onTapOutside: (_) {
        FocusManager.instance.primaryFocus!.unfocus();
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
      cursorColor: AppTheme.primary,
      style: Theme.of(
        context,
      ).textTheme.titleLarge!.copyWith(color: AppTheme.primary),
      decoration: InputDecoration(
        labelText: widget.label,

        hintText: widget.hintText,
        contentPadding: EdgeInsets.all(16),
        suffixIcon: widget.isPassword
            ? IconButton(
                highlightColor: Colors.transparent,
                onPressed: () {
                  showPassword = !showPassword;
                  setState(() {});
                },
                icon: showPassword
                    ? Icon(Icons.visibility_off_outlined, color: AppTheme.gray)
                    : Icon(Icons.visibility_outlined, color: AppTheme.gray),
              )
            : null,
        prefixIcon: widget.iconPathName == null
            ? null
            : SvgPicture.asset(
                'assets/icons/${widget.iconPathName}.svg',
                width: 24,
                height: 24,
                fit: BoxFit.scaleDown,
                colorFilter: ColorFilter.mode(AppTheme.gray, BlendMode.srcIn),
              ),
      ),
    );
  }
}
