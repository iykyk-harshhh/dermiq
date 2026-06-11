import 'package:flutter/material.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/dermiq_colors.dart';

/// Luxury branded text input.
class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final int? maxLines;
  final bool readOnly;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final bool autofocus;

  const AppTextField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.maxLines = 1,
    this.readOnly = false,
    this.focusNode,
    this.textInputAction,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      maxLines: maxLines,
      readOnly: readOnly,
      focusNode: focusNode,
      textInputAction: textInputAction,
      autofocus: autofocus,
      style: AppTypography.bodyLarge.copyWith(color: context.dColors.textPrimary),
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
        prefixIcon: prefixIcon != null
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: prefixIcon,
              )
            : null,
        prefixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        suffixIcon: suffixIcon != null
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: suffixIcon,
              )
            : null,
        suffixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      ),
    );
  }
}

/// Multi-line text area.
class AppTextArea extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final int minLines;
  final int maxLines;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const AppTextArea({
    super.key,
    this.controller,
    this.hintText,
    this.minLines = 3,
    this.maxLines = 6,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      validator: validator,
      onChanged: onChanged,
      style: AppTypography.bodyMedium.copyWith(color: context.dColors.textPrimary),
      decoration: InputDecoration(
        hintText: hintText,
        alignLabelWithHint: true,
      ),
    );
  }
}
