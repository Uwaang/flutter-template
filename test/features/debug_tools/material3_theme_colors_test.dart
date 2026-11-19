import 'package:flutter/material.dart';
import 'package:flutter_app/app/theme/app_theme.dart';
import 'package:flutter_app/features/debug_tools/page/colors/entity/debug_tools_color.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('debug color samples follow Material 3 ThemeData overrides', () {
    final base = AppTheme.getThemeData(brightness: Brightness.light);
    final changed = base.copyWith(
      colorScheme: base.colorScheme.copyWith(primary: Colors.green),
    );
    final colors = DebugToolsColor.getColors(theme: changed);

    expect(colors.singleWhere((sample) => sample.colorName == 'primary').color, Colors.green);
    expect(colors.singleWhere((sample) => sample.colorName == 'error').color, changed.colorScheme.error);
    expect(colors.any((sample) => sample.colorName == 'success'), isTrue);
  });
}
