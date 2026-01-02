import 'package:flutter/material.dart';
import '../../config/gaming_theme.dart';

/// Gaming-themed button with three styles: primary, secondary, outline
enum GamingButtonStyle { primary, secondary, outline }

class GamingButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final GamingButtonStyle style;
  final IconData? icon;
  final bool isLoading;
  final double? width;

  const GamingButton({
    super.key,
    required this.text,
    this.onPressed,
    this.style = GamingButtonStyle.primary,
    this.icon,
    this.isLoading = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onPressed != null && !isLoading;

    return SizedBox(
      width: width,
      child: Container(
        decoration: _getDecoration(),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isEnabled ? onPressed : null,
            borderRadius: BorderRadius.circular(GamingTheme.radiusMedium),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 14,
              ),
              child: _buildContent(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }

    final textWidget = Text(
      text,
      style: GamingTheme.bodyLarge.copyWith(
        fontWeight: FontWeight.bold,
        color: _getTextColor(),
        letterSpacing: 1.2,
      ),
      textAlign: TextAlign.center,
    );

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: _getTextColor(), size: 20),
          const SizedBox(width: 4),
          textWidget,
        ],
      );
    }

    return Center(child: textWidget);
  }

  BoxDecoration _getDecoration() {
    switch (style) {
      case GamingButtonStyle.primary:
        return BoxDecoration(
          gradient: GamingTheme.primaryGradient,
          borderRadius: BorderRadius.circular(GamingTheme.radiusMedium),
          boxShadow: onPressed != null ? GamingTheme.buttonShadow : [],
        );

      case GamingButtonStyle.secondary:
        return BoxDecoration(
          color: GamingTheme.surfaceDark,
          borderRadius: BorderRadius.circular(GamingTheme.radiusMedium),
          border: Border.all(
            color: GamingTheme.primaryAccent,
            width: 1,
          ),
          boxShadow: onPressed != null ? GamingTheme.cardShadow : [],
        );

      case GamingButtonStyle.outline:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(GamingTheme.radiusMedium),
          border: Border.all(
            color: GamingTheme.primaryAccent,
            width: 2,
          ),
        );
    }
  }

  Color _getTextColor() {
    if (onPressed == null) return GamingTheme.textDisabled;

    switch (style) {
      case GamingButtonStyle.primary:
        return Colors.white;
      case GamingButtonStyle.secondary:
      case GamingButtonStyle.outline:
        return GamingTheme.primaryAccent;
    }
  }
}
