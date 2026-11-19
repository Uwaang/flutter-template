import 'package:flutter/material.dart';
import 'package:flutter_app/app/theme/custom_color_scheme.dart';

@immutable
class DebugToolsColor {
  const DebugToolsColor({
    required this.colorName,
    required this.color,
  });

  final String colorName;
  final Color color;

  /// The samples must describe the active Material 3 theme rather than
  /// creating a separate STRV palette, so ThemeData overrides are visible.
  static List<DebugToolsColor> getColors({required ThemeData theme}) {
    final colors = theme.colorScheme;
    final semantic = theme.extension<AppSemanticColors>();

    return [
      DebugToolsColor(color: colors.primary, colorName: 'primary'),
      DebugToolsColor(color: colors.onPrimary, colorName: 'onPrimary'),
      DebugToolsColor(color: colors.secondary, colorName: 'secondary'),
      DebugToolsColor(color: colors.onSecondary, colorName: 'onSecondary'),
      DebugToolsColor(color: colors.surface, colorName: 'surface'),
      DebugToolsColor(color: colors.onSurface, colorName: 'onSurface'),
      DebugToolsColor(color: colors.surfaceContainerLow, colorName: 'surfaceContainerLow'),
      DebugToolsColor(color: colors.onSurfaceVariant, colorName: 'onSurfaceVariant'),
      DebugToolsColor(color: colors.outlineVariant, colorName: 'outlineVariant'),
      DebugToolsColor(color: colors.error, colorName: 'error'),
      DebugToolsColor(color: colors.shadow, colorName: 'shadow'),
      if (semantic != null) ...[
        DebugToolsColor(color: semantic.success, colorName: 'success'),
        DebugToolsColor(color: semantic.snackbarBackground, colorName: 'snackbarBackground'),
        DebugToolsColor(color: semantic.snackbarText, colorName: 'snackbarText'),
      ],
    ];
  }
}
