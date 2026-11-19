import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/configuration/configuration.dart';
import 'package:flutter_app/app/setup/flavor.dart';
import 'package:flutter_app/common/component/custom_profile_avatar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

void main() {
  // Title: Setup app configuration
  Configuration.setup(flavor: Flavor.develop);

  patrolWidgetTest(
    'ProfileCircleAvatar - Widget test',
    ($) async {
      // Title: Inflate widget
      await $.pumpWidget(
        const CustomProfileAvatar(
          imageUrl: 'http://www.test.com/img.jpg',
          size: 56,
        ),
      );
    },
  );
  testWidgets('ProfileAvatar uses a bundled placeholder when image URL is absent', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CustomProfileAvatar(imageUrl: null, size: 56),
        ),
      ),
    );

    expect(find.byType(ExtendedImage), findsNothing);
    expect(find.byType(SvgPicture), findsOneWidget);
  });
}
