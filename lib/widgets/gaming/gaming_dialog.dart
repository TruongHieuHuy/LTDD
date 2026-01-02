import 'package:flutter/material.dart';
import '../../config/gaming_theme.dart';
import 'gaming_button.dart';

/// Gaming-themed dialog types
enum GamingDialogType { error, success, warning, info, confirm }

/// Gaming-themed dialog
class GamingDialog extends StatelessWidget {
  final GamingDialogType type;
  final String title;
  final String message;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const GamingDialog({
    super.key,
    required this.type,
    required this.title,
    required this.message,
    this.confirmText,
    this.cancelText,
    this.onConfirm,
    this.onCancel,
  });

  /// Show error dialog
  static Future<void> showError(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    return showDialog(
      context: context,
      builder: (context) => GamingDialog(
        type: GamingDialogType.error,
        title: title,
        message: message,
        confirmText: 'OK',
        onConfirm: () => Navigator.of(context).pop(),
      ),
    );
  }

  /// Show success dialog
  static Future<void> showSuccess(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    return showDialog(
      context: context,
      builder: (context) => GamingDialog(
        type: GamingDialogType.success,
        title: title,
        message: message,
        confirmText: 'OK',
        onConfirm: () => Navigator.of(context).pop(),
      ),
    );
  }

  /// Show confirm dialog
  static Future<bool> showConfirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => GamingDialog(
        type: GamingDialogType.confirm,
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: GamingTheme.surfaceDark,
          borderRadius: BorderRadius.circular(GamingTheme.radiusLarge),
          border: Border.all(
            color: _getAccentColor(),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: _getAccentColor().withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getAccentColor().withOpacity(0.2),
                  border: Border.all(
                    color: _getAccentColor(),
                    width: 2,
                  ),
                ),
                child: Icon(
                  _getIcon(),
                  color: _getAccentColor(),
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                title,
                style: GamingTheme.h3.copyWith(
                  color: _getAccentColor(),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Message
              Text(
                message,
                style: GamingTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (cancelText != null) ...[
                    Expanded(
                      child: GamingButton(
                        text: cancelText!,
                        style: GamingButtonStyle.outline,
                        onPressed: onCancel ?? () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  Expanded(
                    child: GamingButton(
                      text: confirmText ?? 'OK',
                      style: GamingButtonStyle.primary,
                      onPressed: onConfirm ?? () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getAccentColor() {
    switch (type) {
      case GamingDialogType.error:
        return GamingTheme.hardRed;
      case GamingDialogType.success:
        return GamingTheme.easyGreen;
      case GamingDialogType.warning:
        return GamingTheme.mediumOrange;
      case GamingDialogType.info:
      case GamingDialogType.confirm:
        return GamingTheme.primaryAccent;
    }
  }

  IconData _getIcon() {
    switch (type) {
      case GamingDialogType.error:
        return Icons.error_outline;
      case GamingDialogType.success:
        return Icons.check_circle_outline;
      case GamingDialogType.warning:
        return Icons.warning_amber_outlined;
      case GamingDialogType.info:
        return Icons.info_outline;
      case GamingDialogType.confirm:
        return Icons.help_outline;
    }
  }
}
