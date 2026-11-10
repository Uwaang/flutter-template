import 'package:flutter_app/core/supabase/supabase_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'get_authorization_token_use_case.g.dart';

@riverpod
Future<String?> getAuthorizationTokenUseCase(
  Ref ref, {
  bool forceRefresh = false,
}) async {
  if (!SupabaseService.isConfigured) return null;

  if (forceRefresh) {
    await SupabaseService.client.auth.refreshSession();
  }
  final session = SupabaseService.client.auth.currentSession;
  if (session == null || session.isExpired) return null;
  return session.accessToken;
}
