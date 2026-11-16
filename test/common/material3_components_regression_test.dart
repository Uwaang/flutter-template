import 'package:flutter/material.dart';
import 'package:flutter_app/app/theme/app_theme.dart';
import 'package:flutter_app/common/component/custom_app_bar.dart';
import 'package:flutter_app/common/component/custom_switch.dart';
import 'package:flutter_app/common/composition/responsive_widget.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CustomAppBar preferred size includes the toolbar and bottom', () {
    const appBar = CustomAppBar(
      toolbarHeight: 72,
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(32),
        child: SizedBox(),
      ),
    );

    expect(appBar.preferredSize.height, 104);
  });

  test('ResponsiveWidget does not hide layout builder errors', () {
    expect(
      () => ResponsiveWidget.resolveValueByWidth<int>(
        1700,
        small: () => 1,
        large: () => throw FlutterError('Large layout failed'),
      ),
      throwsA(isA<FlutterError>()),
    );
  });

  for (final brightness in Brightness.values) {
    testWidgets('CustomSwitch subtitle uses onSurface in ${brightness.name}', (
      tester,
    ) async {
      final theme = AppTheme.getThemeData(brightness: brightness);

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: CustomSwitch(
              title: 'Notifications',
              subtitle: 'Summary',
              value: false,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      final subtitle = tester.widget<Text>(find.text('Summary'));
      expect(
        subtitle.style?.color,
        theme.colorScheme.onSurface.withValues(alpha: 0.5),
      );
    });
  }
}
