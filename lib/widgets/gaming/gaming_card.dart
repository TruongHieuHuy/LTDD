import 'package:flutter/material.dart';
import '../../config/gaming_theme.dart';

/// Gaming-themed card container with optional border glow
class GamingCard extends StatelessWidget {
  final Widget child;
  final bool hasBorder;
  final bool hasGlow;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final double? width;
  final double? height;

  const GamingCard({
    super.key,
    required this.child,
    this.hasBorder = true,
    this.hasGlow = false,
    this.padding,
    this.onTap,
    this.backgroundColor,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final cardContent = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? GamingTheme.surfaceDark,
        borderRadius: BorderRadius.circular(GamingTheme.radiusMedium),
        border: hasBorder
            ? Border.all(color: GamingTheme.border, width: 1)
            : null,
        boxShadow: hasGlow ? GamingTheme.cardShadow : null,
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(GamingTheme.radiusMedium),
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}

/// Gaming-themed card with neon accent border
class GamingNeonCard extends StatelessWidget {
  final Widget child;
  final Color accentColor;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const GamingNeonCard({
    super.key,
    required this.child,
    this.accentColor = GamingTheme.primaryAccent,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardContent = Container(
      decoration: BoxDecoration(
        color: GamingTheme.surfaceDark,
        borderRadius: BorderRadius.circular(GamingTheme.radiusMedium),
        border: Border.all(color: accentColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.4),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(GamingTheme.radiusMedium),
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}
