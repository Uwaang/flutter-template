import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app/app/configuration/configuration.dart';
import 'package:flutter_app/app/setup/flavor.dart';
import 'package:flutter_app/app/theme/app_theme.dart';
import 'package:flutter_app/assets/app_localizations.gen.dart';
import 'package:flutter_app/features/authentication/authentication_page_content.dart';
import 'package:flutter_app/features/authentication/authentication_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

Widget _wrap(Widget child, {Brightness brightness = Brightness.light}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: AppTheme.getThemeData(brightness: brightness),
    home: Scaffold(body: child),
  );
}

class _StubAuthNotifier extends AuthenticationStateNotifier {
  _StubAuthNotifier(this._stub);

  final AuthenticationState _stub;

  @override
  FutureOr<AuthenticationState> build() async => _stub;
}

ProviderScope _configuredAuth({bool googleLoading = false, bool appleLoading = false}) {
  return ProviderScope(
    overrides: [
      authBackendConfiguredProvider.overrideWithValue(true),
      authenticationStateProvider.overrideWith(
        () => _StubAuthNotifier(
          AuthenticationState(isGoogleSigningIn: googleLoading, isAppleSigningIn: appleLoading),
        ),
      ),
    ],
    child: _wrap(const AuthenticationPageContent()),
  );
}

void main() {
  Configuration.setup(flavor: Flavor.develop);

  patrolWidgetTest(
    'AuthenticationPageContent - shows mock-only when Supabase is unconfigured',
    ($) async {
      await $.pumpWidgetAndSettle(
        ProviderScope(
          overrides: [
            authenticationStateProvider.overrideWith(
              () => _StubAuthNotifier(
                const AuthenticationState(isGoogleSigningIn: false, isAppleSigningIn: false),
              ),
            ),
          ],
          child: _wrap(const AuthenticationPageContent()),
        ),
      );

      expect(find.text('Mock Sign In'), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
      expect(find.text('Sign in Anonymously'), findsNothing);
      expect(find.text('Sign in with Google'), findsNothing);
      expect(find.text('Sign in with Apple'), findsNothing);
    },
  );

  patrolWidgetTest(
    'AuthenticationPageContent - Google loading disables other sign-in choices',
    ($) async {
      // An indeterminate progress indicator never settles; use a single pump.
      await $.tester.pumpWidget(_configuredAuth(googleLoading: true));
      await $.tester.pump();

      expect(find.text('Mock Sign In'), findsNothing);
      expect(find.text('Sign in with Google'), findsOneWidget);
      expect(find.text('Sign in Anonymously'), findsOneWidget);
      expect(find.text('Sign in with Apple'), findsOneWidget);
      expect(
        $.tester.widget<FilledButton>(find.byKey(const Key('auth_google_button'))).onPressed,
        isNull,
      );
      expect(
        $.tester.widget<OutlinedButton>(find.byKey(const Key('auth_apple_button'))).onPressed,
        isNull,
      );
      expect(
        $.tester.widget<TextButton>(find.byKey(const Key('auth_anonymous_button'))).onPressed,
        isNull,
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    },
  );

  testWidgets('configured sign-in uses Material 3 button hierarchy and existing icons', (tester) async {
    await tester.pumpWidget(_configuredAuth());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('auth_google_button')), findsOneWidget);
    expect(find.byKey(const Key('auth_apple_button')), findsOneWidget);
    expect(find.byKey(const Key('auth_anonymous_button')), findsOneWidget);
    expect(tester.widget<FilledButton>(find.byKey(const Key('auth_google_button'))).onPressed, isNotNull);
    expect(tester.widget<OutlinedButton>(find.byKey(const Key('auth_apple_button'))).onPressed, isNotNull);
    expect(tester.widget<TextButton>(find.byKey(const Key('auth_anonymous_button'))).onPressed, isNotNull);
    expect(find.byType(SvgPicture), findsNWidgets(2));
    expect(find.text('Mock Sign In'), findsNothing);
  });

  testWidgets('compact sign-in viewport scrolls without a layout overflow', (tester) async {
    tester.view.physicalSize = const Size(320, 320);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_configuredAuth());
    await tester.pumpAndSettle();

    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.text('Sign in with Google'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sign-in choices inherit the dark Material 3 theme', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authBackendConfiguredProvider.overrideWithValue(true),
          authenticationStateProvider.overrideWith(
            () => _StubAuthNotifier(
              const AuthenticationState(isGoogleSigningIn: false, isAppleSigningIn: false),
            ),
          ),
        ],
        child: _wrap(const AuthenticationPageContent(), brightness: Brightness.dark),
      ),
    );
    await tester.pumpAndSettle();

    expect(Theme.of(tester.element(find.byKey(const Key('auth_google_button')))).useMaterial3, isTrue);
    expect(Theme.of(tester.element(find.byKey(const Key('auth_google_button')))).brightness, Brightness.dark);
    expect(tester.takeException(), isNull);
  });
}
