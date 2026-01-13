import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/gaming_theme.dart';
import '../../utils/url_helper.dart';

/// Gaming-themed avatar with optional neon glow
class GamingAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? username;
  final double size;
  final bool hasGlow;
  final Color? glowColor;
  final VoidCallback? onTap;

  const GamingAvatar({
    super.key,
    this.imageUrl,
    this.username,
    this.size = 50,
    this.hasGlow = false,
    this.glowColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Convert relative URL to absolute URL if needed
    final fullImageUrl = UrlHelper.getFullImageUrl(imageUrl);

    final avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: hasGlow
              ? (glowColor ?? GamingTheme.primaryAccent)
              : GamingTheme.border,
          width: hasGlow ? 2 : 1,
        ),
        boxShadow: hasGlow
            ? [
                BoxShadow(
                  color: (glowColor ?? GamingTheme.primaryAccent).withOpacity(
                    0.5,
                  ),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: ClipOval(
        child: fullImageUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: fullImageUrl,
                key: ValueKey(fullImageUrl), // Force reload when URL changes
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: GamingTheme.surfaceDark,
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        GamingTheme.primaryAccent,
                      ),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => _buildInitials(),
                // Force cache refresh
                cacheKey: fullImageUrl,
                maxHeightDiskCache: 200,
                maxWidthDiskCache: 200,
              )
            : _buildInitials(),
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: avatar);
    }

    return avatar;
  }

  Widget _buildInitials() {
    final String initials = _getInitials();
    return Container(
      color: GamingTheme.surfaceDark,
      child: Center(
        child: Text(
          initials,
          style: GamingTheme.bodyLarge.copyWith(
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
            color: GamingTheme.primaryAccent,
          ),
        ),
      ),
    );
  }

  String _getInitials() {
    if (username == null || username!.isEmpty) return '?';

    final parts = username!.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }

    return username!.substring(0, username!.length >= 2 ? 2 : 1).toUpperCase();
  }
}
