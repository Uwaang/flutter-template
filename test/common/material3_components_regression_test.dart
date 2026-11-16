import 'package:flutter/material.dart';
import 'package:flutter_app/common/component/custom_app_bar.dart';
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
}
