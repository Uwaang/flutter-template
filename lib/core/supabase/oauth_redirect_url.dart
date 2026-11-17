/// Resolves the destination after Google/Apple authenticate via Supabase Auth.
///
/// Browser URLs must preserve the app's deployed base path, especially the
/// /flutter-template/previews/pr-N/ paths on static GitHub Pages. OAuth codes,
/// temporary query parameters and Flutter hash routes are not part of the
/// callback URL registered in Supabase.
String resolveOAuthRedirectUrl({
  required bool isWeb,
  required Uri currentUri,
  required String? nativeRedirectUrl,
}) {
  if (isWeb) {
    if ((currentUri.scheme != 'https' && currentUri.scheme != 'http') || currentUri.host.isEmpty) {
      throw const FormatException('Web OAuth requires an HTTP(S) page URL.');
    }

    return Uri(
      scheme: currentUri.scheme,
      host: currentUri.host,
      port: currentUri.hasPort ? currentUri.port : null,
      path: currentUri.path,
    ).toString();
  }

  final nativeRedirect = nativeRedirectUrl?.trim();
  if (nativeRedirect == null || nativeRedirect.isEmpty) {
    throw StateError('SUPABASE_OAUTH_REDIRECT_URL is required for native OAuth sign-in.');
  }

  final callback = Uri.tryParse(nativeRedirect);
  if (callback == null || !callback.hasScheme || callback.host.isEmpty || callback.hasFragment) {
    throw const FormatException('Native OAuth redirect must contain a scheme and host, without a fragment.');
  }

  return nativeRedirect;
}
