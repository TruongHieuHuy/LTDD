import 'package:flutter/material.dart';
import '../../config/gaming_theme.dart';

/// Gaming-themed text field with neon border on focus
class GamingTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconTap;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int? maxLines;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final bool enabled;

  const GamingTextField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.obscureText = false,
    this.keyboardType,
    this.maxLines = 1,
    this.onChanged,
    this.validator,
    this.enabled = true,
  });

  @override
  State<GamingTextField> createState() => _GamingTextFieldState();
}

class _GamingTextFieldState extends State<GamingTextField> {
  bool _isFocused = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(GamingTheme.radiusMedium),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: GamingTheme.primaryAccent.withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        obscureText: widget.obscureText,
        keyboardType: widget.keyboardType,
        maxLines: widget.maxLines,
        onChanged: widget.onChanged,
        validator: widget.validator,
        enabled: widget.enabled,
        style: GamingTheme.bodyLarge,
        decoration: InputDecoration(
          hintText: widget.hintText,
          labelText: widget.labelText,
          filled: true,
          fillColor: widget.enabled 
              ? GamingTheme.surfaceLight 
              : GamingTheme.surfaceDark,
          prefixIcon: widget.prefixIcon != null
              ? Icon(
                  widget.prefixIcon,
                  color: _isFocused
                      ? GamingTheme.primaryAccent
                      : GamingTheme.textSecondary,
                )
              : null,
          suffixIcon: widget.suffixIcon != null
              ? IconButton(
                  icon: Icon(
                    widget.suffixIcon,
                    color: GamingTheme.textSecondary,
                  ),
                  onPressed: widget.onSuffixIconTap,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(GamingTheme.radiusMedium),
            borderSide: BorderSide(color: GamingTheme.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(GamingTheme.radiusMedium),
            borderSide: BorderSide(color: GamingTheme.border, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(GamingTheme.radiusMedium),
            borderSide: BorderSide(
              color: GamingTheme.primaryAccent,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(GamingTheme.radiusMedium),
            borderSide: BorderSide(color: GamingTheme.hardRed, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(GamingTheme.radiusMedium),
            borderSide: BorderSide(color: GamingTheme.hardRed, width: 2),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(GamingTheme.radiusMedium),
            borderSide: BorderSide(
              color: GamingTheme.border.withOpacity(0.5),
            ),
          ),
          hintStyle: GamingTheme.bodyMedium.copyWith(
            color: GamingTheme.textDisabled,
          ),
          labelStyle: GamingTheme.bodyMedium.copyWith(
            color: _isFocused
                ? GamingTheme.primaryAccent
                : GamingTheme.textSecondary,
          ),
          errorStyle: GamingTheme.bodySmall.copyWith(
            color: GamingTheme.hardRed,
          ),
        ),
      ),
    );
  }
}
