import 'package:flutter_app/common/provider/current_user_state.dart';
import 'package:flutter_app/core/flogger.dart';
import 'package:flutter_app/core/supabase/supabase_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sign_out_use_case.g.dart';

@riverpod
Future<void> signOutUseCase(Ref ref) async {
  Flogger.d('[Authentication] Signing out');
  if (SupabaseService.isConfigured) {
    await SupabaseService.client.auth.signOut();
  }
  // The local mock profile is also removed if Supabase is not configured.
  await ref.read(currentUserStateProvider.notifier).updateCurrentUser(null);
}
