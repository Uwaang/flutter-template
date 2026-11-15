import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/theme/custom_color_scheme.dart';
import 'package:flutter_app/app/theme/custom_text_theme.dart';

/// Class used to publicly expose themes.
///
/// If you want to expose more colors, styles and so on, you can create public
/// properties here in this class. In order to make code more readable, app theme
/// is separated to multiple files.
class AppTheme {
  AppTheme._();

  static ThemeData getThemeData({required Brightness brightness}) {
    final colorScheme = CustomColorScheme(brightness: brightness);
    final textTheme = CustomTextTheme(colorScheme: colorScheme);

    // Material 3 is the runtime source of truth. The legacy palette only
    // supplies initial values; existing widgets read back from ThemeData.
    final nativeColorScheme =
        ColorScheme.fromSeed(
          seedColor: colorScheme.primary,
          brightness: brightness,
        ).copyWith(
          primary: colorScheme.primary,
          onPrimary: colorScheme.onPrimary,
          secondary: colorScheme.secondary,
          onSecondary: colorScheme.onSecondary,
          surface: colorScheme.surface,
          surfaceContainerLow: colorScheme.surfaceVariant,
          onSurface: colorScheme.onSurface,
          outlineVariant: colorScheme.divider,
          error: colorScheme.error,
          shadow: colorScheme.shadow,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: nativeColorScheme,
      visualDensity: VisualDensity.standard, // Needed for consistent web and app sizing
      textTheme: textTheme.toMaterialTextTheme(),
      scaffoldBackgroundColor: colorScheme.surface,
      extensions: <ThemeExtension<dynamic>>[
        AppSemanticColors.fromPalette(colorScheme),
      ],
      // Warning: IconButtonTheme needs to be set till this is fixed: https://github.com/flutter/flutter/issues/130485
      iconButtonTheme: const IconButtonThemeData(style: ButtonStyle()),
      bottomSheetTheme: _getBottomSheetThemeData(colorScheme: colorScheme),
      scrollbarTheme: ScrollbarThemeData(thumbColor: WidgetStateProperty.all(colorScheme.onSurface.withValues(alpha: 0.3))),
      // Warning: textSelectionTheme must be overwritten here.
      // Overriding theme only around TextField does not work for [selectionHandleColor]
      textSelectionTheme: _getTextSelectionThemeData(colorScheme: colorScheme),
      // This is hotfix that is needed to set correct color for [selectionHandleColor] on iOS.
      cupertinoOverrideTheme: CupertinoThemeData(primaryColor: colorScheme.secondary),
    );
  }
}

BottomSheetThemeData _getBottomSheetThemeData({
  required CustomColorScheme colorScheme,
}) => BottomSheetThemeData(
  backgroundColor: colorScheme.surface,
  surfaceTintColor: colorScheme.surface,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(12),
      topRight: Radius.circular(12),
    ),
  ),
);

TextSelectionThemeData _getTextSelectionThemeData({
  required CustomColorScheme colorScheme,
}) => TextSelectionThemeData(
  cursorColor: colorScheme.secondary,
  selectionColor: colorScheme.secondary.withValues(alpha: 0.3),
  selectionHandleColor: colorScheme.secondary,
);
