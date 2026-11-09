import 'package:flutter_app/common/data/entity/user_entity.dart';
import 'package:flutter_app/common/data/enum/user_role.dart';
import 'package:flutter_app/core/supabase/supabase_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sign_in_completion_use_case.g.dart';

/// Map Supabase Auth's user to the existing local UI entity.
/// No profile table, database CRUD, or backend "sign-in completion" API.
@riverpod
Future<UserEntity> signInCompletionUseCase(Ref ref) async {
  final user = SupabaseService.client.auth.currentUser;
  if (user == null) {
    throw StateError('No Supabase user is signed in.');
  }

  final metadata = user.userMetadata;
  return UserEntity(
    id: user.id,
    role: user.isAnonymous ? UserRole.guest : UserRole.user,
    email: user.email,
    displayName: (metadata?['full_name'] ?? metadata?['name']) as String?,
    imageUrl: metadata?['avatar_url'] as String?,
    referredId: null,
  );
}
