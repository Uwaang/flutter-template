import 'package:flutter/material.dart';
import 'package:flutter_app/features/debug_tools/page/widgets/debug_tools_widgets_page_content.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Material 3 form reports empty and short name errors', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: DebugToolsWidgetsPageContent())),
    );

    await tester.tap(find.text('Validate name'));
    await tester.pump();
    expect(find.text('Please enter a name.'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('debug_sample_name_field')), 'Al');
    await tester.tap(find.text('Validate name'));
    await tester.pump();
    expect(find.text('Enter at least 3 characters.'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('debug_sample_name_field')), 'Alice');
    await tester.tap(find.text('Validate name'));
    await tester.pump();
    expect(find.text('Enter at least 3 characters.'), findsNothing);
  });
}
