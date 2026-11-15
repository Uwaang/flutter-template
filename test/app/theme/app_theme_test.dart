import 'package:flutter/material.dart';
import 'package:flutter_app/app/theme/app_theme.dart';
import 'package:flutter_app/app/theme/custom_color_scheme.dart';
import 'package:flutter_app/assets/fonts.gen.dart';
import 'package:flutter_app/common/component/custom_button/custom_button_primary.dart';
import 'package:flutter_app/common/extension/build_context.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Material 3 theme', () {
    for (final brightness in Brightness.values) {
      test('uses one palette and typography for ${brightness.name}', () {
        final theme = AppTheme.getThemeData(brightness: brightness);
        final legacyColors = CustomColorScheme(brightness: brightness);

        expect(theme.useMaterial3, isTrue);
        expect(theme.colorScheme.brightness, brightness);
        expect(theme.colorScheme.primary, legacyColors.primary);
        expect(theme.colorScheme.onPrimary, legacyColors.onPrimary);
        expect(theme.colorScheme.surface, legacyColors.surface);
        expect(theme.colorScheme.onSurface, legacyColors.onSurface);
        expect(theme.textTheme.titleMedium?.fontFamily, FontFamily.clashDisplay);
        expect(theme.textTheme.titleMedium?.fontSize, 16);
        expect(theme.textTheme.bodyMedium?.color, legacyColors.onSurface);

        // Do not override every Material 3 ElevatedButton with a branded style.
        expect(theme.elevatedButtonTheme.style, isNull);
        expect(theme.colorScheme.surfaceContainerLow, legacyColors.surfaceVariant);
        expect(theme.colorScheme.outlineVariant, legacyColors.divider);
        expect(theme.extension<AppSemanticColors>()!.success, legacyColors.success);
      });
    }
  });

  testWidgets('primary button inherits the shared Material theme', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.getThemeData(brightness: Brightness.light),
        home: Scaffold(
          body: CustomButtonPrimary(
            text: 'Continue',
            onPressed: () {},
          ),
        ),
      ),
    );

    expect(find.text('Continue'), findsOneWidget);
    expect(tester.widget<ElevatedButton>(find.byType(ElevatedButton)).style, isNull);
  });

  testWidgets('existing theme getters resolve the active Material theme', (tester) async {
    final baseTheme = AppTheme.getThemeData(brightness: Brightness.light);
    final modifiedTheme = baseTheme.copyWith(
      colorScheme: baseTheme.colorScheme.copyWith(primary: Colors.green),
      textTheme: baseTheme.textTheme.copyWith(
        titleMedium: baseTheme.textTheme.titleMedium!.copyWith(fontSize: 19),
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: modifiedTheme,
        home: Builder(
          builder: (context) {
            expect(context.colorScheme.primary, Colors.green);
            expect(context.textTheme.titleMedium.fontSize, 19);
            expect(
              context.colorScheme.snackbarBackground,
              modifiedTheme.extension<AppSemanticColors>()!.snackbarBackground,
            );
            return const SizedBox();
          },
        ),
      ),
    );
  });
}
