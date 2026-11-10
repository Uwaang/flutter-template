import 'package:flutter_app/common/data/entity/exception/custom_exception.dart';
import 'package:flutter_app/common/provider/current_user_state.dart';
import 'package:flutter_app/common/usecase/authentication/sign_out_use_case.dart';
import 'package:flutter_app/common/usecase/get_random_image_url_use_case.dart';
import 'package:flutter_app/core/flogger.dart';
import 'package:flutter_app/core/riverpod/state_handler.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_state.freezed.dart';
part 'profile_state.g.dart';

@freezed
abstract class ProfileState with _$ProfileState {
  const factory ProfileState({
    required String displayName,
    required String imageUrl,
    required bool isSigningOut,
  }) = _ProfileState;
}

@riverpod
class ProfileStateNotifier extends _$ProfileStateNotifier with AutoDisposeStateHandler {
  @override
  FutureOr<ProfileState> build() async {
    final currentUser = await ref.read(currentUserStateProvider.future);
    final imageUrl = currentUser?.imageUrl;

    return ProfileState(
      displayName: currentUser?.displayName ?? '',
      imageUrl: imageUrl ?? ref.read(getRandomImageUrlUseCaseProvider(width: 120, height: 120)),
      isSigningOut: false,
    );
  }

  Future<bool> signOut() async {
    setStateData(currentData?.copyWith(isSigningOut: true));

    try {
      await ref.read(signOutUseCaseProvider.future);
      return true;
    } on Exception catch (error) {
      final customException = CustomException.fromErrorObject(error: error);
      Flogger.e('Error: $customException');
      return false;
    } finally {
      setStateData(currentData?.copyWith(isSigningOut: false));
    }
  }
}
