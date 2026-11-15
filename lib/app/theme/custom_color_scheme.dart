import 'package:flutter/material.dart';
import 'package:flutter_app/common/extension/brightness.dart';

class CustomColorScheme {
  factory CustomColorScheme({required Brightness brightness}) =>
      (brightness.isLightMode) ? CustomColorScheme._light() : CustomColorScheme._dark();

  /// Compatibility view for existing widgets. Runtime values come from
  /// ThemeData, not a second palette created for every build.
  factory CustomColorScheme.fromTheme(ThemeData theme) {
    final colors = theme.colorScheme;
    final extras =
        theme.extension<AppSemanticColors>() ??
        AppSemanticColors.fromPalette(
          CustomColorScheme(brightness: colors.brightness),
        );
    return CustomColorScheme._fromMaterial(colors, extras);
  }

  CustomColorScheme._fromMaterial(ColorScheme colors, AppSemanticColors extras)
    : brightness = colors.brightness,
      primary = colors.primary,
      onPrimary = colors.onPrimary,
      secondary = colors.secondary,
      onSecondary = colors.onSecondary,
      surface = colors.surface,
      surfaceVariant = colors.surfaceContainerLow,
      onSurface = colors.onSurface,
      snackbarBackground = extras.snackbarBackground,
      snackbarText = extras.snackbarText,
      success = extras.success,
      error = colors.error,
      shadow = colors.shadow,
      divider = colors.outlineVariant,
      shimmerBackground = extras.shimmerBackground,
      shimmerForeground = extras.shimmerForeground;

  CustomColorScheme._light()
    : brightness = Brightness.light,
      primary = const Color(0xFF0A59F8),
      onPrimary = const Color(0xFFFFFFFF),
      secondary = const Color(0xFF000000),
      onSecondary = const Color(0xFFFFFFFF),
      surface = const Color(0xFFFFFFFF),
      surfaceVariant = const Color(0xFFF7F7F7),
      onSurface = const Color(0xFF000000),
      snackbarBackground = const Color(0xFF041028),
      snackbarText = const Color(0xFFFFFFFF),
      success = const Color(0xFF10B452),
      error = const Color(0xFFE51934),
      shadow = const Color(0x66000000),
      divider = const Color(0xFFEBEBEB),
      shimmerBackground = const Color(0xFFF0F0F0),
      shimmerForeground = const Color(0xFFF7F7F7);

  CustomColorScheme._dark()
    : brightness = Brightness.dark,
      primary = const Color(0xFF0A59F8),
      onPrimary = const Color(0xFFFFFFFF),
      secondary = const Color(0xFFFFFFFF),
      onSecondary = const Color(0xFF000000),
      surface = const Color(0xFF000000),
      surfaceVariant = const Color(0x1AFFFFFF),
      onSurface = const Color(0xFFFFFFFF),
      snackbarBackground = const Color(0xFF041028),
      snackbarText = const Color(0xFFFFFFFF),
      success = const Color(0xFF10B452),
      error = const Color(0xFFE51934),
      shadow = const Color(0x66000000),
      divider = const Color(0xFFEBEBEB),
      shimmerBackground = const Color(0xFF1F1F1F),
      shimmerForeground = const Color(0x1AFFFFFF);

  // Title: Theme specific colors
  final Brightness brightness;
  final Color primary;
  final Color onPrimary;
  final Color secondary;
  final Color onSecondary;
  final Color surface;
  final Color surfaceVariant;
  final Color onSurface;
  final Color snackbarBackground;
  final Color snackbarText;
  final Color success;
  final Color error;
  final Color shadow;
  final Color divider;
  final Color shimmerBackground;
  final Color shimmerForeground;
}

/// Non-Material semantic colors used by existing feedback and skeleton widgets.
/// Keep these in ThemeData.extensions rather than duplicating ColorScheme roles.
@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.snackbarBackground,
    required this.snackbarText,
    required this.success,
    required this.shimmerBackground,
    required this.shimmerForeground,
  });

  factory AppSemanticColors.fromPalette(CustomColorScheme palette) => AppSemanticColors(
    snackbarBackground: palette.snackbarBackground,
    snackbarText: palette.snackbarText,
    success: palette.success,
    shimmerBackground: palette.shimmerBackground,
    shimmerForeground: palette.shimmerForeground,
  );

  final Color snackbarBackground;
  final Color snackbarText;
  final Color success;
  final Color shimmerBackground;
  final Color shimmerForeground;

  @override
  AppSemanticColors copyWith({
    Color? snackbarBackground,
    Color? snackbarText,
    Color? success,
    Color? shimmerBackground,
    Color? shimmerForeground,
  }) => AppSemanticColors(
    snackbarBackground: snackbarBackground ?? this.snackbarBackground,
    snackbarText: snackbarText ?? this.snackbarText,
    success: success ?? this.success,
    shimmerBackground: shimmerBackground ?? this.shimmerBackground,
    shimmerForeground: shimmerForeground ?? this.shimmerForeground,
  );

  @override
  AppSemanticColors lerp(covariant ThemeExtension<AppSemanticColors>? other, double t) {
    if (other is! AppSemanticColors) return this;
    return AppSemanticColors(
      snackbarBackground: Color.lerp(snackbarBackground, other.snackbarBackground, t)!,
      snackbarText: Color.lerp(snackbarText, other.snackbarText, t)!,
      success: Color.lerp(success, other.success, t)!,
      shimmerBackground: Color.lerp(shimmerBackground, other.shimmerBackground, t)!,
      shimmerForeground: Color.lerp(shimmerForeground, other.shimmerForeground, t)!,
    );
  }
}
