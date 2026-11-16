import 'package:flutter/material.dart';
import 'package:flutter_app/common/extension/build_context.dart';
import 'package:flutter_app/core/flogger.dart';

enum AppSnackbarKind { message, success, error }

/// Common Snackbar rendering and duplicate suppression for semantic messages.
class AppSnackbar {
  AppSnackbar({
    required this.context,
    required this.message,
    required this.kind,
    this.optionalBottomSpacing = 0,
  });

  static final Set<(AppSnackbarKind, String)> _shownMessages = {};

  final BuildContext context;
  final String message;
  final AppSnackbarKind kind;
  final double optionalBottomSpacing;

  Future<void> show() async {
    final key = (kind, message);
    if (!_shownMessages.add(key)) {
      Flogger.i('[AppSnackbar] Suppressed duplicate: $message');
      return;
    }

    try {
      final controller = ScaffoldMessenger.of(context).showSnackBar(createSnackBar());
      await controller.closed;
    } finally {
      _shownMessages.remove(key);
    }
  }

  SnackBar createSnackBar() {
    final colorScheme = context.colorScheme;
    final isCompact = MediaQuery.sizeOf(context).width < 600;
    final foreground = switch (kind) {
      AppSnackbarKind.message => colorScheme.snackbarText,
      AppSnackbarKind.success => colorScheme.success,
      AppSnackbarKind.error => colorScheme.error,
    };
    final icon = switch (kind) {
      AppSnackbarKind.message => null,
      AppSnackbarKind.success => Icons.check_circle_outline,
      AppSnackbarKind.error => Icons.error_outline,
    };

    return SnackBar(
      behavior: SnackBarBehavior.floating,
      width: isCompact ? null : 560,
      margin: isCompact ? EdgeInsets.fromLTRB(20, 20, 20, 20 + optionalBottomSpacing) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: colorScheme.snackbarBackground.withValues(alpha: 0.94),
      elevation: 0,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 22),
      content: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 24),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20, color: foreground),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Text(
                message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.labelMedium.copyWith(color: foreground),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
