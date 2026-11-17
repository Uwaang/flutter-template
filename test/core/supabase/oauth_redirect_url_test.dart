import 'package:flutter_app/core/supabase/oauth_redirect_url.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Pages main OAuth returns to the existing app base, not the hash route', () {
    final result = resolveOAuthRedirectUrl(
      isWeb: true,
      currentUri: Uri.parse('https://uwaang.github.io/flutter-template/#/authentication'),
      nativeRedirectUrl: null,
    );
    expect(result, 'https://uwaang.github.io/flutter-template/');
  });

  test('Pages PR OAuth keeps the exact preview subpath', () {
    final result = resolveOAuthRedirectUrl(
      isWeb: true,
      currentUri: Uri.parse('https://uwaang.github.io/flutter-template/previews/pr-15/#/authentication'),
      nativeRedirectUrl: null,
    );
    expect(result, 'https://uwaang.github.io/flutter-template/previews/pr-15/');
  });

  test('Local path-based Web OAuth omits query and fragment', () {
    final result = resolveOAuthRedirectUrl(
      isWeb: true,
      currentUri: Uri.parse('http://localhost:8080/authentication?state=temporary#fragment'),
      nativeRedirectUrl: null,
    );
    expect(result, 'http://localhost:8080/authentication');
  });

  test('Native OAuth uses the configured deep-link callback', () {
    final result = resolveOAuthRedirectUrl(
      isWeb: false,
      currentUri: Uri.parse('file:///'),
      nativeRedirectUrl: ' fluttertemplate://login-callback ',
    );
    expect(result, 'fluttertemplate://login-callback');
  });

  test('Native OAuth fails without a registered callback', () {
    expect(
      () => resolveOAuthRedirectUrl(
        isWeb: false,
        currentUri: Uri.parse('file:///'),
        nativeRedirectUrl: '',
      ),
      throwsStateError,
    );
  });

  test('Native OAuth rejects a callback with no host', () {
    expect(
      () => resolveOAuthRedirectUrl(
        isWeb: false,
        currentUri: Uri.parse('file:///'),
        nativeRedirectUrl: 'fluttertemplate:callback',
      ),
      throwsFormatException,
    );
  });
}
