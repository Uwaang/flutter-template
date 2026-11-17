import 'package:flutter/material.dart';
import 'package:flutter_app/features/debug_tools/page/widgets/debug_tools_widgets_page_content.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildSample() => const MaterialApp(
    home: Scaffold(body: Material3InteractionSamples()),
  );

  testWidgets('filter chips update visible samples and show an empty state', (tester) async {
    await tester.pumpWidget(buildSample());

    expect(find.text('Buttons example'), findsOneWidget);
    expect(find.text('Inputs example'), findsOneWidget);
    expect(find.text('Feedback example'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilterChip, 'Buttons'));
    await tester.pumpAndSettle();
    expect(find.text('Buttons example'), findsNothing);
    expect(find.text('Inputs example'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilterChip, 'Inputs'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilterChip, 'Feedback'));
    await tester.pumpAndSettle();

    expect(find.text('No examples selected. Choose a category above.'), findsOneWidget);
  });

  testWidgets('segmented button switches from cards to a list', (tester) async {
    await tester.pumpWidget(buildSample());

    expect(find.byKey(const Key('sample_card_preview')), findsOneWidget);

    await tester.tap(find.text('List'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('sample_list_preview')), findsOneWidget);
    expect(find.byKey(const Key('sample_card_preview')), findsNothing);
    expect(find.text('Feedback example'), findsOneWidget);
  });
}
