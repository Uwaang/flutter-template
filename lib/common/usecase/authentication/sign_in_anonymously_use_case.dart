import 'package:flutter_app/core/flogger.dart';
import 'package:flutter_app/core/supabase/supabase_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sign_in_anonymously_use_case.g.dart';

@riverpod
Future<void> signInAnonymouslyUseCase(Ref ref) async {
  Flogger.d('[Authentication] Starting Supabase anonymous sign-in');
  await SupabaseService.client.auth.signInAnonymously();
}
