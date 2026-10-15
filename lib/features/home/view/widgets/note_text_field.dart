import 'package:flutter/material.dart';
import 'package:quicknotes/core/theme/app_theme.dart';
import 'package:quicknotes/core/utils/app_text_style.dart';

class NoteTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? text;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final TextStyle? style;
  final TextStyle? hintStyle;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;

  const NoteTextField({
    super.key,
    required this.controller,
    this.text,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.style,
    this.hintStyle,
    this.textInputAction,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      buildCounter: (
        _, {
        required currentLength,
        required isFocused,
        maxLength,
      }) => null,
      style:
          style ??
          AppTextStyle.displayLargeMobile.copyWith(color: context.textPrimary),
      textInputAction: textInputAction ?? TextInputAction.next,
      decoration: InputDecoration(
        hintText: text,
        hintStyle:
            hintStyle ??
            AppTextStyle.displayLargeMobile.copyWith(color: context.textMuted),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
      validator: validator,
    );
  }
}
