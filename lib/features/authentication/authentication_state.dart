import 'package:flutter_app/common/data/entity/exception/custom_exception.dart';
import 'package:flutter_app/common/data/entity/user_entity.dart';
import 'package:flutter_app/common/data/enum/user_role.dart';
import 'package:flutter_app/common/provider/current_user_state.dart';
import 'package:flutter_app/common/usecase/authentication/sign_in_anonymously_use_case.dart';
import 'package:flutter_app/common/usecase/authentication/sign_in_completion_use_case.dart';
import 'package:flutter_app/common/usecase/authentication/sign_in_with_apple_use_case.dart';
import 'package:flutter_app/common/usecase/authentication/sign_in_with_google_use_case.dart';
import 'package:flutter_app/core/flogger.dart';
import 'package:flutter_app/core/riverpod/state_handler.dart';
import 'package:flutter_app/features/authentication/authentication_event.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'authentication_state.freezed.dart';
part 'authentication_state.g.dart';

@freezed
abstract class AuthenticationState with _$AuthenticationState {
  const factory AuthenticationState({
    required bool isGoogleSigningIn,
    required bool isAppleSigningIn,
  }) = _AuthenticationState;
}

@riverpod
class AuthenticationStateNotifier extends _$AuthenticationStateNotifier with AutoDisposeStateHandler {
  bool _completing = false;

  @override
  FutureOr<AuthenticationState> build() async {
    return const AuthenticationState(
      isGoogleSigningIn: false,
      isAppleSigningIn: false,
    );
  }

  Future<void> mockSignIn() async {
    // Synthetic first-screen demo only. This must never be considered a
    // successful Supabase Auth sign-in or a production user.
    const user = UserEntity(
      id: 'mock-user',
      role: UserRole.guest,
      email: 'demo@example.invalid',
      displayName: 'Demo User',
      imageUrl: null,
      referredId: null,
    );
    await ref.read(currentUserStateProvider.notifier).updateCurrentUser(user);
    ref.read(authenticationEventNotifierProvider.notifier).send(const AuthenticationEvent.signedIn());
  }

  Future<void> signInAnonymously() async {
    try {
      await ref.read(signInAnonymouslyUseCaseProvider.future);
      await completeSupabaseSignIn();
    } on Exception catch (error) {
      _handleError(error);
    }
  }

  Future<void> signInWithGoogle() async {
    setStateData(currentData?.copyWith(isGoogleSigningIn: true));
    try {
      await ref.read(signInWithGoogleUseCaseProvider.future);
    } on Exception catch (error) {
      _handleError(error);
    } finally {
      setStateData(currentData?.copyWith(isGoogleSigningIn: false));
    }
  }

  Future<void> signInWithApple() async {
    setStateData(currentData?.copyWith(isAppleSigningIn: true));
    try {
      await ref.read(signInWithAppleUseCaseProvider.future);
    } on Exception catch (error) {
      _handleError(error);
    } finally {
      setStateData(currentData?.copyWith(isAppleSigningIn: false));
    }
  }

  /// Called only after Supabase actually emits a signed-in/refresh event
  /// (or anonymous signInAnonymously returns a real session).
  Future<void> completeSupabaseSignIn() async {
    if (_completing) return;
    _completing = true;
    try {
      final user = await ref.read(signInCompletionUseCaseProvider.future);
      await ref.read(currentUserStateProvider.notifier).updateCurrentUser(user);
      ref.read(authenticationEventNotifierProvider.notifier).send(const AuthenticationEvent.signedIn());
    } on Exception catch (error) {
      _handleError(error);
    } finally {
      _completing = false;
    }
  }

  void _handleError(Object error) {
    final customException = CustomException.fromErrorObject(error: error);
    customException.maybeWhen(
      signInCancelled: () => Flogger.d('[Authentication] Sign-in cancelled'),
      orElse: () {
        Flogger.e('[Authentication] Error while signing in: $customException');
        ref.read(authenticationEventNotifierProvider.notifier).send(AuthenticationEvent.error(customException));
      },
    );
  }
}
