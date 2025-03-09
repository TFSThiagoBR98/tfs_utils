import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputFormfield extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String? labelText;
  final bool readOnly;
  final bool visible;
  final bool isDense;
  final bool filled;
  final Color? fillColor;
  final TextStyle? hintStyle;
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;
  final EdgeInsetsGeometry? contentPadding;
  final GestureTapCallback? onTap;
  final FormFieldValidator<String>? validator;
  final int? lines;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefixIcon;
  final bool obscureText;
  final Widget? suffixIcon;
  final FocusNode? focusNode;
  final InputBorder? border;
  final EdgeInsetsGeometry externalPadding;
  final TextStyle? style;
  final TextInputType? keyboardType;
  final String? helperText;
  final String? hintText;
  final TextCapitalization textCapitalization;
  final String? restorationId;

  const InputFormfield(
      {super.key,
      this.controller,
      this.onChanged,
      this.labelText,
      this.visible = true,
      this.prefixIcon,
      this.suffixIcon,
      this.externalPadding = const EdgeInsets.all(8.0),
      this.lines,
      this.style,
      this.border = const OutlineInputBorder(),
      this.inputFormatters,
      this.validator,
      this.focusNode,
      this.obscureText = false,
      this.readOnly = false,
      this.isDense = false,
      this.filled = true,
      this.fillColor,
      this.hintStyle,
      this.enabledBorder,
      this.focusedBorder,
      this.contentPadding,
      this.keyboardType,
      this.helperText,
      this.hintText,
      this.textCapitalization = TextCapitalization.none,
      this.onTap,
      this.restorationId});

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: visible,
      child: Padding(
        padding: externalPadding,
        child: TextFormField(
          onTap: onTap,
          controller: controller,
          onChanged: onChanged,
          focusNode: focusNode,
          keyboardType: keyboardType,
          validator: validator,
          obscureText: obscureText,
          inputFormatters: inputFormatters,
          minLines: lines,
          readOnly: readOnly,
          maxLines: lines,
          restorationId: restorationId,
          textCapitalization: textCapitalization,
          style: style,
          decoration: InputDecoration(
              suffixIcon: suffixIcon,
              border: border,
              isDense: isDense,
              filled: filled,
              fillColor: fillColor,
              hintText: hintText,
              hintStyle: hintStyle,
              enabledBorder: enabledBorder,
              focusedBorder: focusedBorder,
              contentPadding: contentPadding,
              prefixIcon: prefixIcon,
              helperText: helperText,
              labelText: labelText),
        ),
      ),
    );
  }
}
