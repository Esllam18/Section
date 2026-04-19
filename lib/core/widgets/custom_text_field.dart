// lib/core/widgets/custom_text_field.dart
import 'package:flutter/material.dart';
import 'package:section/core/constants/app_colors.dart';

class CustomTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  // Support both prefixIcon (IconData) and prefix (Widget)
  final IconData? prefixIcon;
  final Widget? prefix;
  final Widget? suffix;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;

  const CustomTextField({
    super.key, this.label, this.hint, this.controller,
    this.isPassword = false, this.keyboardType = TextInputType.text,
    this.validator, this.onChanged, this.onSubmitted,
    this.prefixIcon, this.prefix, this.suffix, this.maxLines = 1,
    this.readOnly = false, this.onTap, this.focusNode, this.textInputAction,
  });

  @override State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscure = true;

  Widget? _buildPrefix() {
    if (widget.prefix != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: widget.prefix,
      );
    }
    if (widget.prefixIcon != null) {
      return Icon(widget.prefixIcon, color: AppColors.textSecondaryLight, size: 20);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword && _obscure,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      maxLines: widget.isPassword ? 1 : widget.maxLines,
      readOnly: widget.readOnly,
      onTap: widget.onTap,
      focusNode: widget.focusNode,
      textInputAction: widget.textInputAction,
      style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        prefixIcon: _buildPrefix(),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: AppColors.textSecondaryLight, size: 20),
                onPressed: () => setState(() => _obscure = !_obscure))
            : widget.suffix,
      ),
    );
  }
}
