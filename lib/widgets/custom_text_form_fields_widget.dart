import 'package:flutter/material.dart';
 
class CustomTxtFormField extends StatelessWidget {
  const CustomTxtFormField({
    super.key,
    required this.hintText,
    this.labelText,
    this.readOnly,
    this.validator,
    this.controller,
    this.onChanged,
    this.obscureText = false,
    this.suffix,
  });

  final String hintText;
  final String? labelText;
  final bool? readOnly;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final TextEditingController? controller;
  final bool obscureText;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return TextFormField(
      obscureText: obscureText,
      readOnly: readOnly ?? false,
      textCapitalization: TextCapitalization.none,
      controller: controller,
      validator: validator,
      style: TextStyle(
        fontSize: 15,
        color: theme.colorScheme.onSurface,
        fontWeight: FontWeight.w500,
      ),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: labelText,
        errorMaxLines: 2,
        suffixIcon: suffix,
        suffixIconColor: theme.colorScheme.primary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        hintText: hintText,
        hintStyle: TextStyle(
          color: theme.colorScheme.onSurface.withOpacity(0.4),
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        filled: true,
        fillColor: theme.brightness == Brightness.dark
            ? Colors.white.withOpacity(0.05)
            : Colors.grey[100],
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
    );
  }
}
