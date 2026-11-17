import 'package:flutter/foundation.dart';
import 'package:flutter_app/core/supabase/oauth_redirect_url.dart';
import 'package:flutter_app/core/supabase/supabase_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'sign_in_with_apple_use_case.g.dart';

@riverpod
Future<void> signInWithAppleUseCase(Ref ref) async {
  // Use the common Supabase OAuth flow on all supported targets. Native Apple
  // sign-in can be introduced separately when real provider settings exist.
  final redirect = resolveOAuthRedirectUrl(
    isWeb: kIsWeb,
    currentUri: Uri.base,
    nativeRedirectUrl: SupabaseService.oauthRedirectUrl,
  );

  final launched = await SupabaseService.client.auth.signInWithOAuth(
    OAuthProvider.apple,
    redirectTo: redirect,
    authScreenLaunchMode: kIsWeb ? LaunchMode.platformDefault : LaunchMode.externalApplication,
  );
  if (!launched) {
    throw StateError('Unable to open the Apple OAuth browser.');
  }
  // Browser launch != sign-in. The UI listens to onAuthStateChange for success.
}
